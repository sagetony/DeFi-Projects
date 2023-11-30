// // SPDX-License-Identifier: SEE LICENSE IN LICENSE
// pragma solidity ^0.8.13;

// import {console, Test} from "forge-std/Test.sol";

// import {DAI} from "../src/unchecked-return-3/DAI.sol";
// import {USDC} from "../src/unchecked-return-3/USDC.sol";
// import {UST} from "../src/unchecked-return-3/UST.sol";

// contract TestStableSwap is Test {
//     uint256 constant TOKENS_INITIAL_SUPPLY = 100000000 * (10 ** 6);
//     uint256 constant TOKENS_IN_STABLESWAP = 1000000 * (10 ** 6);
//     uint8 constant CHAIN_ID = 31337;

//     DAI private dai;
//     USDC private usdc;
//     UST private ust;

//     address deployer = makeAddr("deployer");
//     address user1 = makeAddr("user1");

//     function setUp() external {
//         vm.startPrank(deployer);
//         dai = new DAI(CHAIN_ID);
//         usdc = new USDC();
//         usdc.initialize(
//             "Center Coin",
//             "USDC",
//             "USDC",
//             6,
//             deployer,
//             deployer,
//             deployer,
//             deployer
//         );

//         ust = new UST(TOKENS_INITIAL_SUPPLY, "Terra USD", "UST", 6);
//         vm.stopPrank();
//     }
// }
