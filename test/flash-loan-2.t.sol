// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console, Test} from "forge-std/Test.sol";
import {FlashLoan} from "../src/flash-loan-2/FlashLoan.sol";

contract TestFL2 is Test {
    address constant IMPERSONATED_ACCOUNT_ADDRESS =
        address(0x8e5dEdeAEb2EC54d0508973a0Fccd1754586974A);
    address constant USDC_ADDRESS =
        address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant AAVE_LENDING_POOL_ADDRESS =
        address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    // $100M USDC
    uint256 BORROW_AMOUNT = 100000000e6;
    // AAVE flash loan fee is 0.09% --> $90K USDC
    uint256 FEE_AMOUNT = 90000e6;

    FlashLoan flashLoan;
    IERC20 usdc;

    function setUp() external {
        vm.label(USDC_ADDRESS, "USDC");
        vm.label(AAVE_LENDING_POOL_ADDRESS, "AaveLendingPool");

        vm.startPrank(IMPERSONATED_ACCOUNT_ADDRESS);
        flashLoan = new FlashLoan(AAVE_LENDING_POOL_ADDRESS);
        usdc = IERC20(USDC_ADDRESS);
        usdc.transfer(address(flashLoan), FEE_AMOUNT);
        console.log(usdc.balanceOf(address(flashLoan)));
        vm.stopPrank();
    }

    function test_Loan() external {
        vm.prank(IMPERSONATED_ACCOUNT_ADDRESS);
        flashLoan.getFlashLoan(address(usdc), BORROW_AMOUNT);
        vm.stopPrank();
    }
}
