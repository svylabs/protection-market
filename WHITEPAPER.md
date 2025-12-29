# Liquidax: Liquidation Buffers and Protection Markets for On-Chain Loan Safety

**Author:** Sridhar G <sridharg@protonmail.com>

---

## Abstract

**Liquidax** introduces a new DeFi risk primitive: **Liquidation Buffers**, supplied through open **Protection Markets**. Instead of compensating borrowers after liquidations, Liquidax enables _pre-emptive risk reduction_ by allowing third-party capital to temporarily reinforce the collateral backing of individual on-chain loans.

Through Liquidax, borrowers can purchase time-bound liquidation resistance, underwriters earn yield by supplying junior collateral buffers, and challengers provide adversarial price discovery by staking against loan survival. Protection is fully market-priced, non-custodial, and directly integrated into loan health and liquidation logic via protocols or smart wallets.

Liquidax does not offer insurance, guarantees, or borrower payouts. It introduces a market for **temporary downside collateral**, transparently pricing liquidation risk while preserving protocol solvency and composability.

---

## 1. Motivation

### 1.1 Liquidation Risk in DeFi

Automated liquidations are foundational to DeFi lending protocols. While effective for protocol solvency, liquidations impose severe costs on borrowers:

- Forced asset sales at a discount
- Slippage during volatile market conditions
- Cascading liquidations that amplify systemic stress

Borrowers today face a limited choice set:

- Maintain inefficiently high overcollateralization
- Monitor positions continuously and intervene manually

Neither option offers flexible, market-priced liquidation protection.

### 1.2 Limitations of Existing Risk Solutions

Most existing DeFi risk products focus on **post-event compensation** (insurance, options, hedging) or **protocol-wide parameter tuning**. These approaches do not:

- Improve the real-time health of a specific loan
- Allow open market pricing of liquidation risk
- Enable third parties to supply temporary collateral buffers

There is no native primitive for borrowers to _buy additional collateral backing_ for a defined period of time.

---

## 2. Core Concept: Liquidation Buffers

Liquidax enables borrowers to attach **Liquidation Buffers** to existing loans.

A Liquidation Buffer consists of **underwriter-supplied collateral** that:

- Is locked for a fixed duration
- Is non-withdrawable by the borrower
- Is junior to borrower collateral
- Is consumed first during liquidation
- Directly improves loan health metrics while active

Liquidation Buffers exist only while third-party collateral remains locked. There are:

- No insurance claims
- No borrower payouts
- No principal guarantees for underwriters

Protection improves loan survivability by altering the collateral structure itself, not by compensating losses after liquidation.

---

## 3. Roles in the Liquidax Protection Market

### 3.1 Borrower

- Opens a loan via a lending protocol or CDP
- Purchases a Liquidation Buffer for a chosen duration
- Pays a time-based protection fee
- Benefits from increased liquidation resistance

### 3.2 Underwriter

- Supplies collateral to form Liquidation Buffers for specific loans
- Earns borrower-paid fees proportional to capital and time at risk
- Bears explicit liquidation risk and market price risk

Underwriters may lose some or all supplied collateral, even if the loan is not liquidated.

### 3.3 Challenger

- Stakes capital against loan survival during the buffer period
- Provides adversarial price discovery and risk signaling
- Receives underwriter reward capital if liquidation occurs
- Loses stake if the loan remains solvent

Challengers act as short sellers of loan survival.

### 3.4 Oracle / Integration

- Reports finalized liquidation outcomes and collateral accounting data
- Implemented natively by the lending protocol or by a smart wallet managing the loan position

---

## 4. System Architecture

### 4.1 Separation of Concerns

Liquidax **does not implement lending, debt issuance, or liquidation logic**.

Instead, it coordinates:

- Protection markets
- Capital commitments
- Fee flows
- Settlement outcomes

Loan accounting and liquidation enforcement remain the responsibility of integrated protocols or wallets.

### 4.2 Integration Responsibilities

Integrators must:

- Recognize Liquidation Buffers as valid, junior collateral
- Exclude buffer collateral from borrower withdrawals
- Enforce priority consumption of buffer collateral during liquidation
- Apply buffer expiry and decay rules
- Expose finalized liquidation and collateral consumption data

### 4.3 Integration Models

Supported integration approaches include:

- **Native Protocol Integration** – Lending protocols natively support Liquidation Buffers as a distinct collateral class
- **Smart Wallet Integration** – Wallets manage loan sub-accounts where buffers affect liquidation logic but remain inaccessible to borrowers

---

## 5. Collateral Waterfall

Upon liquidation:

1. Liquidation Buffer collateral is consumed first
2. Borrower collateral is consumed next
3. Any remaining shortfall becomes protocol bad debt

This junior structure is essential for correct market pricing of protection.

---

## 6. Loan Health Accounting

Let:

- `C_user` = borrower collateral
- `C_buffer` = liquidation buffer collateral
- `h` = haircut applied to buffer collateral
- `D` = outstanding debt

Effective collateralization ratio:

```
ECR = (C_user + h × C_buffer) / D
```

Buffer collateral contributes to loan health only while active and remains fully exposed to market price fluctuations.

---

## 7. Liquidation Buffer Lifecycle

### 7.1 Activation

- Borrower selects buffer size and duration
- Borrower pays a time-based protection fee
- Underwriters lock collateral
- Integrator updates loan accounting

### 7.2 Active Period

- Buffer improves loan health
- Underwriters cannot withdraw collateral
- Borrowers cannot access buffer collateral
- Challengers may enter during defined windows

### 7.3 Expiry and Decay

- Buffer contribution decays during a final window
- Buffer collateral is removed from loan health metrics
- Underwriters reclaim remaining collateral, if any

Loan survival does **not** imply underwriter principal preservation.

---

## 8. Fee Allocation

All borrower-paid protection fees are distributed exclusively to underwriters supplying Liquidation Buffers, pro-rata by capital and time.

Fees accrue linearly over the buffer duration.

---

## 9. Settlement Outcomes

### 9.1 No Liquidation

- Underwriters recover remaining buffer collateral
- Underwriters receive accrued borrower fees
- Underwriters receive challenger stakes

### 9.2 Liquidation Event

- Buffer collateral is consumed according to liquidation rules
- Borrower collateral is liquidated next
- Underwriters may lose part or all of their collateral
- Challenger reward capital is distributed per market rules

Borrowers receive no payouts.

---

## 10. Challenger Economics

Challengers provide negative risk exposure and adversarial pricing.

To limit leverage:

```
Total Challenger Stake ≤ β × Underwriter Reward Capital
```

Where `β` is protocol-defined.

---

## 11. Market Pricing

Protection pricing emerges from open participation based on:

- Loan health at entry
- Asset volatility
- Buffer duration and depth
- Challenger pressure

Liquidax imposes no pricing models.

---

## 12. Risks and Challenges

### 12.1 Integration Risk

- Lending protocols vary significantly in accounting and liquidation mechanics
- Integration complexity may introduce additional trust assumptions

### 12.2 Oracle and Accounting Risk

- Accurate reporting of partial consumption and liquidation timing is critical
- Delays or inconsistencies may affect settlement correctness

### 12.3 Incentive and Market Risk

- Underwriters face asymmetric downside risk
- Thin markets may misprice protection
- Challenger manipulation must be mitigated via caps and timing rules

### 12.4 Systemic Risk

- Correlated crashes may cause widespread buffer losses
- Liquidax redistributes risk but does not eliminate systemic exposure

---

## 13. Design Principles

- Liquidation Buffers improve real loan health
- Protection is market-priced and time-bound
- Underwriters bear explicit downside risk
- Fees follow capital at risk
- No insurance claims or guarantees

---

## 14. Use Cases

- Borrowers seeking temporary liquidation resistance
- Smart wallets offering liquidation-buffered UX
- Protocols outsourcing liquidation risk pricing
- Risk dashboards surfacing adversarial sentiment

---

## 15. Conclusion

Liquidax introduces **Liquidation Buffers** and **Protection Markets** as a new on-chain risk primitive. By enabling market-priced, temporary collateral reinforcement without altering core lending logic, Liquidax offers safer borrowing, transparent risk transfer, and composable integration across the DeFi stack.
