// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {console, Test} from "forge-std/Test.sol";

import {Auction} from "../src/dos-2/Auction.sol";
import {AttackAuction} from "../src/dos-2/AttackAuction.sol";

contract TestAuction is Test {
    Auction auction;
    AttackAuction attackauction;

    address user1 = makeAddr("user1");
    address deployer = makeAddr("deployer");

    function setUp() external {
        vm.deal(deployer, 10 ether);
        vm.deal(user1, 10 ether);
        vm.deal(address(attackauction), 10 ether);

        auction = new Auction();
    }

    function test_attackauction() external {
        attackauction = new AttackAuction{value: 5 ether}(address(auction));
        assertEq(auction.currentLeader(), address(attackauction));

        auction.bid{value: 6 ether}();
    }
}
