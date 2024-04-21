// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Challenge} from "../../src/protocol/Challenge.sol";
import {SimpleCTFChallenge} from "../mocks/SimpleCTFChallenge.sol";
import {SimpleCTFRegistry} from "../mocks/SimpleCTFRegistry.sol";
import {Test, console2} from "forge-std/Test.sol";

contract SimpleCTFChallengeTest is Test {
    SimpleCTFChallenge challengeOne;
    SimpleCTFChallenge challengeTwo;
    SimpleCTFRegistry registry;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        registry = new SimpleCTFRegistry();
        challengeOne = new SimpleCTFChallenge(address(registry));
        challengeTwo = new SimpleCTFChallenge(address(registry));
        registry.addChallenge(address(challengeOne));
        registry.addChallenge(address(challengeTwo));
        vm.stopPrank();
    }

    function testRevertDeploymentOnAddressZeroRegistry() public {
        vm.expectRevert(Challenge.Challenge__CantBeZeroAddress.selector);
        new SimpleCTFChallenge(address(0));
    }

    function testSolveChallengeMintsNFT() public {
        vm.startPrank(user);
        challengeOne.solveChallenge();
        vm.stopPrank();
        assertEq(registry.balanceOf(user), 1);
    }

    function testSolveMultipleChallenges() public {
        vm.startPrank(user);
        challengeOne.solveChallenge();
        challengeTwo.solveChallenge();
        vm.stopPrank();
        assertEq(registry.balanceOf(user), 2);
    }

    function testAdminMintSolvers() public {
        vm.startPrank(owner);
        address[] memory solvers = new address[](2);
        solvers[0] = makeAddr("solver1");
        solvers[1] = makeAddr("solver2");
        challengeOne.adminMintSolvers(solvers);
        vm.stopPrank();
        assertEq(registry.balanceOf(solvers[0]), 1);
        assertEq(registry.balanceOf(solvers[1]), 1);
    }
}
