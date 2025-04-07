// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// TDT Token Contract (ERC20 Standard)
contract TDTToken {
    string public constant name = "TDT Token";
    string public constant symbol = "TDT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        _transfer(msg.sender, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }
    
    function _transfer(address from, address to, uint256 value) internal {
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
}

// Token Sale Contract
contract TDTSale {
    address public immutable admin;
    IERC20 public immutable token;
    uint256 public tokenPrice; // Price per token in wei
    
    event TokensPurchased(address indexed buyer, uint256 bnbAmount, uint256 tokenAmount);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }
    
    constructor(address _tokenAddress, uint256 _tokenPrice) {
        admin = msg.sender;
        token = IERC20(_tokenAddress);
        tokenPrice = _tokenPrice;
    }
    
    function buyTokens(uint256 tokenAmount) external payable {
        require(tokenAmount > 0, "Amount must be > 0");
        uint256 requiredBnb = tokenAmount * tokenPrice;
        require(msg.value >= requiredBnb, "Insufficient BNB");
        
        require(
            token.transferFrom(admin, msg.sender, tokenAmount),
            "Transfer failed"
        );
        
        // Refund excess BNB
        if (msg.value > requiredBnb) {
            payable(msg.sender).transfer(msg.value - requiredBnb);
        }
        
        emit TokensPurchased(msg.sender, requiredBnb, tokenAmount);
    }
    
    function setTokenPrice(uint256 newPrice) external onlyAdmin {
        tokenPrice = newPrice;
    }
    
    function withdrawBnb() external onlyAdmin {
        payable(admin).transfer(address(this).balance);
    }
    
    function withdrawTokens(address tokenAddress) external onlyAdmin {
        IERC20(tokenAddress).transfer(admin, IERC20(tokenAddress).balanceOf(address(this)));
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}