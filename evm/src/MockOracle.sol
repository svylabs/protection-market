// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ProtectionMarket.sol";

/**
 * @title MockOracle
 * @dev Simple mock oracle for testing
 */
contract MockOracle is IOracle {
    mapping(address => mapping(uint256 => bool)) public liquidated;

    function setLiquidated(
        address loan,
        uint256 loanId,
        bool _liquidated
    ) external {
        liquidated[loan][loanId] = _liquidated;
    }

    function isLiquidated(
        address loan,
        uint256 loanId
    ) external view override returns (bool) {
        return liquidated[loan][loanId];
    }
}
