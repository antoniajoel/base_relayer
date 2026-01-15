// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {RelayerHub} from "../RelayerHub.sol";

contract RelayerHubTest is Test {
    RelayerHub public hub;
    address public owner = address(0x1);
    address public sponsor = address(0x2);
    address public user = address(0x3);
    address public contractAddr = address(0x4);

    function setUp() public {
        vm.prank(owner);
        hub = new RelayerHub();
    }

    function testAddSponsor() public {
        vm.prank(owner);
        hub.addSponsor(sponsor, 100);

        RelayerHub.Sponsor memory sponsorData = hub.getSponsor(sponsor);
        assertTrue(sponsorData.active);
        assertEq(sponsorData.dailyLimit, 100);
        assertEq(sponsorData.dailyUsed, 0);
    }

    function testRemoveSponsor() public {
        vm.prank(owner);
        hub.addSponsor(sponsor, 100);

        vm.prank(owner);
        hub.removeSponsor(sponsor);

        RelayerHub.Sponsor memory sponsorData = hub.getSponsor(sponsor);
        assertFalse(sponsorData.active);
    }

    function testCanRelay() public {
        vm.prank(owner);
        hub.addSponsor(sponsor, 100);

        bool canRelay = hub.canRelay(sponsor, user, contractAddr);
        assertTrue(canRelay);
    }

    function testCannotRelayInvalidSponsor() public {
        bool canRelay = hub.canRelay(sponsor, user, contractAddr);
        assertFalse(canRelay);
    }

    function testRecordRelay() public {
        vm.prank(owner);
        hub.addSponsor(sponsor, 100);

        hub.recordRelay(sponsor, user, 50000);

        RelayerHub.Sponsor memory sponsorData = hub.getSponsor(sponsor);
        assertEq(sponsorData.dailyUsed, 1);

        RelayerHub.Usage memory usage = hub.getUserUsage(user);
        assertEq(usage.count, 1);
    }

    function testDailyLimit() public {
        vm.prank(owner);
        hub.addSponsor(sponsor, 2); // Limit of 2

        hub.recordRelay(sponsor, user, 50000);
        hub.recordRelay(sponsor, user, 50000);

        bool canRelay = hub.canRelay(sponsor, user, contractAddr);
        assertFalse(canRelay); // Should hit limit
    }

    function testAllowlistContract() public {
        vm.prank(owner);
        hub.allowlistContract(contractAddr);

        assertTrue(hub.allowlistedContracts(contractAddr));
    }
}

