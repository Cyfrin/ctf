// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Challenge} from "../../src/protocol/Challenge.sol";
import {SimpleCTFChallenge} from "../mocks/SimpleCTFChallenge.sol";
import {SimpleCTFRegistry} from "../mocks/SimpleCTFRegistry.sol";
import {Test, console2} from "forge-std/Test.sol";

contract SimpleCTFChallengeTest is Test {
    SimpleCTFChallenge challenge;
    SimpleCTFRegistry registry;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        registry = new SimpleCTFRegistry();
        challenge = new SimpleCTFChallenge(address(registry));
        registry.addChallenge(address(challenge));
        vm.stopPrank();
    }

    function testSolveChallengeMintsNFT() public {
        vm.startPrank(user);
        challenge.solveChallenge();
        vm.stopPrank();
        assertEq(registry.balanceOf(user), 1);
    }
}
