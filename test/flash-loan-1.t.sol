// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {console, Test} from "forge-std/Test.sol";

import {GreedyReceiver} from "../src/flash-loan-1/GreedyReceiver.sol";
import {Pool} from "../src/flash-loan-1/Pool.sol";
import {Receiver} from "../src/flash-loan-1/Receiver.sol";

contract TestFL is Test {
    uint256 private constant CONTRACT_FUNDS = 100 ether;
    uint256 private constant LOAN_AMOUNT = 50 ether;
    GreedyReceiver greedyReceiver;
    Pool pool;
    Receiver receiver;

    address private deployer;
    address private greedyUser;
    address private user;

    function setUp() external {
        deployer = makeAddr("deployer");
        greedyUser = makeAddr("greedyUser");
        user = makeAddr("user");

        vm.deal(deployer, CONTRACT_FUNDS);

        vm.startPrank(deployer);
        pool = new Pool{value: CONTRACT_FUNDS}();
        assertEq(address(pool).balance, CONTRACT_FUNDS);
        vm.stopPrank();
    }

    function test_loan() external {
        console.log("time", block.timestamp);

        // vm.startPrank(user);

        // receiver = new Receiver(address(pool));
        // receiver.flashLoan(LOAN_AMOUNT);
        // assertEq(address(pool).balance, CONTRACT_FUNDS);

        // vm.stopPrank();

        // vm.startPrank(greedyUser);
        // greedyReceiver = new GreedyReceiver(address(pool));
        // greedyReceiver.flashLoan(LOAN_AMOUNT);
        // vm.stopPrank();
    }
}
