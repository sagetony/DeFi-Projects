// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {console, Test} from "forge-std/Test.sol";
import {ProtectSignatureWallet} from "../src/replay-attack-1/ProtectMutiSignatureWallet.sol";

contract TestMultiSignature is Test {
    ProtectSignatureWallet multisignaturewallet;

    address deployer;
    uint256 privateKeyDeployer;

    address signerTwo;
    uint256 privateKeySignerTwo;

    uint256 constant ETH_IN_MULTISIG = 100 ether;
    uint256 constant ATTACKER_WITHDRAW = 1 ether;

    address user = makeAddr("user");

    ProtectSignatureWallet.Signature deployerSignature;
    ProtectSignatureWallet.Signature signerTwoSignature;

    function setUp() external {
        (deployer, privateKeyDeployer) = makeAddrAndKey("deployer");
        (signerTwo, privateKeySignerTwo) = makeAddrAndKey("signerTwo");

        address[2] memory signatories;
        signatories[0] = deployer;
        signatories[1] = signerTwo;

        // deployment of MultiSignature Contract
        vm.prank(deployer);

        multisignaturewallet = new ProtectSignatureWallet(signatories);

        // set Eth balance
        vm.deal(deployer, ETH_IN_MULTISIG);

        vm.prank(deployer);
        (bool success, ) = address(multisignaturewallet).call{
            value: ETH_IN_MULTISIG
        }("");
        require(success, "Transfer Failed!!!");
        assertEq(address(multisignaturewallet).balance, ETH_IN_MULTISIG);

        // Prepare the withdraw message
        string memory message = "\x19Ethereum Signed Message:\n52";
        bytes32 hashMessage = keccak256(
            abi.encodePacked(message, user, ATTACKER_WITHDRAW)
        );

        // Sign message
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = vm.sign(privateKeyDeployer, hashMessage);

        deployerSignature = ProtectSignatureWallet.Signature(v, r, s);

        (v, r, s) = vm.sign(privateKeySignerTwo, hashMessage);

        signerTwoSignature = ProtectSignatureWallet.Signature(v, r, s);

        multisignaturewallet.transfer(
            user,
            ATTACKER_WITHDRAW,
            [deployerSignature, signerTwoSignature]
        );
        assertEq(
            ETH_IN_MULTISIG - ATTACKER_WITHDRAW,
            address(multisignaturewallet).balance
        );

        assertEq(user.balance, ATTACKER_WITHDRAW);
    }

    function test_Transfer() external {
        for (uint256 i = 1; i <= 99; ) {
            multisignaturewallet.transfer(
                user,
                ATTACKER_WITHDRAW,
                [deployerSignature, signerTwoSignature]
            );

            unchecked {
                ++i;
            }
        }
    }
}
