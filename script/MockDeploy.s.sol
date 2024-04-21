// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {SimpleCTFChallenge} from "../test/mocks/SimpleCTFChallenge.sol";

import {SimpleCTFRegistry} from "../test/mocks/SimpleCTFRegistry.sol";

contract MockDeploy is Script {
    function run() external {
        SimpleCTFRegistry registry = new SimpleCTFRegistry();
        SimpleCTFChallenge challenge = new SimpleCTFChallenge(address(registry));
        registry.addChallenge(address(challenge));
    }

    // Add this so forge coverage thinks this is a test and should skip
    function test() public {}
}
