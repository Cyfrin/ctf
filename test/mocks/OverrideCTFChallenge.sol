// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Challenge} from "../../src/protocol/Challenge.sol";

contract OverrideCTFChallenge is Challenge {
    error OverrideCTFChallenge__AlreadyMinted();

    string constant BLANK_TWITTER_HANDLE = "";
    string constant BLANK_IMAGE_URI = "";
    string constant ATTRIBUTE = "Getting learned!";
    string constant DESCRIPTION = "This is a simple CTF challenge.";

    bool s_minted;

    constructor(address registry) Challenge(registry, ATTRIBUTE, DESCRIPTION, BLANK_IMAGE_URI) {
        s_minted = false;
    }

    function _updateAndRewardSolver(string memory twitterHandleOfSolver) internal override {
        if (s_minted) {
            revert OverrideCTFChallenge__AlreadyMinted();
        }
        super._updateAndRewardSolver(twitterHandleOfSolver);
        s_minted = true;
    }

    function solveChallenge() external {
        _updateAndRewardSolver(BLANK_TWITTER_HANDLE);
    }

    // Add this so forge coverage thinks this is a test and should skip
    function test() public {}
}
