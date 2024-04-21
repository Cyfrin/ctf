// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Challenge} from "../../src/protocol/Challenge.sol";

contract SimpleCTFChallenge is Challenge {
    string constant IMAGE_URI = "ipfs://QmZg79jdDNBTi3fxwnjXTvbM9Gtd1C84Axo55Ht2kYCeDH";
    string constant BLANK_TWITTER_HANDLE = "";
    string constant ATTRIBUTE = "Getting learned!";
    string constant DESCRIPTION = "This is a simple CTF challenge.";

    constructor(address registry) Challenge(registry, ATTRIBUTE, DESCRIPTION, IMAGE_URI) {}

    function solveChallenge() external {
        _updateAndRewardSolver(BLANK_TWITTER_HANDLE);
    }

    // Add this so forge coverage thinks this is a test and should skip
    function test() public {}
}
