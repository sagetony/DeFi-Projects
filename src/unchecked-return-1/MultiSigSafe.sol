// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

/**
 * @title MultiSigSafe
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract MultiSigSafe {
    address[] public signers;
    uint8 public requiredApprovals;

    // To -> Amount -> Approvals
    mapping(address => mapping(uint256 => uint256)) public withdrawRequests;

    // @audit 1. no zero address check.
    // 2. No recieve() to accept ether from the donation contract.
    constructor(address[] memory _signers, uint8 _requiredApprovals) {
        requiredApprovals = _requiredApprovals;
        uint256 length = _signers.length;
        if (requiredApprovals > signers.length)
            revert("RequiredApprovals more that the signer");
        for (uint i = 0; i < length; i++) {
            if (signers[0] == address(0)) revert("Invalid Address");
            signers.push(_signers[i]);
        }
    }

    function withdrawETH(address _to, uint _amount) external {
        // @audit no address check
        if (_to == address(0)) revert("Invalid Address");
        uint approvals = withdrawRequests[_to][_amount];
        require(approvals >= requiredApprovals, "Not enough approvals");

        withdrawRequests[_to][_amount] = 0;

        // @audit unchecked return
        bool success = payable(_to).send(_amount);
        if (!success) revert("Invalid Transaction");
    }
}
