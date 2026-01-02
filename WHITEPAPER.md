# Liquidax: Liquidation Buffers and Protection Markets for On-Chain Loan Safety

**Author:** Sridhar G (<sridharg@protonmail.com>)

---

## Abstract

**Liquidax** introduces a new DeFi risk primitive: **Liquidation Buffers**, supplied through open **Protection Markets**.

Instead of compensating borrowers after liquidations, Liquidax enables **pre-emptive risk reduction and capital efficiency** by allowing third-party capital to temporarily reinforce — and partially substitute — the collateral backing of individual on-chain loans.

Through Liquidax, borrowers can purchase **time-bound liquidation resistance or withdrawal capacity**, priced by the market, without increasing protocol risk. Underwriters earn yield by supplying junior, first-loss collateral buffers. Optional challengers improve adversarial price discovery by staking against loan survival.

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

None of these options allow borrowers to **temporarily substitute collateral** or **market‑price short‑term liquidation risk**.

---

### 1.2 Limitations of Existing Risk Solutions

Most existing DeFi risk products focus on:

- **Post‑event compensation** (insurance, coverage protocols)
- **Derivatives and hedging** (options, perpetuals)
- **Protocol‑wide buffers** (safety modules, surplus funds)

These approaches do **not**:

- Improve the real‑time health of a specific loan
- Enable collateral withdrawal without increasing liquidation risk
- Allow third‑party capital to provide time‑bound, loan‑specific buffers

There is no native primitive for borrowers to **rent collateral capacity** or **outsource first‑loss exposure** for a defined period.

---

## 2. Core Concept: Liquidation Buffers

Liquidax enables borrowers to attach **Liquidation Buffers** to existing loans.

A Liquidation Buffer consists of **underwriter‑supplied collateral** that:

- Is locked for a fixed duration
- Is non‑withdrawable by the borrower
- Is junior to borrower collateral
- Is consumed first during liquidation
- Is fully counted in loan health metrics while active

Liquidation Buffers exist only while third‑party collateral remains locked. There are:

- No insurance claims
- No borrower payouts
- No principal guarantees for underwriters

---

## 3. Capital Efficiency and Withdrawal Capacity

### 3.1 Collateral Substitution, Not Leverage

Liquidax improves borrower capital efficiency through **collateral substitution**, not leverage.

Let:

- `C_user` = borrower collateral
- `C_buffer` = active buffer collateral
- `D` = outstanding debt

```
Effective Collateral Ratio (ECR) = (C_user + C_buffer) / D
```

A borrower may reduce `C_user` **only up to the amount replaced by `C_buffer`**, while maintaining the same ECR and liquidation probability.

This allows borrowers to:

- Free capital temporarily
- Maintain equivalent liquidation risk
- Pay a known, time‑bounded fee instead of permanently locking assets

---

### 3.2 Withdrawal Capacity as a Market Outcome

Borrowers do **not** choose how much collateral they can safely withdraw.

Instead:

- Borrowers specify a **price** (upfront fee `x`) and duration `T`
- Underwriters decide **how much buffer collateral** to supply
- The protocol enforces a **maximum withdrawable amount** derived from active buffers

```
MaxWithdrawable ≤ C_buffer × (1 − safety_haircut)
```

If the market supplies less buffer collateral than expected, withdrawal capacity is reduced accordingly.

Withdrawal is **optional**. Buffers represent **capacity**, not an obligation.

---

### 3.3 Enforced Withdrawal Invariant

At all times:

> **Borrower withdrawals are capped such that loan health never exceeds the risk priced by underwriters at entry.**

Any withdrawal that would violate required loan health metrics is deterministically rejected by protocol or smart‑wallet logic.

---

## 4. Roles in the Liquidax Protection Market

### 4.1 Borrower

- Opens a loan via a lending protocol or smart wallet
- Purchases a liquidation buffer by paying an upfront fee
- Gains time‑bound liquidation resistance and/or withdrawal capacity
- May choose not to withdraw any collateral

---

### 4.2 Underwriter

- Supplies buffer collateral to specific loans
- Prices risk **at entry time**
- Locks capital for the agreed duration
- Earns fees proportional to capital × time at risk
- Bears explicit first‑loss liquidation risk

Underwriters may lose part or all of their collateral via liquidation events.

---

### 4.3 Challenger (Optional)

- Stakes capital against loan survival during the buffer period
- Improves adversarial price discovery and risk signaling
- Does not supply collateral or provide protection

Challengers are optional and not required for core functionality.

---

### 4.4 Oracle / Integration Layer

- Reports liquidation events and timing
- Reports partial or full buffer collateral consumption
- Implemented by lending protocols or smart wallets

---

## 5. System Architecture

### 5.1 Separation of Concerns

Liquidax **does not implement lending, debt issuance, or liquidation execution**.

It coordinates only:

- Protection markets
- Capital commitments
- Fee accrual and settlement
- Outcome‑based redistribution

Loan accounting, pricing, and liquidation enforcement remain with integrated protocols or wallets.

---

### 5.2 Integration Responsibilities

Integrators must:

- Recognize Liquidation Buffers as valid junior collateral
- Prevent borrower access to buffer collateral
- Enforce priority consumption of buffer collateral
- Apply buffer expiry and decay
- Report liquidation and partial‑consumption outcomes

---

## 6. Collateral Waterfall

Upon liquidation:

1. Liquidation Buffer collateral is consumed first
2. Borrower collateral is consumed next
3. Remaining shortfall becomes protocol bad debt

Liquidax redistributes **first‑loss exposure** but does not eliminate systemic risk.

---

## 7. Liquidation Buffer Lifecycle

### 7.1 Activation

- Borrower pays upfront fee
- Underwriters lock collateral
- Buffer parameters are immutable per unit of collateral

### 7.2 Active Period

- Loan health improves
- Withdrawal capacity is enforced
- Fees accrue over time

### 7.3 Expiry and Decay

- Buffer contribution decays before expiry
- Withdrawal capacity shrinks smoothly
- Remaining collateral becomes withdrawable by underwriters

Loan survival does **not** imply underwriter principal preservation.

---

## 8. Fee Accrual and Distribution

### 8.1 Time‑Weighted Fee Accrual

```
F_accrued(t) = F_total × (t / T)
```

If liquidation or early repayment occurs:

- Accrued fees are paid to underwriters
- Unaccrued fees are returned to the borrower

---

### 8.2 Capital × Time Allocation

For underwriter `i`:

```
W_i = C_i × τ_i
F_i = F_accrued × (W_i / ΣW)
```

This ensures:

- No retroactive dilution
- Fair compensation for early risk
- Late entrants earn fees only for remaining exposure

---

## 9. Market Pricing

Protection pricing emerges from:

- Loan health at activation
- Asset volatility
- Buffer depth and duration
- Challenger participation (if enabled)

Liquidax imposes no pricing model or oracle of risk.

---

## 10. Risks and Challenges

- Integration and accounting risk
- Oracle risk
- Incentive mispricing
- Systemic market stress

Liquidax redistributes risk; it does not eliminate it.

---

## 11. Design Principles

- Buffers improve real loan health
- Collateral substitution is time‑bound
- Risk is explicitly priced and voluntary
- Underwriters bear first‑loss exposure
- No insurance semantics or guarantees

---

## 12. Use Cases

- Borrowers unlocking collateral without increasing risk
- Temporary liquidation resistance during volatility
- DAO and treasury capital efficiency
- Smart wallets with buffered UX
- Protocols outsourcing risk pricing

---

## 13. Conclusion

Liquidax introduces **Liquidation Buffers** and **Protection Markets** as a new on‑chain risk primitive.

By enabling market‑priced, time‑bound collateral reinforcement and substitution without altering core lending logic, Liquidax improves borrower capital efficiency, enables explicit risk transfer, and remains fully composable across the DeFi stack.
