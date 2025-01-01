# Polyblade Staking Contract

## Overview
Polyblade is a staking smart contract built using Solidity. The contract is based on the ERC20 token standard and includes features for staking, claiming rewards, and withdrawing staked tokens. This project leverages OpenZeppelin’s libraries for security and modularity.

## Features
- **ERC20 Token:** Implements a token named `Polyblade` with the symbol `PBD`.
- **Staking Mechanism:** Users can stake their tokens for a specified lock-up period.
- **Rewards:** Users earn rewards based on the duration of their staking.
- **Penalty for Early Withdrawal:** A 5% penalty fee is applied if tokens are unstaked before the lock-up period ends.
- **Admin Control:** Admin has the ability to mint and distribute tokens.

---

## Smart Contract Details

### Contract Information
- **Contract Name:** `Stake`
- **Token Name:** Polyblade (`PBD`)
- **Compiler Version:** ^0.8.13
- **Libraries Used:** OpenZeppelin (
  - `ERC20` for token standard implementation.
  - `Ownable` for access control.
  - `ERC20Permit` for gasless approvals.)

### Constructor
```solidity
constructor(address admin, uint256 mintAmount)
```
- Initializes the contract with an admin address and mints a specified amount of tokens to the contract's address.

### Mappings
- `mapping(address => uint256) stakedTS`: Tracks the timestamp of the staking action for each user.
- `mapping(address => uint256) staked`: Tracks the amount staked by each user.
- `mapping(address => uint256) timeOfLockUp`: Tracks the lock-up duration for each user.

### Functions

#### **1. requestToken**
```solidity
function requestToken(uint256 amount) public onlyOwner
```
- Allows the owner to withdraw tokens from the contract to their own address.

#### **2. stake**
```solidity
function stake(uint256 amount, uint256 time_months) external
```
- Allows users to stake a specific amount of tokens for a lock-up period measured in months.
- Claims existing rewards before adding new tokens to the staking balance.

#### **3. unStake**
```solidity
function unStake(uint256 amount, uint256 durationOfLockUp) external
```
- Allows users to withdraw staked tokens.
- Applies a penalty fee if the withdrawal occurs before the lock-up period ends.
- Transfers the remaining tokens back to the user after deducting the penalty (if applicable).

#### **4. reward**
```solidity
function reward(address user) public view returns (uint256)
```
- Calculates the staking reward based on the user’s staking duration.
- Rewards are accrued at an annual rate of 50%.

#### **5. claim**
```solidity
function claim() public
```
- Allows users to claim accrued rewards for their staked tokens.
- Mints new tokens as rewards to the user’s address.

---

## How to Use

### 1. Deployment
- Deploy the contract with the admin address and the initial token supply:
  ```solidity
  constructor(address admin, uint256 mintAmount)
  ```

### 2. Staking
- Call the `stake` function to stake tokens:
  ```solidity
  stake(uint256 amount, uint256 time_months);
  ```

### 3. Claim Rewards
- Use the `claim` function to mint and collect rewards:
  ```solidity
  claim();
  ```

### 4. Unstaking
- Call the `unStake` function to withdraw tokens:
  ```solidity
  unStake(uint256 amount, uint256 durationOfLockUp);
  ```

---

## Penalty Fee Calculation
- **Penalty Fee:** 5% of the unstaked amount.
- Penalty applies if the withdrawal occurs before the lock-up period ends.

---

## Reward Calculation
- **Annual Rate:** 50%
- Rewards are calculated based on the staked amount and duration.

---

## Security Features
- **Ownership:** Only the admin can mint tokens.
- **Safe Transfers:** Utilizes OpenZeppelin’s `ERC20` for secure token transfers.

---

## Installation and Testing

1. Install dependencies:
   ```bash
   npm install @openzeppelin/contracts
   ```

2. Compile the contract using your preferred development environment (e.g., Hardhat or Foundry).

3. Deploy the contract on a local or test network.

4. Interact with the contract using scripts or a frontend interface.


