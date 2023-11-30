// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {console, Test} from "forge-std/Test.sol";
import {FindMe} from "../src/frontrunning-1/FindMe.sol";

contract TestFrontrunning is Test {
    FindMe findme;

    address userOne = makeAddr("userOne");
    address attacker = makeAddr("attacker");

    function setUp() external {
        vm.deal(userOne, 10 ether);
        vm.deal(attacker, 10 ether);

        findme = new FindMe{value: 10 ether}();

        console.log("Before", userOne.balance);
        string memory name = "Ethereum";
        vm.prank(userOne);
        findme.claim(name);
        console.log("After", userOne.balance);
    }

    function test_findMe() external {}
}
