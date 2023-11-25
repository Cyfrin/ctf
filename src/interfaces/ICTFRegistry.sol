// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ICTFRegistry {
    /////////////
    // Errors  //
    /////////////
    error CTFRegistry__NotChallengeContract();
    error CTFRegistry__NFTNotMinted();
    error CTFRegistry__YouAlreadySolvedThis();

    function mintNft(address receiver, string memory twitterHandle) external returns (uint256);

    function addChallenge(address challengeContract) external returns (address);
}
