# Protection Markets Protocol

## Abstract

The Protection Markets Protocol introduces a new DeFi primitive: a **market for temporary, third-party collateral that improves the health of on-chain loans**. Rather than providing insurance payouts after adverse events, the protocol enables _pre-emptive risk reduction_ by allowing external underwriters to supply collateral that directly increases a loan’s effective collateralization for a fixed period of time.

Protection is priced by open market participation. Borrowers can purchase liquidation resistance, underwriters earn yield for supplying downside collateral, and challengers provide adversarial price discovery by staking against loan survival. The protocol is modular, non-custodial, and designed to integrate directly with existing CDP and lending systems.

---

## 1. Motivation

### 1.1 Liquidation Risk in DeFi

Collateralized lending protocols rely on automated liquidations to maintain solvency. While effective for protocol safety, liquidations impose significant costs on borrowers:

- Forced sale penalties
- Slippage during volatile markets
- Cascading liquidations that amplify systemic stress

Borrowers today have only two options:

- Over-collateralize inefficiently
- Monitor positions continuously and react manually

### 1.2 Limitations of Existing Solutions

Current DeFi risk solutions focus on _post-event compensation_ (insurance, hedging) or _protocol-level parameter tuning_. These approaches do not:

- Improve the real-time health of a specific loan
- Allow market pricing of liquidation risk
- Enable third parties to supply temporary downside capital

There is no native mechanism for borrowers to **buy additional collateral backing from the market**.

---

## 2. Core Concept

The Protection Markets Protocol enables a borrower to temporarily increase the safety of a loan by purchasing protection from an open market.

Protection takes the form of **underwriter-supplied collateral** that:

- Is locked for a fixed duration
- Is junior to borrower collateral
- Is consumed first in liquidation
- Directly improves loan health metrics

Protection exists only while third-party collateral is present. There are **no insurance claims and no payouts to borrowers**.

---

## 3. Roles

### 3.1 Borrower

- Opens a loan via a CDP or lending protocol
- Purchases protection for a chosen duration
- Pays a time-based protection fee
- Benefits from improved liquidation resistance

### 3.2 Underwriter

- Supplies capital to back a specific loan
- Chooses how capital is allocated between:
  - collateral that improves loan health, and
  - reward capital that backs challenger settlement
- Earns borrower fees only on capital that improves loan health
- Earns challenger stakes only on capital exposed to challenger settlement
- Loses capital if liquidation occurs

### 3.3 Challenger

- Stakes capital against the loan surviving the protection period
- Receives a conditional claim on underwriter reward capital if liquidation occurs
- Loses stake if the loan remains solvent

Challengers act as adversarial price discovery agents, not insurers or liquidators.

### 3.4 Oracle / Adapter

- Reports finalized liquidation events from the underlying lending protocol
- May be implemented by the CDP itself or by a trusted adapter

---

## 4. System Architecture

### 4.1 Integration Model

The protocol does **not** implement lending logic. It integrates via:

- Native CDP integration (preferred)
- Proxy or adapter contracts

Protection collateral must be explicitly recognized in the liquidation logic of the underlying loan.

---

## 5. Underwriter Capital Structure

Underwriters deposit total capital `U`, which they allocate into two tranches:

```
U = U_collateral + U_reward
```

### 5.1 Collateral Tranche (`U_collateral`)

- Counts (haircutted) toward loan health
- Is consumed first in liquidation
- Bears liquidation shortfall risk
- Earns **borrower-paid protection fees**

### 5.2 Reward Tranche (`U_reward`)

- Does NOT improve loan health
- Is escrowed exclusively to settle challenger positions
- Does NOT earn borrower fees
- Earns **challenger stakes** if the loan survives

The split is chosen by underwriters, subject to protocol-defined minimum collateral requirements.

---

## 6. Loan Health Accounting

Let:

- `C_user` = borrower collateral
- `U_collateral` = underwriter collateral tranche
- `h` = haircut on protection collateral
- `D` = debt
- `L` = liquidation ratio

Effective collateralization ratio:

```
ECR = (C_user + h × U_collateral) / D
```

Only `U_collateral` contributes to loan health.

---

## 7. Protection Lifecycle

### 7.1 Activation

- Borrower selects duration and pays a time-based fee `F`
- Underwriters supply capital and select tranche allocations
- Protection becomes active immediately

### 7.2 During Protection

- `U_collateral` improves loan health
- Underwriters cannot withdraw
- Challengers may stake within defined entry windows

### 7.3 Expiry

- Protection contribution decays during a final window
- Underwriters reclaim unused capital
- Loan health reverts to borrower-only state

---

## 8. Fee Allocation

Borrower protection fees `F` are paid **exclusively to underwriter collateral that contributes to loan health**.

```
All borrower fees → U_collateral providers (pro-rata)
```

- `U_reward` earns **no borrower fees**
- `U_reward` exists solely to back challenger settlement

---

## 9. Settlement Logic

### 9.1 No Liquidation

If the loan remains solvent until protection expiry:

- Underwriters recover:
  - `U_collateral + U_reward`
- Underwriters receive:
  - Borrower fees (pro-rata to `U_collateral`)
  - Challenger stakes (pro-rata to `U_reward`)
- Challengers lose their entire stake

---

### 9.2 Liquidation During Protection

#### Step 1: Loss Absorption

Liquidation shortfall is absorbed by `U_collateral`:

```
Loss = min(U_collateral, liquidation shortfall)
```

#### Step 2: Challenger Settlement

- Entire `U_reward` tranche is transferred to challengers
- Distribution is pro-rata by challenger stake

#### Step 3: Underwriter Outcome

- Loses `Loss` from `U_collateral`
- Loses all of `U_reward`
- Retains borrower fees accrued up to liquidation (protocol-defined)

Borrowers receive no payout.

---

## 10. Challenger Economics

Challengers are economically equivalent to **short positions on loan survival**.

- Downside: loss of stake if no liquidation
- Upside: claim on `U_reward` if liquidation occurs

To limit leverage:

```
Total challenger stake ≤ β × U_reward
```

Where `β` is protocol-defined.

---

## 11. Market Pricing

Protection pricing emerges from:

- Loan health at entry
- Asset volatility
- Duration
- Size of `U_collateral`
- Challenger pressure against `U_reward`

The protocol does not impose pricing models; it exposes transparent risk data.

---

## 12. Risk Mitigations

- Minimum `U_collateral / U` ratios
- Challenger entry cutoffs
- Linear fee accrual
- Protection decay before expiry
- Oracle settlement using finalized liquidation states

---

## 13. Design Principles

- Fees follow protection, not speculation
- No insurance claims
- No pooled guarantees
- No protocol-level leverage
- Explicit, market-priced risk

---

## 14. Use Cases

- Borrowers seeking temporary liquidation resistance
- Wallets offering liquidation-resistant UX
- Protocols outsourcing risk pricing to markets
- Risk dashboards surfacing adversarial sentiment

---

## 15. Conclusion

The Protection Markets Protocol introduces a new DeFi risk primitive: **market-priced, temporary collateral protection with adversarial settlement**. Borrower fees compensate only capital that directly improves loan safety, while challenger markets price tail risk through explicit capital transfer. This separation ensures clean incentives, robust price discovery, and transparent liquidation risk markets.
