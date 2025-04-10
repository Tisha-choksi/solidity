// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract TokenSale {
    address public owner;
    IBEP20 public immutable tdtToken;
    IBEP20 public immutable usdtToken;

    uint256 public tokenPriceInUSDT; // How much USDT (6 decimals) per 1 TDT (18 decimals)

    event TokensPurchased(address indexed buyer, uint256 usdtPaid, uint256 tokensReceived);
    event PriceUpdated(uint256 newPrice);
    event USDTWithdrawn(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(address _tdtToken, address _usdtToken, uint256 _priceInUSDT) {
        require(_tdtToken != address(0) && _usdtToken != address(0), "Invalid token address");
        require(_priceInUSDT > 0, "Price must be > 0");

        owner = msg.sender;
        tdtToken = IBEP20(_tdtToken);
        usdtToken = IBEP20(_usdtToken);
        tokenPriceInUSDT = _priceInUSDT; // For example, 1 TDT = 0.1 USDT => 100000 (USDT has 6 decimals)
    }

    function buyTokens(uint256 usdtAmount) external {
        require(usdtAmount > 0, "USDT amount must be > 0");

        // Calculate how many TDT tokens the buyer gets
        // tokenAmount = usdtAmount * 10^12 / tokenPriceInUSDT
        // Converts 6 decimals USDT to 18 decimals TDT
        uint256 tokenAmount = (usdtAmount * 1e12) / tokenPriceInUSDT;

        require(
            tdtToken.balanceOf(owner) >= tokenAmount,
            "Not enough TDT tokens available"
        );
        require(
            tdtToken.allowance(owner, address(this)) >= tokenAmount,
            "Owner must approve TDT tokens"
        );
        require(
            usdtToken.allowance(msg.sender, address(this)) >= usdtAmount,
            "Approve USDT first"
        );

        // Transfer USDT from buyer to this contract
        require(usdtToken.transferFrom(msg.sender, address(this), usdtAmount), "USDT transfer failed");

        // Transfer TDT from owner to buyer
        require(tdtToken.transferFrom(owner, msg.sender, tokenAmount), "TDT transfer failed");

        emit TokensPurchased(msg.sender, usdtAmount, tokenAmount);
    }

    function setTokenPrice(uint256 newPriceInUSDT) external onlyOwner {
        require(newPriceInUSDT > 0, "Price must be > 0");
        tokenPriceInUSDT = newPriceInUSDT;
        emit PriceUpdated(newPriceInUSDT);
    }

    function withdrawUSDT() external onlyOwner {
        uint256 balance = usdtToken.balanceOf(address(this));
        require(balance > 0, "No USDT to withdraw");
        require(usdtToken.transfer(owner, balance), "Withdraw failed");
        emit USDTWithdrawn(balance);
    }

    function recoverOtherTokens(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(tdtToken), "Cannot recover TDT");
        require(tokenAddress != address(usdtToken), "Cannot recover USDT");
        IBEP20 token = IBEP20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner, balance), "Token recovery failed");
    }
}
