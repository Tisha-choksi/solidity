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
