// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "src/money-markets-1/AaveUser.sol";

/**
@dev run "forge test --fork-url $ETH_RPC_URL --fork-block-number 16776127 --match-contract MM1 -vvv" 
*/
contract TestMM1 is Test {
    address constant AAVE_POOL =
        address(0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2);
    address constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant WHALE =
        address(0xF977814e90dA44bFA03b6295A0616a897441aceC);
    address constant AUSDC =
        address(0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c); // AAVE USDC Receipt Token
    address constant VARIABLE_DEBT_DAI =
        address(0xcF8d0c70c850859266f5C338b38F9D663181C314); // AAVE DAI Variable Debt Token

    uint128 constant USER_USDC_BALANCE = 100000e6;
    uint128 constant AMOUNT_TO_DEPOSIT = 10000e6;
    uint128 constant AMOUNT_TO_BORROW = 100 ether;

    address user = makeAddr("user");

    AaveUser aaveUser;
    IERC20 usdc;
    IERC20 dai;
    IERC20 aUSDC;
    IERC20 debtDAI;

    function setUp() public {
        vm.label(AAVE_POOL, "AavePool");
        vm.label(USDC, "USDC");
        vm.label(DAI, "DAI");
        vm.label(AUSDC, "aUSDC");
        vm.label(VARIABLE_DEBT_DAI, "DebtDAI");

        // Load tokens
        usdc = IERC20(USDC);
        dai = IERC20(DAI);
        aUSDC = IERC20(AUSDC);
        debtDAI = IERC20(VARIABLE_DEBT_DAI);

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

    function test_StudentTests() public {
        /** CODE YOUR SOLUTION HERE */
        // TODO: Deploy AaveUser contract
        vm.startPrank(user);

        aaveUser = new AaveUser(
            0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2,
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            0x6B175474E89094C44Da98b954EedeAC495271d0F
        );
        // TODO: Appove and deposit 1000 USDC tokens
        usdc.approve(address(aaveUser), USER_USDC_BALANCE);
        aaveUser.depositUSDC(USER_USDC_BALANCE);

        // TODO: Validate that the depositedAmount state var was changed
        assertGt(aaveUser.depositedamount(user), 0);

        // // TODO: Validate that your contract received the aUSDC tokens (receipt tokens)
        assertGt(aUSDC.balanceOf(address(aaveUser)), 0);
        // // TODO: borrow 100 DAI tokens
        aaveUser.borrowDAI(AMOUNT_TO_BORROW);
        // // TODO: Validate that the borrowedAmount state var was changed
        assertEq(aaveUser.borrowedAmount(user), AMOUNT_TO_BORROW);
        // // TODO: Validate that the user received the DAI Tokens
        assertEq(dai.balanceOf(user), AMOUNT_TO_BORROW);
        // // TODO: Validate that your contract received the DAI variable debt tokens
        assertEq(debtDAI.balanceOf(address(aaveUser)), AMOUNT_TO_BORROW);

        // // // TODO: Repay all the DAI
        dai.approve(address(aaveUser), AMOUNT_TO_BORROW);
        aaveUser.repayDAI(AMOUNT_TO_BORROW);
        // // TODO: Validate that the borrowedAmount state var was changed

        assertEq(aaveUser.borrowedAmount(user), 0);
        // // TODO: Validate that the user doesn't own the DAI tokens
        assertEq(dai.balanceOf(user), 0);
        // // TODO: Validate that your contract own much less DAI Variable debt tokens (less then 0.1% of borrowed amount)
        // // Note: The contract still supposed to own some becuase of negative interest
        assertEq(
            debtDAI.balanceOf(address(aaveUser)) < AMOUNT_TO_BORROW / 100,
            true
        );
        // TODO: Withdraw all your USDC
        aaveUser.withdrawUSDC(AMOUNT_TO_DEPOSIT);
        // TODO: Validate that the depositedAmount state var was changed
        assertEq(aaveUser.depositedamount(user), 0);
        // TODO: Validate that the user got the USDC tokens back
        usdc.balanceOf(user);
        // // TODO: Validate that your contract own much less aUSDC receipt tokens (less then 0.1% of deposited amount)
        // Note: The contract still supposed to own some becuase of the positive interest
        vm.stopPrank();
    }
}
