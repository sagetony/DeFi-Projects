// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity 0.8.20;

interface IPool {
    function flashLoan(uint256 amount) external;
}

/**
 * @title Receiver
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract Receiver {
    IPool private immutable pool;

    error Receiver_FailedTransaction();
    error Receiver_InvalidAmount();

    constructor(address _poolAddress) {
        pool = IPool(_poolAddress);
    }

    // TODO: Implement Receiver logic (Receiving a loan and paying it back)
    function useLoan() internal {
        (bool success, ) = address(pool).call{value: address(this).balance}("");
        if (!success) revert Receiver_FailedTransaction();
    }

    // TODO: Complete this function
    function flashLoan(uint256 amount) external {
        if (amount == 0) revert Receiver_InvalidAmount();
        IPool(pool).flashLoan(amount);
    }

    // TODO: Complete getETH() payable function
    function getETH() external payable {
        useLoan();
    }
}
