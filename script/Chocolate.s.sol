// // SPDX-License-Identifier: SEE LICENSE IN LICENSE
// pragma solidity 0.8.20;

// import "forge-std/Script.sol";
// import "forge-std/console.sol";
// import {Chocolate} from "../src/Chocolate.sol";

// contract ChocolateScript is Script {
//     Chocolate public chocolate;

//     function run() external {
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//         vm.startBroadcast(deployerPrivateKey);

//         address account = vm.addr(deployerPrivateKey);
//         console.log(account);

//         uint256 initialSupply = 1000000;
//         chocolate = new Chocolate(initialSupply);
//         // console.log(chocolate.uniswapV2Pair());

//         vm.stopBroadcast();
//     }
// }
