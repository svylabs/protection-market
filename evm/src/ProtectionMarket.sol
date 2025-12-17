// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IOracle
 * @dev Interface for Oracle integration
 */
interface IOracle {
    function isLiquidated(
        address loan,
        uint256 loanId
    ) external view returns (bool);
}

/**
 * @title ProtectionMarket
 * @dev Main contract for the Protection Markets Protocol
 */
contract ProtectionMarket {
    struct Protection {
        address user;
        address loan;
        uint256 loanId;
        uint256 protectionFee;
        uint256 protectionEnd;
        address oracle;
        bool settled;
        bool liquidated;
        address[] challengers;
        address[] underwriters;
        mapping(address => uint256) challengerDeposits;
        mapping(address => uint256) underwriterCollateral;
        uint256 totalChallengerDeposit;
        uint256 totalUnderwriterCollateral;
    }

    uint256 public nextProtectionId;
    mapping(uint256 => Protection) public protections;

    event ProtectionOpened(
        uint256 indexed protectionId,
        address indexed user,
        address loan,
        uint256 loanId,
        uint256 protectionEnd
    );
    event ChallengerJoined(
        uint256 indexed protectionId,
        address indexed challenger,
        uint256 amount
    );
    event UnderwriterJoined(
        uint256 indexed protectionId,
        address indexed underwriter,
        uint256 amount
    );
    event ProtectionSettled(uint256 indexed protectionId, bool liquidated);

    // Open a protection market for a loan
    function openProtection(
        address loan,
        uint256 loanId,
        uint256 duration,
        address oracle
    ) external payable returns (uint256) {
        require(msg.value > 0, "Protection fee required");
        require(duration > 0, "Duration required");
        require(oracle != address(0), "Oracle required");

        uint256 protectionId = nextProtectionId++;
        Protection storage p = protections[protectionId];
        p.user = msg.sender;
        p.loan = loan;
        p.loanId = loanId;
        p.protectionFee = msg.value;
        p.protectionEnd = block.timestamp + duration;
        p.oracle = oracle;
        p.settled = false;
        p.liquidated = false;

        emit ProtectionOpened(
            protectionId,
            msg.sender,
            loan,
            loanId,
            p.protectionEnd
        );
        return protectionId;
    }

    // Challenger joins by betting on liquidation
    function joinAsChallenger(uint256 protectionId) external payable {
        Protection storage p = protections[protectionId];
        require(block.timestamp < p.protectionEnd, "Protection expired");
        require(msg.value > 0, "Deposit required");
        require(!p.settled, "Already settled");
        if (p.challengerDeposits[msg.sender] == 0) {
            p.challengers.push(msg.sender);
        }
        p.challengerDeposits[msg.sender] += msg.value;
        p.totalChallengerDeposit += msg.value;
        emit ChallengerJoined(protectionId, msg.sender, msg.value);
    }

    // Underwriter joins by providing collateral
    function joinAsUnderwriter(uint256 protectionId) external payable {
        Protection storage p = protections[protectionId];
        require(block.timestamp < p.protectionEnd, "Protection expired");
        require(msg.value > 0, "Collateral required");
        require(!p.settled, "Already settled");
        if (p.underwriterCollateral[msg.sender] == 0) {
            p.underwriters.push(msg.sender);
        }
        p.underwriterCollateral[msg.sender] += msg.value;
        p.totalUnderwriterCollateral += msg.value;
        emit UnderwriterJoined(protectionId, msg.sender, msg.value);
    }

    // Settle the protection market after expiry
    function settle(uint256 protectionId) external {
        Protection storage p = protections[protectionId];
        require(block.timestamp >= p.protectionEnd, "Protection not expired");
        require(!p.settled, "Already settled");
        p.settled = true;
        bool liquidated = IOracle(p.oracle).isLiquidated(p.loan, p.loanId);
        p.liquidated = liquidated;
        uint256 fee = p.protectionFee;
        uint256 challengerShare;
        uint256 underwriterShare;
        if (liquidated) {
            // Challengers win: share underwriter collateral + user fee
            challengerShare = (p.totalUnderwriterCollateral * 80) / 100 + fee; // 80% to challengers, 20% to protocol/owner
            underwriterShare = (p.totalUnderwriterCollateral * 20) / 100;
            for (uint256 i = 0; i < p.challengers.length; i++) {
                address c = p.challengers[i];
                uint256 portion = (p.challengerDeposits[c] * challengerShare) /
                    p.totalChallengerDeposit;
                payable(c).transfer(portion);
            }
            // Underwriters lose collateral, but get 20% back
            for (uint256 i = 0; i < p.underwriters.length; i++) {
                address u = p.underwriters[i];
                uint256 portion = (p.underwriterCollateral[u] *
                    underwriterShare) / p.totalUnderwriterCollateral;
                if (portion > 0) payable(u).transfer(portion);
            }
        } else {
            // Underwriters win: share challenger deposit
            for (uint256 i = 0; i < p.underwriters.length; i++) {
                address u = p.underwriters[i];
                uint256 portion = (p.underwriterCollateral[u] *
                    p.totalChallengerDeposit) / p.totalUnderwriterCollateral;
                if (portion > 0) payable(u).transfer(portion);
            }
        }
        emit ProtectionSettled(protectionId, liquidated);
    }
}
