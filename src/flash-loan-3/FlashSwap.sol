// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity 0.8.20;

import "../interfaces/IPair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {console} from "forge-std/Test.sol";

/**
 * @title FlashSwap
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract FlashSwap {
    IPair immutable pair;
    address token;

    constructor(address _pair) {
        pair = IPair(_pair);
    }

    // TODO: Implement this function
    function executeFlashSwap(address _token, uint256 _amount) external {
        token = _token;
        console.log(
            "Contract balance before flash loan",
            IERC20(_token).balanceOf(address(this))
        );

        if (pair.token0() == _token) {
            pair.swap(_amount, 0, address(this), "0xSAG");
        } else if (pair.token1() == _token) {
            pair.swap(0, _amount, address(this), "0xSAG");
        } else {
            revert("Token not found");
        }
    }

    // TODO: Implement this function
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external {
        if (msg.sender != address(pair)) revert("You no be caller");
        if (sender != address(this)) revert("Omo you no be sender");

        console.log(
            "Contract balance after flash loan",
            IERC20(token).balanceOf(address(this))
        );

        uint256 fee;
        uint256 owned;
        if (pair.token0() == token) {
            fee = (amount0 * 3) / 100 + 1;
            owned = amount0 + fee;
            IERC20(token).transfer(address(pair), owned);
        } else if (pair.token1() == token) {
            owned = amount1 + fee;
            IERC20(token).transfer(address(pair), owned);
        }

        console.log("Fee", fee);
        console.log("owned", owned);
        console.log(
            "Contract balance after flash loan",
            IERC20(token).balanceOf(address(this))
        );
    }
}
