// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {OverrideCTFChallenge} from "../mocks/OverrideCTFChallenge.sol";
import {SimpleCTFRegistry} from "../mocks/SimpleCTFRegistry.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Test, console2} from "forge-std/Test.sol";

contract OverrideCTFChallengeTest is Test {
    OverrideCTFChallenge challenge;
    SimpleCTFRegistry registry;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

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

    function testCanOnlyMintOnceWithOverride(address rando) public {
        vm.prank(user);
        challenge.solveChallenge();

        vm.prank(rando);
        vm.expectRevert(OverrideCTFChallenge.OverrideCTFChallenge__AlreadyMinted.selector);
        challenge.solveChallenge();
    }

    function testOwnerCanChangeAttribute() public {
        vm.prank(owner);
        challenge.changeAttribute("new attribute");
        assertEq(challenge.attribute(), "new attribute");
    }

    function testNonOwnerCannotChangeAttribute(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.prank(randomAddress);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, randomAddress));
        challenge.changeAttribute("new attribute");
    }

    function testChangeDescrpition(string memory newDescription) public {
        vm.prank(owner);
        challenge.changeDescription(newDescription);
        assertEq(challenge.description(), newDescription);
    }
}
