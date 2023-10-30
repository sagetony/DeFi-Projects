// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity 0.8.20;

import "../interfaces/ILendingPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/Test.sol";

/**
 * @title FlashLoan
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract FlashLoan {
    ILendingPool immutable pool;

    error FlashLoan_InvalidAsset();
    error FlashLoan_AmountIsZero();
    error FlashLoan_OnlyContract();

    constructor(address _pool) {
        pool = ILendingPool(_pool);
    }

    // TODO: Implement this function
    function getFlashLoan(address token, uint amount) external {
        if (token == address(0)) revert FlashLoan_InvalidAsset();
        if (amount == 0) revert FlashLoan_AmountIsZero();
        console.log(IERC20(token).balanceOf(address(this)));

        address[] memory assets = new address[](1);
        assets[0] = token;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        pool.flashLoan(
            address(this),
            assets,
            amounts,
            modes,
            address(this),
            "0x",
            0
        );
        console.log(IERC20(token).balanceOf(address(this)));
    }

    // TODO: Implement this function
    function executeOperation(
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory premiums,
        address initiator,
        bytes memory params
    ) public returns (bool) {
        if (msg.sender != address(pool)) revert FlashLoan_OnlyContract();
        if (initiator != address(this)) revert FlashLoan_OnlyContract();

        IERC20 asset;

        for (uint i = 1; i <= 1; i++) {
            asset = IERC20(assets[i]);
            uint256 amount = amounts[i];
            uint256 premium = premiums[i];
            console.log(
                "contract's token balance during the flash loan: %s",
                asset.balanceOf(address(this))
            );

            uint amountToPay = amount + premium;

            asset.approve(address(pool), amountToPay);
        }

        return true;
    }
}
