// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IChallenge} from "../interfaces/IChallenge.sol";
import {ICTFRegistry} from "../interfaces/ICTFRegistry.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Challenge is IChallenge, Ownable {
    error Challenge__CantBeZeroAddress();

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    string internal s_imageUri;
    string internal s_description;
    string internal s_attribute;
    ICTFRegistry internal immutable i_registry;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event AttributeChanged(string newAttribute);
    event DescriptionChanged(string newDescription);
    event ExtraDescriptionChanged(string newExtraDescription);
    event ImageUriChanged(string newImageUri);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(
        address registry,
        string memory startingAttribute,
        string memory startingDescription,
        string memory imageURI
    ) Ownable(msg.sender) {
        if (registry == address(0)) {
            revert Challenge__CantBeZeroAddress();
        }
        i_registry = ICTFRegistry(registry);
        s_attribute = startingAttribute;
        s_description = startingDescription;
        s_imageUri = imageURI;
    }

    /*
     * A lot of users have solved the challenges on different chains.
     * This function allows the admin to mint the solvers from past challenges onto the registry.
     */
    function adminMintSolvers(address[] memory solvers) external onlyOwner {
        for (uint256 i = 0; i < solvers.length; i++) {
            ICTFRegistry(i_registry).mintNft(solvers[i], "");
        }
    }

    /*
     * @param twitterHandleOfSolver - The twitter handle of the solver.
     * It can be left blank.
     */
    function _updateAndRewardSolver(string memory twitterHandleOfSolver) internal virtual {
        ICTFRegistry(i_registry).mintNft(msg.sender, twitterHandleOfSolver);
    }

    /*
     * @notice Changes the attribute of a challenge.
     */
    function changeAttribute(string memory newAttribute) external onlyOwner {
        emit AttributeChanged(newAttribute);
        s_attribute = newAttribute;
    }

    /* 
     * @notice Changes the description of a challenge.
     */
    function changeDescription(string memory newDescription) external onlyOwner {
        emit DescriptionChanged(newDescription);
        s_description = newDescription;
    }

    /*
     * @notice Changes the special image of a challenge.
     */
    function changeImage(string memory newImageUri) external onlyOwner {
        emit ImageUriChanged(newImageUri);
        s_imageUri = newImageUri;
    }

    /*//////////////////////////////////////////////////////////////
                                  VIEW
    //////////////////////////////////////////////////////////////*/
    function attribute() external view virtual returns (string memory) {
        return s_attribute;
    }

    function description() external view virtual returns (string memory) {
        return s_description;
    }

    function imageUri() external view virtual returns (string memory) {
        return s_imageUri;
    }

    /* 
     * @notice if a description is supposed to be per-user unique, then this function should overriden.
     * @param user - The user for which the description is being requested.
     * 
     * Note: You'll notice we only defined extraDescription and special image but not description and attribute.
     * This is because we wanted to enforce challenge builders to remember to add the latter.
     */
    function extraDescription(address /* user */ ) external view virtual returns (string memory) {
        return "";
    }

    // We should have one of these too... but the signature might be different, so we don't force it.
    // function solveChallenge() external virtual {}
}
