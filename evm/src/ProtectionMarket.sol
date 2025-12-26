// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);
}

interface IOracle {
    function isLiquidated(
        address loan,
        uint256 loanId
    ) external view returns (bool, uint256, uint256);
}

contract ProtectionMarket {
    struct Underwriter {
        uint256 collateral; // U_collateral
        uint256 reward; // U_reward
        bool withdrawn;
    }
    struct Challenger {
        uint256 stake; // C_reward
        bool withdrawn;
    }
    struct Protection {
        address user;
        address loan;
        uint256 loanId;
        address authorizedCollateralBufferManager;
        address collateralToken; // 0x0 for native, else ERC20
        address rewardToken; // ERC20 for reward, cannot be native
        uint256 protectionFee;
        uint256 protectionEnd;
        address oracle;
        bool settled;
        bool liquidated;
        uint256 totalLiquidationAmount;
        uint256 totalCollateralBuffer;
        uint256 totalUnderwriterReward;
        uint256 totalChallengerStake;
        mapping(address => Underwriter) underwriters;
        mapping(address => Challenger) challengers;
    }

    uint256 public nextProtectionId;
    mapping(uint256 => Protection) public protections;

    event ProtectionOpened(
        uint256 indexed protectionId,
        address indexed user,
        address loan,
        uint256 loanId,
        address collateralToken,
        uint256 protectionEnd,
        uint256 protectionFee
    );
    event UnderwriterJoined(
        uint256 indexed protectionId,
        address indexed underwriter,
        uint256 collateral,
        uint256 reward
    );
    event ChallengerJoined(
        uint256 indexed protectionId,
        address indexed challenger,
        uint256 stake
    );
    event ProtectionSettled(uint256 indexed protectionId, bool liquidated);
    event Withdrawn(
        uint256 indexed protectionId,
        address indexed participant,
        uint256 amount
    );

    // Open a protection market for a loan
    function openProtection(
        address loan,
        uint256 loanId,
        address authorizedCollateralBufferManager,
        uint256 duration,
        address oracle,
        address collateralToken,
        address rewardToken,
        uint256 protectionFee
    ) external payable returns (uint256) {
        require(duration > 0, "Duration required");
        require(oracle != address(0), "Oracle required");
        require(protectionFee > 0, "Protection fee required");

        if (collateralToken == address(0)) {
            require(
                msg.value == protectionFee,
                "Fee must be paid in native token"
            );
        } else {
            require(msg.value == 0, "Native token not accepted");
            require(
                IERC20(collateralToken).transferFrom(
                    msg.sender,
                    address(this),
                    protectionFee
                ),
                "ERC20 fee transfer failed"
            );
        }

        require(rewardToken != address(0), "Reward token must be ERC20");
        uint256 protectionId = nextProtectionId++;
        Protection storage p = protections[protectionId];
        p.user = msg.sender;
        p.loan = loan;
        p.loanId = loanId;
        p.authorizedCollateralBufferManager = authorizedCollateralBufferManager;
        p.collateralToken = collateralToken;
        p.rewardToken = rewardToken;
        p.protectionFee = protectionFee;
        p.protectionEnd = block.timestamp + duration;
        p.oracle = oracle;
        p.settled = false;
        p.liquidated = false;

        emit ProtectionOpened(
            protectionId,
            msg.sender,
            loan,
            loanId,
            collateralToken,
            p.protectionEnd,
            protectionFee
        );
        return protectionId;
    }

    // Underwriter joins with U_collateral and U_reward
    function joinAsUnderwriter(
        uint256 protectionId,
        uint256 collateral,
        uint256 reward
    ) external payable {
        Protection storage p = protections[protectionId];
        require(block.timestamp < p.protectionEnd, "Protection expired");
        require(!p.settled, "Already settled");
        require(collateral > 0, "Collateral required");

        // Collateral deposit
        if (p.collateralToken == address(0)) {
            require(msg.value == collateral, "Must send native collateral");
        } else {
            require(msg.value == 0, "Native token not accepted");
            require(
                IERC20(p.collateralToken).transferFrom(
                    msg.sender,
                    address(this),
                    collateral
                ),
                "ERC20 collateral transfer failed"
            );
        }
        // Reward deposit (always ERC20)
        require(
            IERC20(p.rewardToken).transferFrom(
                msg.sender,
                address(this),
                reward
            ),
            "ERC20 reward transfer failed"
        );

        Underwriter storage u = p.underwriters[msg.sender];
        require(u.collateral == 0 && u.reward == 0, "Already joined");
        u.collateral = collateral;
        u.reward = reward;
        u.withdrawn = false;
        p.totalCollateralBuffer += collateral;
        p.totalUnderwriterReward += reward;

        emit UnderwriterJoined(protectionId, msg.sender, collateral, reward);
    }

    // Challenger joins with C_reward
    function joinAsChallenger(
        uint256 protectionId,
        uint256 stake
    ) external payable {
        Protection storage p = protections[protectionId];
        require(block.timestamp < p.protectionEnd, "Protection expired");
        require(!p.settled, "Already settled");
        require(stake > 0, "Stake required");

        // Challenger stake is always in rewardToken
        require(msg.value == 0, "Native token not accepted for reward");
        require(
            IERC20(p.rewardToken).transferFrom(
                msg.sender,
                address(this),
                stake
            ),
            "ERC20 reward transfer failed"
        );

        Challenger storage c = p.challengers[msg.sender];
        require(c.stake == 0, "Already joined");
        c.stake = stake;
        c.withdrawn = false;
        p.totalChallengerStake += stake;

        emit ChallengerJoined(protectionId, msg.sender, stake);
    }

    // Settle the protection market after expiry
    function settle(uint256 protectionId) external {
        Protection storage p = protections[protectionId];
        require(block.timestamp >= p.protectionEnd, "Protection not expired");
        require(!p.settled, "Already settled");
        p.settled = true;
        (
            bool liquidated,
            uint256 liquidationTime,
            uint256 liquidationAmount
        ) = IOracle(p.oracle).isLiquidated(p.loan, p.loanId);
        // Only count as liquidated if within protection period
        if (
            liquidated &&
            liquidationTime >=
            (p.protectionEnd - (p.protectionEnd - block.timestamp)) &&
            liquidationTime <= p.protectionEnd
        ) {
            p.liquidated = true;
            // Store the amount liquidated for use in withdrawal
            p.totalLiquidationAmount = liquidationAmount;
        } else {
            p.liquidated = false;
            p.totalLiquidationAmount = 0;
        }
        emit ProtectionSettled(protectionId, p.liquidated);
        uint256 totalLiquidationAmount;
    }

    // Withdraw rewards/stake after settlement
    function withdraw(uint256 protectionId) external {
        Protection storage p = protections[protectionId];
        require(p.settled, "Not settled");
        uint256 amount = 0;

        // Underwriter withdrawal
        Underwriter storage u = p.underwriters[msg.sender];
        if (u.collateral > 0 || u.reward > 0) {
            require(!u.withdrawn, "Already withdrawn");
            uint256 collateralAmount = 0;
            uint256 rewardAmount = 0;
            if (!p.liquidated) {
                // No liquidation: underwriter gets collateral + pro-rata protection fee
                collateralAmount = u.collateral;
                if (p.totalCollateralBuffer > 0) {
                    collateralAmount +=
                        (u.collateral * p.protectionFee) /
                        p.totalCollateralBuffer;
                }
                // Underwriter gets reward + pro-rata challenger stakes (reward pool)
                rewardAmount = u.reward;
                if (
                    p.totalChallengerStake > 0 && p.totalUnderwriterReward > 0
                ) {
                    rewardAmount +=
                        (u.reward * p.totalChallengerStake) /
                        p.totalUnderwriterReward;
                }
            } else {
                // Liquidation: underwriter loses up to their share of the liquidated amount, all reward lost
                uint256 loss = (u.collateral * p.totalLiquidationAmount) /
                    p.totalCollateralBuffer;
                if (loss > u.collateral) {
                    loss = u.collateral;
                }
                collateralAmount = (u.collateral - loss);
                if (p.totalCollateralBuffer > 0) {
                    collateralAmount +=
                        (u.collateral * p.protectionFee) /
                        p.totalCollateralBuffer;
                }
                // reward is always lost in liquidation
            }
            u.withdrawn = true;
            _transfer(p.collateralToken, msg.sender, collateralAmount);
            _transfer(p.rewardToken, msg.sender, rewardAmount);
            emit Withdrawn(
                protectionId,
                msg.sender,
                collateralAmount + rewardAmount
            );
            return;
        }

        // Challenger withdrawal
        Challenger storage c = p.challengers[msg.sender];
        if (c.stake > 0) {
            require(!c.withdrawn, "Already withdrawn");
            uint256 rewardAmount = 0;
            if (p.liquidated) {
                // Challengers win: share U_reward pro-rata by stake
                if (
                    p.totalUnderwriterReward > 0 && p.totalChallengerStake > 0
                ) {
                    rewardAmount =
                        (c.stake * p.totalUnderwriterReward) /
                        p.totalChallengerStake;
                }
            } else {
                // No liquidation: challengers lose their stake
                rewardAmount = 0;
            }
            c.withdrawn = true;
            if (rewardAmount > 0) {
                _transfer(p.rewardToken, msg.sender, rewardAmount);
            }
            emit Withdrawn(protectionId, msg.sender, rewardAmount);
            return;
        }

        revert("Nothing to withdraw");
    }

    /// @notice Returns liquidation status, amount, and protection end for a protection market
    function getProtectionStatus(
        uint256 protectionId
    )
        external
        view
        returns (
            bool settled,
            bool liquidated,
            uint256 liquidationAmount,
            uint256 protectionEnd
        )
    {
        Protection storage p = protections[protectionId];
        return (
            p.settled,
            p.liquidated,
            p.totalLiquidationAmount,
            p.protectionEnd
        );
    }

    /// @notice Claim liquidated collateral (protocol/adapter only, after liquidation)
    function claimLiquidationCollateral(
        uint256 protectionId,
        address to
    ) external {
        Protection storage p = protections[protectionId];
        require(
            msg.sender == p.authorizedCollateralBufferManager,
            "Not authorized"
        );
        require(p.settled, "Not settled");
        require(p.liquidated, "Not liquidated");
        require(p.totalLiquidationAmount > 0, "No collateral to claim");
        require(
            p.totalCollateralBuffer >= p.totalLiquidationAmount,
            "Insufficient collateral"
        );
        p.totalCollateralBuffer -= p.totalLiquidationAmount;
        _transfer(p.collateralToken, to, p.totalLiquidationAmount);
    }

    /// @notice Return unused collateral to protocol (after settlement, if not liquidated)
    function returnUnusedCollateral(uint256 protectionId, address to) external {
        Protection storage p = protections[protectionId];
        require(p.settled, "Not settled");
        require(!p.liquidated, "Only if not liquidated");
        require(p.totalCollateralBuffer > 0, "No collateral to return");
        uint256 amount = p.totalCollateralBuffer;
        p.totalCollateralBuffer = 0;
        _transfer(p.collateralToken, to, amount);
    }

    function _transfer(address token, address to, uint256 amount) internal {
        if (amount == 0) return;
        if (token == address(0)) {
            (bool sent, ) = to.call{value: amount}("");
            require(sent, "Native transfer failed");
        } else {
            require(
                IERC20(token).transfer(to, amount),
                "ERC20 transfer failed"
            );
        }
    }

    // Allow contract to receive native token
    receive() external payable {}
}
