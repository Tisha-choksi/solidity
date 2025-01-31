# IDO Sale Smart Contract  

## Overview  
This repository contains the **IDOSale** smart contract, which facilitates an **Initial DEX Offering (IDO)** for an **ERC-20** token. The contract allows users to purchase tokens using ETH at a predefined rate while enforcing purchase limits and time constraints. It also enables the owner to manage the IDO lifecycle and withdraw funds.  

---

## Features  
- **Token Sale:** Users can buy tokens using ETH at a fixed rate.  
- **IDO Lifecycle Management:** The owner can start and end the IDO.  
- **Purchase Limits:** Users cannot exceed a predefined maximum purchase amount.  
- **Time Constraints:** The IDO runs only within a specified start and end time.  
- **Fund Withdrawal:** The contract owner can withdraw collected ETH.  
- **Unsold Token Retrieval:** The owner can reclaim unsold tokens after the IDO ends.  

---

## Contract Details  

### Constructor  
The contract is initialized with the following parameters:  

- `_token`: Address of the ERC-20 token being sold.  
- `_rate`: Number of tokens per **1 ETH**.  
- `_startTime`: IDO start timestamp.  
- `_endTime`: IDO end timestamp.  
- `_maxPurchase`: Maximum tokens a user can buy.  

```solidity
constructor(
    address _token,
    uint256 _rate,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _maxPurchase
)


## Conditions

### Buy Tokens
Users can buy tokens by sending ETH to the contract:

```solidity
function buyTokens() external payable onlyWhileOpen
```

#### ✅ Conditions:
- The IDO must be active.
- Users must send ETH to purchase tokens.
- The purchase amount must not exceed the max purchase limit.
- The contract must have enough tokens available.

### End IDO
The owner can end the IDO when the sale period is over:

```solidity
function endIDO() external onlyOwner
```

#### ✅ Conditions:
- The IDO must be active.
- The current time must be past the end time.

### Withdraw Funds
The owner can withdraw collected ETH after the IDO:

```solidity
function withdrawFunds() external onlyOwner
```

#### ✅ Conditions:
- There must be ETH in the contract.

### Withdraw Unsold Tokens
The owner can retrieve unsold tokens after the IDO ends:

```solidity
function withdrawUnsoldTokens() external onlyOwner
```

#### ✅ Conditions:
- Unsold tokens must be present in the contract.

## Events
The contract emits events for tracking IDO progress:

```solidity
event TokenPurchased(address indexed buyer, uint256 amount);
event IDOStarted(uint256 startTime, uint256 endTime);
event IDOEnded();
```

## Deployment Instructions

### Prerequisites
Ensure you have the following installed:
- Node.js & npm
- Hardhat or Truffle
- MetaMask (or any Ethereum wallet)
- OpenZeppelin Contracts

### Deploy the Contract

#### Install dependencies:
```bash
npm install
```

#### Compile the contract:
```bash
npx hardhat compile
```

#### Deploy using Hardhat:
```javascript
const IDOSale = await ethers.getContractFactory("IDOSale");
const idoSale = await IDOSale.deploy(
    "TOKEN_CONTRACT_ADDRESS",
    1000, 
    START_TIMESTAMP, 
    END_TIMESTAMP, 
    MAX_PURCHASE_AMOUNT
);
```

#### Verify deployment:
```bash
npx hardhat verify --network <network> DEPLOYED_CONTRACT_ADDRESS TOKEN_ADDRESS RATE START_TIME END_TIME MAX_PURCHASE
```

## Usage

### Buy Tokens
Send ETH to the contract from your wallet:
```solidity
idosale.buyTokens({ value: ethers.utils.parseEther("1") });
```

### Start IDO
```solidity
idosale.startIDO();
```

### End IDO
```solidity
idosale.endIDO();
```

### Withdraw Funds
```solidity
idosale.withdrawFunds();
```

### Withdraw Unsold Tokens
```solidity
idosale.withdrawUnsoldTokens();
```

## Security Considerations
- The contract only allows purchases during the active IDO period.
- The owner can withdraw funds but not before IDO completion.
- Reentrancy protection and proper access control are ensured.

## License
This project is licensed under the MIT License.
