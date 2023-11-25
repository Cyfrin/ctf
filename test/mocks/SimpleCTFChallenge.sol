// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Challenge} from "../../src/protocol/Challenge.sol";

contract SimpleCTFChallenge is Challenge {
    string constant BLANK_TWITTER_HANDLE = "";

    constructor(address registry) Challenge(registry) {}

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
