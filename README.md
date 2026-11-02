# GPA Vault

**Decentralised Academic Credential Protocol on Botchain**

## Contents

| File | Description |
|------|-------------|
| `index.html` | Full single-file web app — landing page, registration, calculator, dashboard, on-chain tab |
| `GPAVault.sol` | Solidity ^0.8.20 smart contract — deploy on Botchain (chain ID 677) |
| `GPA_Vault_Whitepaper.pdf` | Technical whitepaper v1.0 |

## Quick Start

### 1 — Deploy the contract
```bash
forge create GPAVault.sol:GPAVault \
  --rpc-url <BOTCHAIN_RPC> \
  --private-key <YOUR_PK>
```
Copy the deployed address.

### 2 — Configure the app
Open `index.html` in any browser.  
Go to **On-Chain → Configuration** and paste:
- Botchain RPC URL
- Deployed contract address

### 3 — Register
Click **Get Started** on the landing page, connect MetaMask, fill in your name / matric number / institution, and sign the `register()` transaction.

### 4 — Calculate & anchor
Add semesters and courses in the **Calculator** tab, then go to **On-Chain → Store GPA Hash** to anchor your SHA-256 hash on Botchain.

### 5 — Verify
Anyone can call `verifyRecord(address, hash)` from the **On-Chain** tab — no wallet needed for reads.

## Contract ABI (key functions)
```
register(name, matricNo, institution)   → external
storeRecord(bytes32 dataHash, label)    → external (must be registered)
isRegistered(address)                   → view → bool
getStudent(address)                     → view → (name, matricNo, institution, registeredAt)
verifyRecord(address, bytes32)          → view → (found, timestamp)
```

## License
MIT
# Kilogba
