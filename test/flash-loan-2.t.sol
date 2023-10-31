// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/flash-loan-2/FlashLoan.sol";

/**
@dev run "forge test --fork-url $ETH_RPC_URL --fork-block-number 15969633 --match-test test_Attack -vvvvv" 
*/
contract TestFL2 is Test {
    // Should have $4.745M USDC on mainnet block 15969633
    // https://etherscan.io/address/0x8e5dedeaeb2ec54d0508973a0fccd1754586974a
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

    function setUp() public {
        vm.label(USDC_ADDRESS, "USDC");
        vm.label(AAVE_LENDING_POOL_ADDRESS, "AaveLendingPool");

        // TODO: Get contract objects for relevant On-Chain contracts
        usdc = IERC20(USDC_ADDRESS);

        // TODO: Deploy Flash Loan contract
        vm.prank(IMPERSONATED_ACCOUNT_ADDRESS);
        flashLoan = new FlashLoan(AAVE_LENDING_POOL_ADDRESS);
    }

    function test_Loan() public {
        // TODO: Send USDC to contract for fees
        vm.prank(IMPERSONATED_ACCOUNT_ADDRESS);
        usdc.transfer(address(flashLoan), FEE_AMOUNT);

        // TODO: Execute successfully a Flash Loan of $100,000,000 (USDC)
        flashLoan.getFlashLoan(address(usdc), BORROW_AMOUNT);
    }
}
