// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {ICTFRegistry} from "../interfaces/ICTFRegistry.sol";
import {IChallenge} from "../interfaces/IChallenge.sol";

/*
 * @title CTFRegistry
 * @author cyfrin.io
 * 
 * @notice check out https://updraft.cyfrin.io/ for more badass web3 content!
 *
 * @notice This contract is used to mint NFTs after a user has completed a CTF/Challenge.
 * It works as the "hub" for the entire CTF system.
 *
 * Each challenge needs to be added to this contract, and only then can an NFT be minted.
 */
abstract contract CTFRegistry is ERC721, Ownable, ICTFRegistry {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 private s_tokenCounter;
    mapping(uint256 tokenId => address challengeContract) private s_tokenIdToChallengeContract;
    mapping(address user => mapping(address challenge => bool hasSolved)) private s_userToChallengeToHasSolved;
    address[] private s_challengeContracts;

    string private constant DEFAULT_ATTRIBUTE = "Getting learned!";

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event ChallengeAdded(address challengeContract);
    event ChallengeReplaced(address oldChallenge, address newChallenge);
    event BaseTokenImageUriChanged(string newUri);
    event ChallengeSolved(address solver, address challenge, string twitterHandle);

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyChallengeContract(address contractAddress) {
        bool found = false;
        for (uint256 i; i < s_challengeContracts.length; i++) {
            if (s_challengeContracts[i] == contractAddress) {
                found = true;
                break;
            }
        }
        if (found) {
            _;
        } else {
            revert CTFRegistry__NotChallengeContract();
        }
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(string memory ctfName, string memory symbol) ERC721(ctfName, symbol) Ownable(msg.sender) {}

    /*
     * @dev adds a contract to the list of challenge contracts.
     * @param challengeContract - The address of the challenge contract to add.
     */
    function addChallenge(address challengeContract) external onlyOwner returns (address) {
        s_challengeContracts.push(challengeContract);
        emit ChallengeAdded(challengeContract);
        return challengeContract;
    }

    /*
     * @notice Replaces a challenge contract.
     * @param challengeIndex - The index of the challenge contract to replace.
     * @param newChallenge - The address of the new challenge contract.
     */
    function replaceChallenge(uint256 challengeIndex, address newChallenge) external onlyOwner {
        address oldChallenge = s_challengeContracts[challengeIndex];
        s_challengeContracts[challengeIndex] = newChallenge;
        emit ChallengeReplaced(oldChallenge, newChallenge);
    }

    /*
     * @dev This function is used to mint an NFT for a challenge contract.
     * Once a challenge contract is solved, the challenge contract should call
     * this function to mint an NFT for the user.
     *
     * @dev _safeMint has a check to make sure the tokenId hasn't already been
     * minted, so we don't need to check that here.
     */
    function mintNft(address receiver, string memory twitterHandle)
        external
        virtual
        onlyChallengeContract(msg.sender)
        returns (uint256)
    {
        if (s_userToChallengeToHasSolved[receiver][msg.sender] == true) {
            revert CTFRegistry__YouAlreadySolvedThis();
        }
        uint256 tokenId = s_tokenCounter;
        s_tokenCounter = tokenId + 1;
        s_tokenIdToChallengeContract[tokenId] = msg.sender;
        s_userToChallengeToHasSolved[receiver][msg.sender] = true;
        emit ChallengeSolved(receiver, msg.sender, twitterHandle);
        _safeMint(receiver, tokenId);
        return tokenId;
    }

    /*//////////////////////////////////////////////////////////////
                       FUNCTIONS - VIEW AND PURE
    //////////////////////////////////////////////////////////////*/
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        IChallenge courseChallenge = IChallenge(s_tokenIdToChallengeContract[tokenId]);
        // check to see if the challenge has a special image using a string comparison
        string memory imageUriOfTokenId = courseChallenge.imageUri();

        string memory attribute = keccak256(bytes(courseChallenge.attribute())) != keccak256(bytes(""))
            ? courseChallenge.attribute()
            : DEFAULT_ATTRIBUTE;

        address owner = ownerOf(tokenId);

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description": "',
                            courseChallenge.description(),
                            courseChallenge.extraDescription(owner),
                            '", ',
                            '"attributes": [{"trait_type": "',
                            attribute,
                            '", "value": 100}], "image":"',
                            imageUriOfTokenId,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    /*
     * @dev Returns true if the contract address is a challenge contract.
     * It will return false for the RemoveChallenge contract.
     */
    function isChallengeContract(address contractAddress) external view returns (bool) {
        for (uint256 i; i < s_challengeContracts.length; i++) {
            if (s_challengeContracts[i] == contractAddress) {
                return true;
            }
        }
        return false;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function getChallengeContract(uint256 index) external view returns (address) {
        return s_challengeContracts[index];
    }

    function getChallengeContractFromTokenId(uint256 tokenId) external view returns (address) {
        return s_tokenIdToChallengeContract[tokenId];
    }

    function getChallengeContractFullDescription(uint256 tokenId) external view returns (string memory) {
        IChallenge courseChallenge = IChallenge(s_tokenIdToChallengeContract[tokenId]);
        address owner = ownerOf(tokenId);
        string memory description = courseChallenge.description();
        string memory extraDescription = courseChallenge.extraDescription(owner);
        return string(abi.encodePacked(description, extraDescription));
    }
}
