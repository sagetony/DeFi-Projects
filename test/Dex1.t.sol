// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Chocolate} from "src/dex-1/Chocolate.sol";
import {IUniswapV2Pair} from "src/interfaces/IUniswapV2.sol";

/**
 * @dev run "forge test --fork-url $ETH_RPC_URL --fork-block-number 15969633 --match-contract Chocolate"
 */
contract TestChocolate is Test {
    Chocolate chocolate;
    IUniswapV2Pair pair;

    address constant WETH_ADDRESS =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant RICH_SIGNER =
        address(0x8EB8a3b98659Cce290402893d0123abb75E3ab28);

    uint128 constant ETH_BALANCE = 300 ether;
    uint128 constant INITIAL_MINT = 1000000 ether;
    uint128 constant INITIAL_LIQUIDITY = 100000 ether;
    uint128 constant ETH_IN_LIQUIDITY = 100 ether;

    uint128 constant TEN_ETH = 10 ether;
    uint128 constant HUNDRED_CHOCOLATES = 100 ether;

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    IERC20 weth = IERC20(WETH_ADDRESS);

    function setUp() public {
        vm.label(WETH_ADDRESS, "WETH");
        vm.label(RICH_SIGNER, "RICH_SIGNER");

        vm.deal(user, 100 ether);
        address richSigner = RICH_SIGNER;

        vm.prank(deployer);
        chocolate = new Chocolate(INITIAL_MINT);
        pair = IUniswapV2Pair(chocolate.uniswapV2Pair());

        // Send ETH from rich signer to our deployer
        vm.prank(richSigner);
        (bool success, ) = deployer.call{value: ETH_BALANCE}("");
        require(success, "Transfer Failed!!!");
    }

    function test_Deployment() public {
        /**
         * CODE YOUR SOLUTION HERE
         */

        // TODO: Deploy your smart contract to `chocolate`, mint 1,000,000 tokens to deployer
        vm.prank(deployer);

        // TODO: Print newly created pair address and store pair contract to `this.pair`

        console.log(chocolate.uniswapV2Pair());
    }

    function test_DeployerAddLiquidity() public {
        /**
         * CODE YOUR SOLUTION HERE
         */

        // TODO: Add liquidity of 100,000 tokens and 100 ETH (1 token = 0.001 ETH)
        vm.startPrank(deployer);
        chocolate.approve(address(chocolate), INITIAL_LIQUIDITY);
        weth.approve(address(chocolate), ETH_IN_LIQUIDITY);
        chocolate.addChocolateLiquidity{value: 100}(INITIAL_LIQUIDITY);
        vm.stopPrank();

        // TODO: Print the amount of LP tokens that the deployer owns
        console.log(chocolate.balanceOf(deployer));
    }

    function test_UserSwap() public {
        /**
         * CODE YOUR SOLUTION HERE
         */

        test_DeployerAddLiquidity();

        uint256 userChocolateBalance = chocolate.balanceOf(user);
        uint256 userWETHBalance = weth.balanceOf(user);
        // console.log(weth.balanceOf(deployer));

        // TODO: From user: Swap 10 ETH to Chocolate
        vm.startPrank(user);
        chocolate.swapChocolates{value: TEN_ETH}(address(weth), TEN_ETH);

        // TODO: Make sure user received the chocolates (greater amount than before)
        uint256 userChocolateBalanceAfter = chocolate.balanceOf(user);
        assertGt(userChocolateBalanceAfter, userChocolateBalance);
        // TODO: From user: Swap 100 Chocolates to ETH
        chocolate.swapChocolates(address(chocolate), HUNDRED_CHOCOLATES);

        uint256 userWETHBalanceAfter = weth.balanceOf(user);
        // TODO: Make sure user received the WETH (greater amount than before)
        assertGt(userWETHBalanceAfter, userWETHBalance);

        vm.stopPrank();
    }

    function test_DeployerRemoveLiquidity() public {
        /**
         * CODE YOUR SOLUTION HERE
         */

        test_DeployerAddLiquidity();
        uint256 deployerChocolateBalance = chocolate.balanceOf(deployer);
        uint256 deployerWETHBalance = weth.balanceOf(deployer);

        // TODO: Remove 50% of deployer's liquidity

        // uint128 HALF_LQ = INITIAL_LIQUIDITY / 2;
        vm.startPrank(deployer);
        uint256 LQ = IUniswapV2Pair(pair).balanceOf(deployer);
        uint256 HALF_LQ = LQ / 2;

        IUniswapV2Pair((pair)).approve(address(chocolate), HALF_LQ);

        chocolate.removeChocolateLiquidity(HALF_LQ);
        uint256 deployerWETHBalanceAfter = weth.balanceOf(deployer);

        // // // TODO: Make sure deployer owns 50% of the LP tokens (leftovers)
        uint256 currentLP = IUniswapV2Pair(pair).balanceOf(deployer);
        assertEq(currentLP, HALF_LQ);

        // // // TODO: Make sure deployer got chocolate and weth back (greater amount than before)
        uint256 deployerChocolateBalanceAfter = chocolate.balanceOf(deployer);

        assertGt(deployerWETHBalanceAfter, deployerWETHBalance);
        assertGt(deployerChocolateBalanceAfter, deployerChocolateBalance);
        vm.stopPrank();
    }
}
