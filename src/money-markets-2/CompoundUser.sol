// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity 0.8.20;

import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./CompoundInterfaces.sol";

contract CompoundUser is Ownable {
    IComptroller private comptroller;

    IERC20 private immutable usdc;
    IERC20 private immutable dai;

    cERC20 private immutable cUsdc;
    cERC20 private immutable cDai;

    uint256 public depositedAmount; // In USDC
    uint256 public borrowedAmount; // In DAI

    // Errors
    error CompoundUser_ZeroAmount();
    error CompoundUser_InsufficientAmount();

    // TODO: Implement the constructor
    constructor(
        address _comptroller,
        address _cUsdc,
        address _cDai
    ) Ownable(msg.sender) {
        // TODO: Set the comptroller, cUsdc, and cDai contracts
        comptroller = IComptroller(_comptroller);
        cUsdc = cERC20(_cUsdc);
        cDai = cERC20(_cDai);

        // TODO: Set the usdc, and dai contract (retrieve from cToken contracts)
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    // Deposit USDC to Compound
    function deposit(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        if (_amount == 0) revert CompoundUser_ZeroAmount();
        // // TODO: Update depositedAmount state var
        depositedAmount += _amount;
        // // TODO: Transfer the USDC from the user to this smart contract
        usdc.transferFrom(msg.sender, address(this), _amount);
        // // TODO: Approve the cUsdc contract to spend our USDC tokens
        usdc.approve(address(cUsdc), _amount);
        // // TODO: Deposit USDC tokens (mint cUSDC tokens)
        cUsdc.mint(_amount);
    }

    // Allow the deposited USDC to be used as collateral, interact with the Comptroller contract
    function allowUSDCAsCollateral() external onlyOwner {
        // TODO: Implement this function
        // TODO: Use the comptroller `enterMarkets` function to set the usdc as collateral
        address[] memory tokenAddress = new address[](1);
        tokenAddress[0] = address(cUsdc);
        comptroller.enterMarkets(tokenAddress);
    }

    // Withdraw deposited USDC from Compound
    function withdraw(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        if (_amount == 0) revert CompoundUser_ZeroAmount();
        // TODO: Revert if the user is trying to withdraw more than he deposited
        if (_amount > depositedAmount) revert CompoundUser_InsufficientAmount();
        // TODO: Update depositedAmount amount state var
        depositedAmount -= _amount;
        // TODO: Withdraw the USDC tokens
        cUsdc.redeemUnderlying(_amount);
        // TODO: Transfer USDC token to the user
        usdc.transfer(msg.sender, _amount);
    }

    // Borrow DAI from Compound
    function borrow(uint256 _amount) external {
        // TODO: Implement this function
        if (_amount == 0) revert CompoundUser_ZeroAmount();
        // TODO: Update borrowedAmount state var
        borrowedAmount += _amount;
        // TODO: Borrow DAI
        cDai.borrow(_amount);
        // TODO: Send DAI to the user
        dai.transfer(msg.sender, _amount);
    }

    // Repay the borrowed DAI
    function repay(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        if (_amount == 0) revert CompoundUser_ZeroAmount();
        // TODO: Revert if the user is trying to repay more tokens than he borrowed
        if (_amount > borrowedAmount) revert CompoundUser_InsufficientAmount();
        // TODO: Update borrowedAmount state var
        borrowedAmount -= _amount;
        // TODO: Transfer the DAI tokens from the user to this contract
        dai.transferFrom(msg.sender, address(this), _amount);
        // TODO: Approve Compound cToken contract to spend the DAI tokens
        dai.approve(address(cDai), _amount);
        // TODO: Repay the loan
        cDai.repayBorrow(_amount);
    }
}
