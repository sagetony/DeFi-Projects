// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity 0.8.20;

interface IPool {
    function flashLoan(uint256 amount) external;
}

/**
 * @title GreedyReceiver
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract GreedyReceiver {
    IPool pool;

    error GreedyReceiver_InvalidAmount(string message);

    constructor(address _poolAddress) {
        pool = IPool(_poolAddress);
    }

    // TODO: Implement Greedy Receiver Logic (Not paying back the loan)
    function useLoan() internal {}

    // TODO: Complete this function
    function flashLoan(uint256 amount) external {
        if (amount == 0)
            revert GreedyReceiver_InvalidAmount("Amount cant be zero");
        pool.flashLoan(amount);
    }

    // TODO: Complete getETH() payable function
    function getETH() external payable {
        useLoan();
    }
}
