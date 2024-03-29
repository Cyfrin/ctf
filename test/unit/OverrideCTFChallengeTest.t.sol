// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {OverrideCTFChallenge} from "../mocks/OverrideCTFChallenge.sol";
import {SimpleCTFRegistry} from "../mocks/SimpleCTFRegistry.sol";
import {Test, console2} from "forge-std/Test.sol";

contract OverrideCTFChallengeTest is Test {
    OverrideCTFChallenge challenge;
    SimpleCTFRegistry registry;

    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address rando = makeAddr("rando");

    function setUp() public {
        vm.startPrank(owner);
        registry = new SimpleCTFRegistry();
        challenge = new OverrideCTFChallenge(address(registry));
        registry.addChallenge(address(challenge));
        vm.stopPrank();
    }

    function testCanMintOnce() public {
        vm.prank(user);
        challenge.solveChallenge();
        assertEq(registry.balanceOf(user), 1);
    }

    function testCanOnlyMintOnceWithOverride() public {
        vm.prank(user);
        challenge.solveChallenge();

        vm.prank(rando);
        vm.expectRevert(OverrideCTFChallenge.OverrideCTFChallenge__AlreadyMinted.selector);
        challenge.solveChallenge();
    }
}
