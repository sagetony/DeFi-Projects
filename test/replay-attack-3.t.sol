// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {console, Test} from "forge-std/Test.sol";

import {RedHawksVIP} from "../src/replay-attack-3/RedHawksVIP.sol";
import {AttackRedHawksVIP} from "../src/replay-attack-3/AttackRedHawksVIP.sol";

contract TestRA3 is Test {
    RedHawksVIP private redhawksvip;
    AttackRedHawksVIP private attackedhawksvip;
    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(uint256 chainId,address verifyingContract)");

    address deployer;

    address voucher;
    uint256 voucherKey;

    address user;
    address attacker;

    address signer;

    function setUp() external {
        deployer = makeAddr("deployer");
        (voucher, voucherKey) = makeAddrAndKey("voucher");
        attacker = makeAddr("attacker");
        user = makeAddr("user");
        vm.startPrank(deployer);
        // deploy redhawksvip contract
        redhawksvip = new RedHawksVIP(voucher);

        // get the hashdata
        bytes32 hashMessage = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256(
                        "VoucherData(uint256 amountOfTickets,string password)"
                    ),
                    2,
                    keccak256(bytes("sagetony"))
                )
            )
        );

        // Sign message
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = vm.sign(voucherKey, hashMessage);

        signer = ecrecover(hashMessage, v, r, s);

        // redhawksvip.mint(2, "sagetony", signer);
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, block.chainid, address(this)));
    }

    function _hashTypedDataV4(
        bytes32 structHash
    ) internal view virtual returns (bytes32) {
        return
            MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}
