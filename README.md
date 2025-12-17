# Protection Markets Protocol

## Overview

The Protection Markets Protocol is a set of smart contracts that enables wallet providers and protocol developers to create decentralized protection markets for loans. **The protocol itself does not provide CDP (Collateralized Debt Position) functionality, but is designed to be integrated directly by CDP or wallet platforms.** It introduces a market-driven approach to risk and pricing, allowing users to hedge against liquidation risk while enabling others to participate as challengers or underwriters.

## How It Works

1. **Loan Origination**: Users open a loan using a Collateralized Debt Position (CDP).
2. **Protection Purchase**: When opening a loan, users can optionally purchase protection by paying an upfront fee to the Protection Market Protocol and specifying the duration for which the protection is active.
3. **Market Participation**:
   - **Challengers**: Anyone can become a challenger by betting that the loan will be liquidated before the protection period ends.
   - **Underwriters**: Anyone can become an underwriter by adding collateral to protect the user's loan. Underwriters are betting that the loan will _not_ be liquidated within the protection period.

## Roles

- **User**: Opens a loan and optionally purchases protection.
- **Challenger**: Bets on the liquidation of the loan within the protection period.
- **Underwriter**: Provides additional collateral to protect the loan, betting against liquidation.

## Settlement Logic

- If the loan is liquidated before the protection period ends:
  - Challengers win the bet.
  - A percentage of the underwriters' collateral is distributed among the challengers, along with the user's upfront protection fee.
- If the loan is _not_ liquidated before the protection period ends:
  - Underwriters win the bet.
  - Challengers lose their deposit, which is distributed to the underwriters.
- If the combined collateral (user + underwriter) falls below a threshold set by external protocols, underwriters lose their collateral.

## Key Advantages

- **Market-Driven Risk & Pricing**: The protocol allows the market to determine risk and pricing, rather than relying on centralized or static models.
- **Open Participation**: Anyone can become a challenger or underwriter, increasing liquidity and decentralization.
- **Flexible Protection**: Users can customize protection duration and coverage based on their needs.

## Example Flow

1. Alice opens a loan and pays a fee to activate protection for 30 days.
2. Bob becomes a challenger, betting that Alice's loan will be liquidated within 30 days.
3. Carol becomes an underwriter, adding collateral to protect Alice's loan.
4. If Alice's loan is liquidated within 30 days, Bob and other challengers share a portion of Carol's collateral and Alice's fee. If not, Carol and other underwriters receive Bob's deposit.

---

This protocol is designed to be modular and composable, enabling integration with various DeFi lending and borrowing platforms.
