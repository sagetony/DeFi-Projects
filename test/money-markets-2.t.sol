// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../src/money-markets-2/CompoundUser.sol";

/**
@dev run "forge test --fork-url $ETH_RPC_URL --fork-block-number 16776127 --match-contract MM2 -vvv" 
*/
contract TestMM2 is Test {
    address constant COMPOUND_COMPTROLLER =
        address(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    address constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant WHALE =
        address(0xF977814e90dA44bFA03b6295A0616a897441aceC);
    address constant C_USDC =
        address(0x39AA39c021dfbaE8faC545936693aC917d5E7563); // AAVE USDC Receipt Token
    address constant C_DAI =
        address(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643); // AAVE DAI Variable Debt Token

    uint128 constant USER_USDC_BALANCE = 100000e6;
    uint128 constant AMOUNT_TO_DEPOSIT = 10000e6;
    uint128 constant AMOUNT_TO_BORROW = 100 ether;

    uint256 public cUSDCBalanceBefore;

    address user = makeAddr("user");

    CompoundUser compUser;
    IERC20 usdc;
    IERC20 dai;
    IERC20 cUsdc;
    IERC20 cDai;

    function setUp() public {
        vm.label(USDC, "USDC");
        vm.label(DAI, "DAI");
        vm.label(C_USDC, "cUSDC");
        vm.label(C_DAI, "cDAI");

        // Load tokens
        usdc = IERC20(USDC);
        dai = IERC20(DAI);
        cUsdc = IERC20(C_USDC);
        cDai = IERC20(C_DAI);

        // Set user & whale balance to 2 ETH
        vm.deal(user, 2 ether);
        vm.deal(WHALE, 2 ether);

        // Transfer USDC to the user
        vm.prank(WHALE);
        usdc.transfer(user, USER_USDC_BALANCE);

        // Burn DAI balance form the user
        vm.prank(user);
        dai.transfer(
            address(0x000000000000000000000000000000000000dEaD),
            dai.balanceOf(user)
        );
    }

    function test_StudentMMTests() public {
        /** CODE YOUR SOLUTION HERE */
        vm.startPrank(user);
        // TODO: Deploy AaveUser contract
        compUser = new CompoundUser(COMPOUND_COMPTROLLER, C_USDC, C_DAI);
        // TODO: Appove and deposit 1000 USDC tokens
        usdc.approve(address(compUser), USER_USDC_BALANCE);

        compUser.deposit(AMOUNT_TO_DEPOSIT);

        // TODO: Validate that the depositedAmount state var was changed
        assertEq(compUser.depositedAmount(), AMOUNT_TO_DEPOSIT);
        // TODO: Store the cUSDC tokens that were minted to the compoundUser contract in `cUSDCBalanceBefore`
        cUSDCBalanceBefore = cUsdc.balanceOf(address(compUser));
        // TODO: Validate that your contract received cUSDC tokens (receipt tokens)
        assertEq(cUSDCBalanceBefore > AMOUNT_TO_DEPOSIT, true);

        // TODO: Allow USDC as collateral
        compUser.allowUSDCAsCollateral();
        // TODO: borrow 100 DAI tokens
        compUser.borrow(AMOUNT_TO_BORROW);
        // TODO: Validate that the borrowedAmount state var was changed
        assertEq(compUser.borrowedAmount(), AMOUNT_TO_BORROW);
        // TODO: Validate that the user received the DAI Tokens
        assertEq(dai.balanceOf(user), AMOUNT_TO_BORROW);

        // TODO: Repay all the borrowed DAI
        dai.approve(address(compUser), AMOUNT_TO_BORROW);
        compUser.repay(AMOUNT_TO_BORROW);
        // TODO: Validate that the borrowedAmount state var was changed
        assertEq(compUser.borrowedAmount(), 0);
        // TODO: Validate that the user doesn't own the DAI tokens
        assertEq(dai.balanceOf(user), 0);
        // TODO: Withdraw all your USDC
        compUser.withdraw(AMOUNT_TO_DEPOSIT);
        // // TODO: Validate that the depositedAmount state var was changed
        assertEq(compUser.depositedAmount(), 0);
        // TODO: Validate that the user got the USDC tokens back
        assertGt(usdc.balanceOf(user), AMOUNT_TO_DEPOSIT);
        // TODO: Validate that the majority of the cUSDC tokens (99.9%) were burned, and the contract doesn't own them
        assertEq(
            cUsdc.balanceOf(address(compUser)) < cUSDCBalanceBefore / 100,
            true
        );
        // NOTE: There are still some cUSDC tokens left, since we accumelated positive interest
        vm.stopPrank();
    }
}
