# Liquidax: Liquidation Buffers and Protection Markets for On-Chain Loan Safety

**Author:** Sridhar G (<sridharg@protonmail.com>)

---

## Abstract

**Liquidax** introduces a new DeFi risk primitive: **Liquidation Buffers**, supplied through open **Protection Markets**. Instead of compensating borrowers after liquidations, Liquidax enables _pre-emptive risk reduction_ by allowing third-party capital to temporarily reinforce the collateral backing of individual on-chain loans.

Through Liquidax, borrowers can purchase time-bound liquidation resistance, underwriters earn yield by supplying junior collateral buffers, and challengers provide adversarial price discovery by staking against loan survival. Protection is fully market-priced, non-custodial, and directly integrated into loan health and liquidation logic via protocols or smart wallets.

Liquidax does **not** offer insurance, guarantees, or borrower payouts. It introduces a market for **temporary downside collateral**, transparently pricing liquidation risk while preserving protocol solvency and composability.

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
- Pays a one-time, upfront protection fee
- Benefits from increased liquidation resistance

### 3.2 Underwriter

- Supplies collateral to form Liquidation Buffers for specific loans
- May enter at any time while the buffer is active
- Cannot withdraw collateral until buffer expiry
- Earns borrower-paid fees over time
- Bears explicit liquidation and market price risk

Underwriters may lose some or all supplied collateral, even if the loan is not liquidated.

### 3.3 Challenger

- Stakes capital against loan survival during the buffer period
- Provides adversarial price discovery and risk signaling
- Loses entire stake if the loan remains solvent
- Receives escrowed underwriter reward capital if liquidation occurs

Challengers act as short sellers of loan survival.

### 3.4 Oracle / Integration Layer

- Reports finalized liquidation outcomes
- Reports partial or full buffer collateral consumption
- Implemented by lending protocols or smart wallets

---

## 4. System Architecture

### 4.1 Separation of Concerns

Liquidax **does not implement lending, debt issuance, or liquidation logic**.

It coordinates only:

- Protection markets
- Capital commitments
- Fee accrual and settlement
- Outcome-based redistribution

Loan accounting and liquidation enforcement remain with integrated protocols or wallets.

### 4.2 Integration Responsibilities

Integrators must:

- Recognize Liquidation Buffers as valid junior collateral
- Prevent borrower access to buffer collateral
- Enforce priority consumption of buffer collateral
- Apply buffer expiry and decay
- Report liquidation outcomes and timing

### 4.3 Integration Models

- **Native Protocol Integration**
- **Smart Wallet Integration** (loan sub-accounts)

---

## 5. Collateral Waterfall

Upon liquidation:

1. Liquidation Buffer collateral is consumed first
2. Borrower collateral is consumed next
3. Remaining shortfall becomes protocol bad debt

This junior structure is essential for correct market pricing.

---

## 6. Loan Health Accounting

Let:

- `C_user` = borrower collateral
- `C_buffer` = liquidation buffer collateral
- `D` = outstanding debt

```text
ECR = (C_user + C_buffer) / D
```

Liquidation Buffer collateral contributes **fully** to loan health metrics while active and remains fully exposed to market price changes.

---

## 7. Liquidation Buffer Lifecycle

### 7.1 Activation

- Borrower selects buffer size and fixed duration
- Borrower pays a one-time protection fee upfront
- Underwriters lock collateral as they enter
- Buffer parameters are immutable per unit of collateral
- Loan accounting is updated

### 7.2 Active Period

- Buffer improves loan health
- Underwriters:
  - Cannot withdraw collateral
  - Accrue fees from time of entry onward
- Borrowers:
  - Cannot access buffer collateral
  - Are protected from underwriter exit
- Challengers may enter at any time during the active period

### 7.3 Expiry and Decay

- Buffer contribution decays during a final window
- Buffer is progressively removed from loan health metrics
- At expiry:
  - Remaining collateral becomes withdrawable
  - Final fee settlement occurs

Loan survival does **not** imply underwriter principal preservation.

---

## 8. Fee Accrual and Distribution

### 8.1 Time-Weighted Fee Accrual

Borrower-paid protection fees accrue linearly over time.

Let:

- `F_total` = total protection fee
- `T` = buffer duration
- `t` = elapsed active time

```text
F_accrued(t) = F_total × (t / T)
```

Unaccrued fees are not distributed.

### 8.2 Collateral-Weighted Allocation

For underwriter `i`:

- `C_i` = supplied collateral
- `τ_i` = time active

```text
W_i = C_i × τ_i
```

```text
F_i = F_accrued × (W_i / Σ W)
```

Underwriters entering later receive no retroactive fee allocation and bear proportionally higher liquidation risk.

### 8.3 Early Liquidation

If liquidation occurs early:

- Fee accrual stops immediately
- Only accrued fees are distributed
- Unaccrued fees are forfeited
- Underwriters may lose collateral
- Challenger rewards settle exclusively against escrowed underwriter reward capital

There are no guaranteed returns.

---

## 9. Underwriter Commitment Model

### 9.1 Open-Entry, Time-Locked Underwriting

- Underwriters may join at any time while the buffer is active
- All supplied collateral is immediately locked
- Withdrawals are prohibited until buffer expiry
- Risk exposure begins immediately upon entry

### 9.2 Borrower Protection Guarantees

- Active buffer collateral cannot be withdrawn early
- Loan health cannot deteriorate due to underwriter exit
- Protection remains deterministic once active

---

## 10. Challenger Economics

- Challenger stakes are fully at risk
- Challenger upside is strictly bounded by explicitly escrowed underwriter reward capital
- No protocol-level caps are imposed beyond available rewards
- Challenger participation provides adversarial signaling and late-stage price discovery

---

## 11. Market Pricing

Protection pricing emerges from:

- Loan health at activation
- Asset volatility
- Buffer depth and duration
- Challenger participation

Liquidax imposes no pricing model.

---

## 12. Risks and Challenges

### 12.1 Integration Risk

### 12.2 Oracle and Accounting Risk

### 12.3 Incentive and Market Risk

### 12.4 Systemic Risk

Liquidax redistributes risk; it does not eliminate it.

---

## 13. Design Principles

- Buffers improve real loan health
- Protection is market-priced and time-bound
- Underwriters bear explicit downside risk
- Fees follow capital at risk
- No insurance semantics or guarantees

---

## 14. Use Cases

- Borrowers seeking temporary liquidation resistance
- Smart wallets with buffered UX
- Protocols outsourcing risk pricing
- Risk dashboards using challenger signals

---

## 15. Conclusion

Liquidax introduces **Liquidation Buffers** and **Protection Markets** as a new on-chain risk primitive. By enabling market-priced, time-bound collateral reinforcement without altering core lending logic, Liquidax improves borrower safety, enables explicit risk transfer, and remains fully composable across the DeFi stack.
