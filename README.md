# Cross-Chain Token Bridge

This repository provides a foundational architecture for bridging assets between two EVM-compatible blockchains. It utilizes a secure "Burn/Mint" logic to ensure the total circulating supply across all chains remains constant.

## Mechanism
1. **Source Chain (Deposit):** User calls `bridgeTokens()`, which burns the tokens on the source chain (or locks them in a vault).
2. **Relayer/Validator:** An off-chain service detects the `Deposit` event.
3. **Destination Chain (Mint):** After validation, the bridge contract on the destination chain mints an equivalent amount of tokens to the user's address.

## Security Features
* **Role-Based Access Control:** Only authorized "Minters" or "Relayers" can trigger the minting process.
* **Non-Replayable Transactions:** Each bridge request includes a unique nonce to prevent double-minting.
* **Emergency Stop:** Integrated Pausable functionality to halt bridging in case of network instability.

## File Structure
All core logic is contained in the root directory for a "flat" deployment experience.
