// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./AaveInterfaces.sol";

error AaveUser_InvalidAmount();
error AaveUser_InsufficientAmount();

contract AaveUser is Ownable {
    // TODO: Complete state variables
    IPool private immutable aavepool;
    IERC20 private immutable dai;
    IERC20 private immutable usdc;

    mapping(address => uint256) public depositedamount;
    mapping(address => uint256) public borrowedAmount;

    // TODO: Complete the constructor
    constructor(
        address _pool,
        address _usdc,
        address _dai
    ) Ownable(msg.sender) {
        aavepool = IPool(_pool);
        dai = IERC20(_dai);
        usdc = IERC20(_usdc);
    }

    // Deposit USDC in AAVE Pool
    function depositUSDC(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        if (_amount == 0) revert AaveUser_InvalidAmount();
        // TODO: Update depositedamount state var
        depositedamount[msg.sender] += _amount;
        // TODO: Transfer from the sender the USDC to this contract
        usdc.transferFrom(msg.sender, address(this), _amount);
        // TODO: Supply USDC to aavePool Pool
        usdc.approve(address(aavepool), _amount);
        IPool(aavepool).supply(address(usdc), _amount, address(this), 0);
    }

    // Withdraw USDC
    function withdrawUSDC(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        if (_amount == 0) revert AaveUser_InvalidAmount();
        // TODO: Revert if the user is trying to withdraw more than the deposited amount
        if (_amount > depositedamount[msg.sender])
            revert AaveUser_InsufficientAmount();
        // TODO: Update depositedamount state var
        depositedamount[msg.sender] -= _amount;
        // TODO: Withdraw the USDC tokens, send them directly to the user
        IPool(aavepool).withdraw(address(usdc), _amount, msg.sender);
    }

    // Borrow DAI From aave, send DAI to the user (msg.sender)
    function borrowDAI(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        if (_amount == 0) revert AaveUser_InvalidAmount();
        // TODO: Update borrowedAmmount state var
        borrowedAmount[msg.sender] += _amount;
        // TODO: Borrow the DAI tokens in variable interest mode
        IPool(aavepool).borrow(address(dai), _amount, 2, 0, address(this));
        // TODO: Transfer DAI token to the user
        dai.transfer(msg.sender, _amount);
    }

    // Repay the borrowed DAI to AAVE
    function repayDAI(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        if (_amount == 0) revert AaveUser_InvalidAmount();
        // TODO: Revert if the user is trying to repay more tokens that he borrowed
        if (_amount > borrowedAmount[msg.sender])
            revert AaveUser_InsufficientAmount();
        // TODO: Update borrowedAmmount state var
        borrowedAmount[msg.sender] -= _amount;
        // TODO: Transfer the DAI tokens from the user to this contract
        dai.transferFrom(msg.sender, address(this), _amount);
        // TODO: Approve AAVE Pool to spend the DAI tokens
        dai.approve(address(aavepool), _amount);
        // TODO: Repay the loan
        aavepool.repay(address(dai), _amount, 2, address(this));
    }
}
