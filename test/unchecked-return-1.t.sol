// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {console, Test} from "forge-std/Test.sol";
import {DonationMaster} from "../src/unchecked-return-1/DonationMaster.sol";
import {MultiSigSafe} from "../src/unchecked-return-1/MultiSigSafe.sol";

contract TestDonationMaster is Test {
    DonationMaster donationmaster;
    MultiSigSafe multisifsage;

    address owner;
    address user1;
    address user2;
    address signer1;
    address signer2;
    address signer3;

    function setUp() external {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        signer1 = makeAddr("signer1");
        signer2 = makeAddr("signer2");
        signer3 = makeAddr("signer3");

        vm.deal(user1, 10 ether);
        vm.deal(user2, 20 ether);

        address[] memory signers = new address[](3);

        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;

        donationmaster = new DonationMaster();
        multisifsage = new MultiSigSafe(signers, 2);
    }

    function test_donation() external {
        donationmaster.newDonation(address(multisifsage), 30 ether);
        vm.prank(user1);
        donationmaster.donate{value: 5 ether}(1);
        vm.prank(user2);
        donationmaster.donate{value: 10 ether}(1);

        console.log(address(multisifsage).balance);
    }
}
