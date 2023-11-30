// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {console, Test} from "forge-std/Test.sol";
import {RainbowAllianceToken} from "../src/dao-attack-1/RainbowAllianceToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestRainbowAllienceToken is Test {
    uint256 constant DEPLOYER_MINT = 1000;
    uint256 constant USERS_MINT = 100;
    uint256 constant USER2_BURN = 30;

    RainbowAllianceToken rainbowalliancetoken;

    address userOne = makeAddr("userOne");
    address userTwo = makeAddr("userTwo");
    address userThree = makeAddr("userThree");
    address deployer = makeAddr("deployer");
    address attackerOne = makeAddr("attackerOne");
    address attackerTwo = makeAddr("attackerTwo");

    function setUp() external {
        rainbowalliancetoken = new RainbowAllianceToken();
        rainbowalliancetoken.mint(address(this), DEPLOYER_MINT);

        rainbowalliancetoken.mint(userOne, USERS_MINT);

        rainbowalliancetoken.mint(userTwo, USERS_MINT);
        rainbowalliancetoken.burn(userTwo, USER2_BURN);

        rainbowalliancetoken.mint(attackerOne, USERS_MINT);
    }

    function test_governance() external {
        // Can't create proposals, if there is no voting power
        vm.expectRevert("no voting rights");
        vm.prank(userThree);
        rainbowalliancetoken.createProposal("Donate 1000$ to charities");

        // // Should be able to create proposals if you have voting power
        rainbowalliancetoken.createProposal(
            "Pay 100$ to george for a new Logo"
        );
        // // Can't vote twice
        vm.expectRevert("already voted");
        rainbowalliancetoken.vote(1, true);

        // // Shouldn't be able to vote without voting rights
        vm.expectRevert("no voting rights");
        vm.prank(userThree);
        rainbowalliancetoken.vote(1, true);

        // // Non existing proposal, reverts
        vm.expectRevert("proposal doesn't exist");
        rainbowalliancetoken.vote(123, false);
        // // Users votes
        vm.prank(userOne);
        rainbowalliancetoken.vote(1, true);

        vm.prank(userTwo);
        rainbowalliancetoken.vote(1, true);

        // console.log(rainbowalliancetoken.getProposal(1));
        // // Supposed to be 1,100 (User1 - 100, deployer - 1,000)
        (, , uint yes, uint no) = rainbowalliancetoken.getProposal(1);
        uint256 deployerVotePower = rainbowalliancetoken.getVotingPower(
            address(this)
        );
        uint256 userOneVotePower = rainbowalliancetoken.getVotingPower(userOne);
        uint256 userTwoVotePower = rainbowalliancetoken.getVotingPower(userTwo);

        assertEq(yes, deployerVotePower + userOneVotePower + userTwoVotePower);
        // Supposed to be 70 (100 - 30, becuase we burned 30 tokens of user2)
        assertEq(no, 0);

        // Attack
        vm.startPrank(attackerOne);
        ERC20(rainbowalliancetoken).transfer(attackerTwo, USERS_MINT);
        rainbowalliancetoken.vote(1, true);
        vm.stopPrank();
    }
}
