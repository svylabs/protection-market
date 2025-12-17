// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./ProtectionMarket.sol";
import "./MockOracle.sol";

contract ProtectionMarketTest is Test {
    ProtectionMarket market;
    MockOracle oracle;
    address user = address(0x1);
    address challenger = address(0x2);
    address underwriter = address(0x3);
    address loan = address(0x4);
    uint256 loanId = 1;

    function setUp() public {
        market = new ProtectionMarket();
        oracle = new MockOracle();
    }

    function testProtectionFlow() public {
        vm.deal(user, 10 ether);
        vm.deal(challenger, 10 ether);
        vm.deal(underwriter, 10 ether);
        vm.startPrank(user);
        uint256 protectionId = market.openProtection{value: 1 ether}(
            loan,
            loanId,
            1 days,
            address(oracle)
        );
        vm.stopPrank();

        vm.startPrank(challenger);
        market.joinAsChallenger{value: 1 ether}(protectionId);
        vm.stopPrank();

        vm.startPrank(underwriter);
        market.joinAsUnderwriter{value: 2 ether}(protectionId);
        vm.stopPrank();

        // Fast forward time
        vm.warp(block.timestamp + 2 days);
        // Set liquidation outcome
        oracle.setLiquidated(loan, loanId, true);

        // Settle
        market.settle(protectionId);
        // Add assertions as needed
    }
}
