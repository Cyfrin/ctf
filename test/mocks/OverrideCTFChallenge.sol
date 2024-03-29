// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Challenge} from "../../src/protocol/Challenge.sol";

contract OverrideCTFChallenge is Challenge {
    error OverrideCTFChallenge__AlreadyMinted();

    string constant BLANK_TWITTER_HANDLE = "";

    bool s_minted;

    constructor(address registry) Challenge(registry) {
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

    function attribute() external pure override returns (string memory) {
        return "Getting learned!";
    }

    function description() external pure override returns (string memory) {
        return "This is a simple CTF challenge.";
    }

    function specialImage() external pure returns (string memory) {
        return BLANK_TWITTER_HANDLE;
    }
}
