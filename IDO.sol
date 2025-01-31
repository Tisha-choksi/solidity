// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IDOSale is Ownable {
    IERC20 public token; // Token being sold
    uint256 public rate; // Token price (1 ETH = how many tokens)
    uint256 public startTime; // IDO start time
    uint256 public endTime; // IDO end time
    uint256 public tokensSold; // Track number of tokens sold
    uint256 public maxPurchase; // Max tokens per user
    bool public isIDOActive = false; // Status of IDO

    mapping(address => uint256) public contributions; // Store each buyer's contribution

    event TokenPurchased(address indexed buyer, uint256 amount);
    event IDOStarted(uint256 startTime, uint256 endTime);
    event IDOEnded();

    constructor(
        address _token,
        uint256 _rate,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxPurchase
    ) Ownable(msg.sender) {
        require(_startTime < _endTime, "Start time must be before end time");
        require(_rate > 0, "Rate must be greater than 0");

        token = IERC20(_token);
        rate = _rate;
        startTime = _startTime;
        endTime = _endTime;
        maxPurchase = _maxPurchase;
    }

    modifier onlyWhileOpen() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "IDO not active");
        require(isIDOActive, "IDO has not started yet");
        _;
    }

    function startIDO() external onlyOwner {
        require(!isIDOActive, "IDO already started");
        isIDOActive = true;
        emit IDOStarted(startTime, endTime);
    }

    function buyTokens() external payable onlyWhileOpen {
        require(msg.value > 0, "Send ETH to buy tokens");
        uint256 amountToBuy = msg.value * rate;
        require(amountToBuy <= token.balanceOf(address(this)), "Not enough tokens left");
        require(contributions[msg.sender] + amountToBuy <= maxPurchase, "Purchase limit exceeded");

        contributions[msg.sender] += amountToBuy;
        tokensSold += amountToBuy;

        token.transfer(msg.sender, amountToBuy);
        emit TokenPurchased(msg.sender, amountToBuy);
    }

    function endIDO() external onlyOwner {
        require(isIDOActive, "IDO not started yet");
        require(block.timestamp > endTime, "IDO is still ongoing");

        isIDOActive = false;
        emit IDOEnded();
    }

    function withdrawFunds() external onlyOwner {
        require(address(this).balance > 0, "No funds to withdraw");
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawUnsoldTokens() external onlyOwner {
        uint256 remainingTokens = token.balanceOf(address(this));
        require(remainingTokens > 0, "No unsold tokens left");
        token.transfer(owner(), remainingTokens);
    }
}
