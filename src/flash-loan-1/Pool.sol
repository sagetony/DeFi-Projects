// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity 0.8.20;

interface IReceiver {
    function getETH() external payable;
}

/**
 * @title Pool
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract Pool {
    error Pool_InsufficientFund();
    error Pool_InvalidAmount();

    constructor() payable {}

    // TODO: Complete this function
    function flashLoan(uint256 amount) external {
        uint256 beforeAmount = address(this).balance;
        // check that the amount is not zero
        if (amount == 0) revert Pool_InvalidAmount();
        // check the balance of the contract to be greater than amount
        if (address(this).balance < amount) revert Pool_InsufficientFund();
        //perform the flash loan
        IReceiver(msg.sender).getETH{value: amount}();

        assert(address(this).balance >= beforeAmount);
    }

    receive() external payable {}
}
