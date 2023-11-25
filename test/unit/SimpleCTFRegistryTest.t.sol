// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Challenge} from "../../src/protocol/Challenge.sol";
import {SimpleCTFChallenge} from "../mocks/SimpleCTFChallenge.sol";
import {SimpleCTFRegistry} from "../mocks/SimpleCTFRegistry.sol";
import {ICTFRegistry} from "../../src/interfaces/ICTFRegistry.sol";
import {Test, console2} from "forge-std/Test.sol";

contract SimpleCTFRegistryTest is Test {
    SimpleCTFChallenge challenge;
    SimpleCTFRegistry registry;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    // Annoying that I need to have the events twice in foundry...
    event ChallengeAdded(address challengeContract);
    event ChallengeReplaced(address oldChallenge, address newChallenge);
    event BaseTokenImageUriChanged(string newUri);
    event ChallengeSolved(address solver, address challenge, string twitterHandle);

    function setUp() public {
        vm.startPrank(owner);
        registry = new SimpleCTFRegistry();
        challenge = new SimpleCTFChallenge(address(registry));
        vm.stopPrank();
    }

    function testAddChallengeAddsChallenges() public {
        // Arrange
        vm.startPrank(owner);
        assert(registry.isChallengeContract(address(challenge)) == false);
        // Act / Assert
        vm.expectEmit(true, false, false, true, address(registry));
        emit ChallengeAdded(address(challenge));
        registry.addChallenge(address(challenge));
        vm.stopPrank();

        // Assert
        assert(registry.isChallengeContract(address(challenge)) == true);
    }

    function testReplaceChallengeWorks() public {
        // Arrange
        vm.prank(owner);
        registry.addChallenge(address(challenge));

        assert(registry.isChallengeContract(address(challenge)) == true);
        SimpleCTFChallenge newchallenge = new SimpleCTFChallenge(address(registry));

        // Act / Assert
        vm.prank(owner);
        vm.expectEmit(true, false, false, true, address(registry));
        emit ChallengeReplaced(address(challenge), address(newchallenge));
        registry.replaceChallenge(0, address(newchallenge));

        // Assert
        assert(registry.isChallengeContract(address(challenge)) == false);
        assert(registry.isChallengeContract(address(newchallenge)) == true);
    }

    function testReplaceChallengeOnlyOwner(address randomPerson) public {
        // Arrange
        vm.assume(randomPerson != owner);
        vm.prank(randomPerson);
        vm.expectRevert();
        registry.addChallenge(address(challenge));
    }

    function testMintNft() public {
        // Arrange
        vm.prank(owner);
        registry.addChallenge(address(challenge));

        // Act
        vm.startPrank(user);
        challenge.solveChallenge();
        vm.stopPrank();

        // Assert
        assertEq(registry.balanceOf(user), 1);
    }

    function testuserCanOnlyMintOnce() public {
        // Arrange
        vm.prank(owner);
        registry.addChallenge(address(challenge));

        // Act
        vm.startPrank(user);
        challenge.solveChallenge();
        vm.stopPrank();

        // Assert
        vm.startPrank(user);
        // cast sig "CTFRegistry__YouAlreadySolvedThis()"
        // vm.expectRevert(0x5ac85896);
        vm.expectRevert(ICTFRegistry.CTFRegistry__YouAlreadySolvedThis.selector);
        challenge.solveChallenge();
        vm.stopPrank();
    }

    function testGetTokenUri() public {
        // Arrange
        uint256 tokenId = 0;
        string memory EXPECTED_TOKEN_URI =
            "data:application/json;base64,eyJuYW1lIjoiT3VyIENURiIsICJkZXNjcmlwdGlvbiI6ICJUaGlzIGlzIGEgc2ltcGxlIENURiBjaGFsbGVuZ2UuIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIkdldHRpbmcgbGVhcm5lZCEiLCAidmFsdWUiOiAxMDB9XSwgImltYWdlIjoiaXBmczovL1FtWmc3OWpkRE5CVGkzZnh3bmpYVHZiTTlHdGQxQzg0QXhvNTVIdDJrWUNlREgifQ==";
        vm.prank(owner);
        registry.addChallenge(address(challenge));

        // Act
        vm.startPrank(user);
        challenge.solveChallenge();
        vm.stopPrank();

        // Act / Assert
        assertEq(registry.tokenURI(tokenId), EXPECTED_TOKEN_URI);
    }

    fallback() external payable {}

    receive() external payable {}
}
