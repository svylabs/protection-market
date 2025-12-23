# Protection Markets Protocol

## Abstract

The Protection Markets Protocol introduces a new DeFi primitive: a **market for temporary, third-party collateral that improves the health of on-chain loans**. Rather than providing insurance payouts after adverse events, the protocol enables _pre-emptive risk reduction_ by allowing external underwriters to supply collateral that directly increases a loan’s effective collateralization for a fixed period of time.

Protection is priced by open market participation. Borrowers can purchase liquidation resistance, underwriters earn yield for supplying downside collateral, and challengers provide adversarial price discovery by staking against loan survival. The protocol is modular, non-custodial, and designed to integrate directly with lending protocols and wallets that manage loan accounting and liquidation logic.

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
- Is non-withdrawable by the borrower
- Is consumed first in liquidation
- Directly improves loan health metrics

Protection exists only while third-party collateral is present. There are **no insurance claims and no payouts to borrowers**, and underwriter principal is not guaranteed.

---

## 3. Roles

### 3.1 Borrower

- Opens a loan via a CDP or lending protocol
- Purchases protection for a chosen duration
- Pays a time-based protection fee
- Benefits from improved liquidation resistance

### 3.2 Underwriter

- Supplies collateral to back a specific loan
- Earns borrower-paid fees for providing liquidation resistance
- Bears the risk of collateral loss due to liquidation **or adverse price movements**

### 3.3 Challenger

- Stakes capital against the loan surviving the protection period
- Provides adversarial price discovery
- Receives underwriter reward capital if liquidation occurs
- Loses stake if the loan remains solvent

### 3.4 Oracle / Adapter

- Reports liquidation outcomes and collateral accounting data
- May be implemented natively by the CDP or by an external oracle / adapter

---

## 4. System Architecture

### 4.1 Integration Assumptions

The Protection Markets Protocol **does not implement lending logic or loan accounting**.

Instead, it assumes integration with:

- CDP / lending protocols, or
- Smart wallets managing loan positions

These integrators are responsible for:

- Recognizing protection collateral as valid collateral
- Excluding protection collateral from borrower withdrawals
- Enforcing junior priority of protection collateral in liquidation
- Applying protection expiry and decay rules
- Exposing liquidation and collateral consumption data

The protocol itself only coordinates markets, capital flows, and settlement.

---

### 4.2 Liquidation and Accounting Data Requirements

For correct settlement, integrations **must provide reliable accounting data**, either directly from the lending protocol or via an oracle.

Required data includes:

- Whether a loan was liquidated or not
- Timestamp or block number of liquidation (if any)
- Whether liquidation was partial or full
- Amount of protection collateral consumed
- Remaining protection collateral value at expiry

---

### 4.3 Integration Models

Supported integration approaches include:

- **Native CDP Integration**  
  Lending protocols natively support protection collateral as a distinct collateral class and emit finalized liquidation events.

- **Smart Wallet Integration**  
  Wallets manage loan sub-accounts where protection collateral is visible to liquidation logic but inaccessible to the borrower.

- **Adapter-Based Integration**  
  External contracts index protocol events, apply protocol-specific rules, and relay finalized liquidation and accounting states.

---

## 5. Collateral Waterfall

Upon liquidation:

1. Protection collateral is consumed first
2. Borrower collateral is consumed next
3. Any remaining shortfall becomes protocol bad debt

This junior structure is essential for correct risk pricing.

---

## 6. Loan Health Accounting

Let:

- `C_user` = borrower collateral
- `C_protect` = protection collateral
- `h` = haircut on protection collateral
- `D` = debt

Effective collateralization ratio:

```
ECR = (C_user + h × C_protect) / D
```

Protection collateral contributes to loan health only while active and remains subject to market price fluctuations.

---

## 7. Protection Lifecycle

### 7.1 Activation

- Borrower selects duration and pays a time-based fee `F`
- Underwriters supply collateral
- Integrator updates loan accounting to include protection collateral

### 7.2 During Protection

- Protection collateral improves loan health
- Underwriters cannot withdraw collateral
- Borrowers cannot withdraw protection collateral
- Challengers may stake within defined entry windows

### 7.3 Expiry and Post-Expiry Accounting

- Protection contribution decays during a final window
- Integrator removes protection collateral from loan health accounting
- Underwriters reclaim remaining protection collateral, **if any**

Even if the loan is not liquidated:

- Protection collateral may be partially or fully consumed
- Collateral value may decline due to adverse price movements
- Underwriters bear this market risk while still earning borrower fees and challenger stakes

Loan survival does not imply underwriter principal preservation.

---

## 8. Fee Allocation

Borrower-paid protection fees `F` are distributed **exclusively to underwriters supplying protection collateral**.

```
All borrower fees → protection collateral providers (pro-rata)
```

Fees accrue linearly over the protection period.

---

## 9. Settlement Logic

### 9.1 No Liquidation

If the loan is not liquidated:

- Underwriters recover remaining protection collateral (if any)
- Underwriters receive accrued borrower fees
- Underwriters receive challenger stakes

---

### 9.2 Liquidation During or After Protection

If liquidation occurs:

- Protection collateral is consumed according to liquidation rules
- Borrower collateral is liquidated next
- Underwriters may lose part or all of their collateral
- Challenger reward capital is distributed according to market rules

Borrowers receive no payout.

---

## 10. Challenger Economics

Challengers act as **short sellers of loan survival**.

- Downside: loss of stake if no liquidation
- Upside: claim on underwriter reward capital if liquidation occurs

To limit leverage:

```
Total challenger stake ≤ β × underwriter reward capital
```

Where `β` is protocol-defined.

---

## 11. Market Pricing

Protection pricing emerges from open participation based on:

- Loan health at entry
- Asset volatility
- Protection duration
- Protection depth
- Challenger pressure

The protocol does not impose pricing models.

---

## 12. Challenges and Open Risks

### 12.1 Integration Challenges

- Lending protocols differ significantly in collateral accounting, withdrawal rules, and liquidation mechanics.
- Supporting non-withdrawable, junior protection collateral requires explicit protocol or wallet-level cooperation.
- Adapter-based integrations may introduce additional trust assumptions.

### 12.2 Oracle and Accounting Risk

- Accurate reporting of collateral consumption and remaining value is required.
- Oracle delays, reorgs, or inconsistent liquidation definitions may lead to incorrect settlement.
- Partial consumption without liquidation introduces additional accounting complexity.

### 12.3 Incentive and Market Risks

- Underwriters face both liquidation risk and market price risk.
- Thin markets may result in mispriced protection.
- Challenger manipulation must be mitigated through caps and timing rules.

### 12.4 Systemic Risk

- Correlated price crashes may cause widespread protection losses.
- Protection markets redistribute risk but do not eliminate systemic exposure.

---

## 13. Design Principles

- Protection improves real loan health
- Underwriters bear explicit market and liquidation risk
- Fees follow capital at risk
- No insurance claims
- Market-priced liquidation risk

---

## 14. Use Cases

- Borrowers seeking temporary liquidation resistance
- Wallets offering liquidation-resistant UX
- Protocols outsourcing liquidation risk pricing
- Risk dashboards surfacing adversarial sentiment

---

## 15. Conclusion

The Protection Markets Protocol introduces a new DeFi risk primitive: **market-priced, temporary collateral protection**. By separating protection markets from loan accounting and supporting multiple integration models, the protocol enables safer borrowing while preserving composability, transparency, and open risk pricing.
