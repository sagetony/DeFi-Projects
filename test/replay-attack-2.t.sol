// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {console, Test} from "forge-std/Test.sol";
import {AttackRealtySale} from "../src/replay-attack-2/AttackRealtySale.sol";
import {RealtySale} from "../src/replay-attack-2/RealtySale.sol";

contract TestRealtySale is Test {
    AttackRealtySale attackrealtysale;
    RealtySale realtysale;

    address deployer;
    uint256 privateDeployer;

    address signerOne;
    uint256 privateSignerOne;

    address userOne;
    address userTwo;
    address attacker;
    uint256 privateKeyAttacker;

    function setUp() external {
        // Assigning address
        (deployer, privateDeployer) = makeAddrAndKey("deployer");
        (signerOne, privateSignerOne) = makeAddrAndKey("signer");
        (attacker, privateKeyAttacker) = makeAddrAndKey("attacker");
        userOne = makeAddr("userOne");
        userTwo = makeAddr("userTwo");

        // deploy realtysale contract
        vm.startPrank(deployer);
        realtysale = new RealtySale();
        vm.stopPrank();
    }

    function test_Attack() public {
        //setUp
        vm.startPrank(attacker);
        attackrealtysale = new AttackRealtySale(address(realtysale));
        //execution
        attackrealtysale.attack();
        //assert
        assertEq(attackrealtysale.balanceNft(), 100);
        vm.stopPrank();
    }
}
