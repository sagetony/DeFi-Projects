// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/flash-loan-3/FlashSwap.sol";

/**
@dev run "forge test --fork-url $ETH_RPC_URL --fork-block-number 15969633 --match-contract FL3 -vvvvv" 
*/
contract TestFL3 is Test {
    // Should have $4.745M USDC on mainnet block 15969633
    // https://etherscan.io/address/0x8e5dedeaeb2ec54d0508973a0fccd1754586974a
    address constant IMPERSONATED_ACCOUNT_ADDRESS =
        address(0x8e5dEdeAEb2EC54d0508973a0Fccd1754586974A);
    address constant USDC_ADDRESS =
        address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant WETH_USDC_PAIR =
        address(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);
    // $40M USDC
    uint256 BORROW_AMOUNT = 40000000e6;
    // Uniswap V2 fee is 0.3% which is $1.2M USDC
    uint256 FEE_AMOUNT = ((BORROW_AMOUNT * 3) / 100) + 1;

    FlashSwap flashSwap;
    IERC20 usdc;

    function setUp() public {
        vm.label(USDC_ADDRESS, "USDC");
        vm.label(WETH_USDC_PAIR, "WethUsdcPair");

        // TODO: Get contract objects for relevant On-Chain contracts
        usdc = IERC20(USDC_ADDRESS);

        // TODO: Deploy FlashSwap contract
        vm.prank(IMPERSONATED_ACCOUNT_ADDRESS);
        flashSwap = new FlashSwap(WETH_USDC_PAIR);
    }

    function test_Attack() public {
        // TODO: Send USDC to contract for fees
        vm.prank(IMPERSONATED_ACCOUNT_ADDRESS);
        usdc.transfer(address(flashSwap), FEE_AMOUNT);

        // TODO: Execute successfully a Flash Swap of $40,000,000 (USDC)
        flashSwap.executeFlashSwap(address(usdc), BORROW_AMOUNT);
    }
}
