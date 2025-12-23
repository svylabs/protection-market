// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ProtectionMarket.sol";

/**
 * @title MockOracle
 * @dev Simple mock oracle for testing
 */
contract MockOracle is IOracle {
    struct LiquidationInfo {
        bool liquidated;
        uint256 timestamp;
        uint256 amount;
    }
    mapping(address => mapping(uint256 => LiquidationInfo))
        public liquidationInfo;

    function setLiquidated(
        address loan,
        uint256 loanId,
        bool _liquidated,
        uint256 _amount
    ) external {
        liquidationInfo[loan][loanId].liquidated = _liquidated;
        if (_liquidated) {
            liquidationInfo[loan][loanId].timestamp = block.timestamp;
            liquidationInfo[loan][loanId].amount = _amount;
        } else {
            liquidationInfo[loan][loanId].timestamp = 0;
            liquidationInfo[loan][loanId].amount = 0;
        }
    }

    function isLiquidated(
        address loan,
        uint256 loanId
    ) external view override returns (bool, uint256, uint256) {
        LiquidationInfo memory info = liquidationInfo[loan][loanId];
        return (info.liquidated, info.timestamp, info.amount);
    }
}
