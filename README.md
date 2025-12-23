# Protection Markets Protocol

## Overview

This repository implements the Protection Markets Protocol, a new DeFi primitive for temporary, third-party collateralization of on-chain loans. Instead of providing insurance payouts after adverse events, the protocol enables pre-emptive risk reduction by allowing external underwriters to supply collateral that directly increases a loan’s effective collateralization for a fixed period.

## Key Features

- **Pre-emptive Risk Reduction:** Borrowers can purchase liquidation resistance, improving loan health metrics for a chosen duration.
- **Open Market Pricing:** Protection is priced by open market participation between borrowers, underwriters, and challengers.
- **Modular & Non-custodial:** Designed to integrate with existing CDP and lending systems without taking custody of user funds.
- **No Insurance Claims:** There are no insurance claims or payouts to borrowers; protection exists only while third-party collateral is present.

## Roles

- **Borrower:** Purchases protection to improve loan safety and pays a time-based fee.
- **Underwriter:** Supplies capital to back specific loans, earning fees and taking on liquidation risk.
- **Challenger:** Stakes against loan survival, providing adversarial price discovery and earning rewards if the loan is liquidated.
- **Oracle/Adapter:** Reports liquidation events from the underlying lending protocol.

## How It Works

1. **Borrowers** open a loan and purchase protection for a set period.
2. **Underwriters** supply collateral, which is locked and junior to borrower collateral, directly improving the loan’s health.
3. **Challengers** stake against the loan’s survival, earning rewards if the loan is liquidated during the protection period.
4. **Oracles** report liquidation events, triggering settlement logic.

## Capital Structure

- Underwriter capital is split into:
  - **Collateral Tranche:** Improves loan health and earns borrower fees.
  - **Reward Tranche:** Escrowed for challenger settlement, does not improve loan health, and earns challenger stakes if the loan survives.

## Integration

The protocol is designed to be integrated with existing lending protocols via adapters or native support. It does not implement lending logic itself.

## More Information

For detailed protocol mechanics, motivation, and lifecycle, see [WHITEPAPER.md](WHITEPAPER.md).
