# RelicsAirdropBatch – ERC20 Token with Vesting & Batch Distribution

This repository contains a Solidity smart contract that implements:

- An **ERC20 token** called **RelicsAirdropBatch (RAB)** with fixed supply of 5,000,000 tokens.
- A **claim system** for users to receive an airdrop with vesting schedule.
- An **owner batch transfer function** to release vested tranches for all participants with a single transaction.

The design ensures simplicity:
- **Users only click `claim()`** once to join the airdrop and start vesting.
- **Owner only clicks `transferBatch()`** to release all pending tranches automatically.
- No need for manual input of numbers by either users or owner.

---

## Features

- **Token**: RelicsAirdropBatch (RAB), 18 decimals, fixed supply 5,000,000 RAB.
- **Airdrop allocation per user**: 25,000 RAB.
- **Initial release**: 10,000 RAB immediately on claim.
- **Vesting release**: 5,000 RAB every 1 hour until 25,000 total is reached.
- **Owner fee**: 5% is deducted on each release and sent to the owner automatically.
- **Batch transfer**: The owner distributes pending tranches for all participants in one click.

---

## Contract

File: [`RelicsAirdropBatch.sol`](./RelicsAirdropBatch.sol)  
Solidity version: **0.8.30**  

---

## Deployment Guide

1. Open [Remix IDE](https://remix.ethereum.org/).
2. Create a new file `RelicsAirdropBatch.sol` and paste the contract code.
3. Select **Solidity Compiler** → version `0.8.30` → enable **Optimizer**.
4. Deploy the contract (constructor takes no arguments).
5. After deployment:
   - The **owner** (deployer) automatically receives 5,000,000 RAB.
   - Users can now call `claim()` to start their vesting.
   - Owner can call `transferBatch()` to release tranches for all users at once.

---

## Usage

- **User**:
  - Call `claim()` → receive 10,000 RAB instantly.
  - Remaining 15,000 RAB will be released in 3 tranches of 5,000 RAB every 1 hour.
- **Owner**:
  - Call `transferBatch()` → all users who are due for release will receive their tokens automatically.
  - A 5% fee from each release is transferred to the owner’s balance.

---

## Example

- Alice calls `claim()`.
  - She gets 9,500 RAB instantly (10,000 minus 5% fee).
  - Vesting record created for 15,000 RAB remaining.
- After 1 hour, owner calls `transferBatch()`.
  - Alice receives 4,750 RAB (5,000 minus 5% fee).
- This continues until her 25,000 RAB allocation is complete.

---

## License

MIT License.  
Feel free to fork and build upon this project.

