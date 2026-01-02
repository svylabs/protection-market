# Liquidax: Liquidation Buffers and Protection Markets for On-Chain Loan Safety

**Author:** Sridhar G (<sridharg@protonmail.com>)

---

## Abstract

**Liquidax** introduces a new DeFi risk primitive: **Liquidation Buffers**, supplied through open **Protection Markets**. Instead of compensating borrowers after liquidations, Liquidax enables _pre-emptive risk reduction and capital efficiency_ by allowing third-party capital to temporarily reinforce — and partially substitute — the collateral backing of individual on-chain loans.

Through Liquidax, borrowers can purchase time-bound liquidation resistance **or safely withdraw a portion of their own collateral** without increasing liquidation risk. Underwriters earn yield by supplying junior collateral buffers, and challengers provide adversarial price discovery by staking against loan survival. Protection is fully market-priced, non-custodial, and directly integrated into loan health and liquidation logic via protocols or smart wallets.

Liquidax does **not** offer insurance, guarantees, or borrower payouts. It introduces a market for **temporary downside collateral**, transparently pricing liquidation risk while preserving protocol solvency and composability.

---

## 1. Motivation

### 1.1 Liquidation Risk and Capital Inefficiency in DeFi

Automated liquidations are foundational to DeFi lending protocols. While effective for protocol solvency, liquidations impose severe costs on borrowers:

- Forced asset sales at a discount
- Slippage during volatile market conditions
- Cascading liquidations that amplify systemic stress

To avoid liquidation, borrowers are forced to maintain **inefficiently high overcollateralization**, resulting in large amounts of idle capital locked in lending protocols.

Borrowers today face a limited choice set:

- Maintain excess collateral permanently
- Monitor positions continuously and intervene manually
- Refinance or close positions to free capital

None of these options allow borrowers to _temporarily substitute collateral_ or market-price short-term liquidation risk.

---

### 1.2 Limitations of Existing Risk Solutions

Most existing DeFi risk products focus on:

- **Post-event compensation** (insurance, coverage protocols)
- **Derivatives and hedging** (options, perps)
- **Protocol-wide risk buffers** (safety modules, surplus buffers)

These approaches do **not**:

- Improve the real-time health of a specific loan
- Enable collateral withdrawal without increasing liquidation risk
- Allow third-party capital to supply time-bound, loan-specific buffers

There is no native primitive for borrowers to _rent collateral_ or _outsource first-loss exposure_ for a defined period of time.

---

## 2. Core Concept: Liquidation Buffers

Liquidax enables borrowers to attach **Liquidation Buffers** to existing loans.

A Liquidation Buffer consists of **underwriter-supplied collateral** that:

- Is locked for a fixed duration
- Is non-withdrawable by the borrower
- Is junior to borrower collateral
- Is consumed first during liquidation
- Directly improves loan health metrics while active

Crucially, Liquidation Buffers can be used to:

- Increase liquidation resistance **or**
- Allow borrowers to safely withdraw a portion of their own collateral while maintaining equivalent risk

Liquidation Buffers exist only while third-party collateral remains locked. There are:

- No insurance claims
- No borrower payouts
- No principal guarantees for underwriters

---

## 3. Roles in the Liquidax Protection Market

### 3.1 Borrower

- Opens a loan via a lending protocol or CDP
- Attaches a Liquidation Buffer of chosen size and duration
- Pays a one-time, upfront protection fee
- May withdraw some of their own collateral while maintaining loan health
- Benefits from time-bound liquidation resistance and improved capital efficiency

---

### 3.2 Underwriter

- Supplies collateral to form Liquidation Buffers for specific loans
- May enter at any time while the buffer is active
- Cannot withdraw collateral until buffer expiry
- Earns borrower-paid fees over time
- Bears explicit first-loss liquidation and market price risk

Underwriters may lose some or all supplied collateral, even if the loan is not fully liquidated, due to mark-to-market exposure or partial buffer consumption.

---

### 3.3 Challenger

- Stakes capital against loan survival during the buffer period
- Provides adversarial price discovery and risk signaling
- Loses entire stake if the loan remains solvent
- Receives escrowed underwriter reward capital if liquidation occurs

Challengers function as short sellers of loan survival rather than insurers or liquidators.

---

### 3.4 Oracle / Integration Layer

- Reports liquidation events and timing
- Reports partial or full buffer collateral consumption
- Implemented by lending protocols or smart wallets

---

## 4. System Architecture

### 4.1 Separation of Concerns

Liquidax **does not implement lending, debt issuance, or liquidation execution**.

It coordinates only:

- Protection markets
- Capital commitments
- Fee accrual and settlement
- Outcome-based redistribution

Loan accounting, pricing, and liquidation enforcement remain entirely with integrated protocols or wallets.

---

### 4.2 Integration Responsibilities

Integrators must:

- Recognize Liquidation Buffers as valid junior collateral
- Prevent borrower access to buffer collateral
- Enforce priority consumption of buffer collateral
- Apply buffer expiry and decay
- Report liquidation and partial-consumption outcomes

---

## 5. Collateral Waterfall

Upon liquidation:

1. Liquidation Buffer collateral is consumed first
2. Borrower collateral is consumed next
3. Remaining shortfall becomes protocol bad debt

Liquidax redistributes _first-loss exposure_ but does not eliminate systemic risk or protocol insolvency.

---

## 6. Loan Health Accounting

Let:

- `C_user` = borrower collateral
- `C_buffer` = liquidation buffer collateral
- `D` = outstanding debt

```
Effective Collateral Ratio (ECR) = (C_user + C_buffer) / D
```

Liquidation Buffer collateral contributes fully to loan health metrics while active and remains exposed to market price changes.

---

## 7. Liquidation Buffer Lifecycle

### 7.1 Activation

- Borrower selects buffer size and fixed duration
- Borrower pays a one-time protection fee upfront
- Underwriters lock collateral as they enter
- Buffer parameters are immutable per unit of collateral
- Loan accounting is updated

---

### 7.2 Active Period

- Buffer improves loan health
- Borrowers may withdraw some of their own collateral
- Underwriters:
  - Cannot withdraw collateral
  - Accrue fees from time of entry onward
- Challengers may enter at any time

---

### 7.3 Expiry and Decay

- Buffer contribution decays during a final window
- Buffer is progressively removed from loan health metrics
- At expiry:
  - Remaining buffer collateral becomes withdrawable
  - Final fee settlement occurs

Loan survival does **not** imply underwriter principal preservation.

---

## 8. Fee Accrual and Distribution

### 8.1 Time-Weighted Fee Accrual

Let:

- `F_total` = total protection fee
- `T` = buffer duration
- `t` = elapsed active time

```
F_accrued(t) = F_total × (t / T)
```

Unaccrued fees are forfeited if liquidation occurs early.

---

### 8.2 Collateral-Weighted Allocation

For underwriter `i`:

- `C_i` = supplied collateral
- `τ_i` = time active

```
W_i = C_i × τ_i
```

```
F_i = F_accrued × (W_i / Σ W)
```

Late-entering underwriters receive no retroactive fees and bear proportionally higher risk.

---

## 9. Underwriter Commitment Model

- Open-entry while buffer is active
- Immediate and non-revocable capital lock
- No early withdrawal
- Deterministic borrower protection once active

---

## 10. Challenger Economics

- Challenger stakes are fully at risk
- Upside is capped by escrowed underwriter reward capital
- No protocol-level guarantees or subsidies

---

## 11. Market Pricing

Protection pricing emerges from:

- Loan health at activation
- Asset volatility
- Buffer depth and duration
- Challenger participation

Liquidax imposes no pricing model or oracle of risk.

---

## 12. Risks and Challenges

- Integration risk
- Oracle and accounting risk
- Incentive mispricing
- Systemic market stress

Liquidax redistributes risk; it does not eliminate it.

---

## 13. Design Principles

- Buffers improve real loan health
- Collateral substitution is time-bound
- Risk is explicitly priced and voluntary
- Underwriters bear first-loss exposure
- No insurance semantics or guarantees

---

## 14. Use Cases

- Borrowers unlocking collateral without increasing risk
- Temporary liquidation resistance during volatility
- DAO and treasury capital efficiency
- Smart wallets with buffered UX
- Protocols outsourcing risk pricing

---

## 15. Conclusion

Liquidax introduces **Liquidation Buffers** and **Protection Markets** as a new on-chain risk primitive. By enabling market-priced, time-bound collateral reinforcement and substitution without altering core lending logic, Liquidax improves borrower capital efficiency, enables explicit risk transfer, and remains fully composable across the DeFi stack.
