// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UMBToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable {
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10**18; // 100M UMB
    uint256 public transactionTax = 0; 
    address public taxCollector; 

    mapping(address => bool) public isExcludedFromTax; 

    event TaxUpdated(uint256 newTax);
    event TaxCollectorUpdated(address newCollector);
    event ExcludedFromTax(address indexed account, bool status);

    constructor() ERC20("UMB Token", "UMB") Ownable(msg.sender) {
        _mint(msg.sender, MAX_SUPPLY);
        taxCollector = msg.sender; 
        isExcludedFromTax[msg.sender] = true; 
    }

    // Fixing the _update function conflict
    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Pausable) {
        if (transactionTax > 0 && !isExcludedFromTax[from] && !isExcludedFromTax[to]) {
            uint256 taxAmount = (value * transactionTax) / 100;
            super._update(from, taxCollector, taxAmount);
            value -= taxAmount;
        }
        super._update(from, to, value);
    }

    function setTransactionTax(uint256 _tax) external onlyOwner {
        require(_tax <= 10, "Tax cannot exceed 10%");
        transactionTax = _tax;
        emit TaxUpdated(_tax);
    }

    function setTaxCollector(address _collector) external onlyOwner {
        require(_collector != address(0), "Invalid tax collector");
        taxCollector = _collector;
        emit TaxCollectorUpdated(_collector);
    }

    function excludeFromTax(address account, bool status) external onlyOwner {
        isExcludedFromTax[account] = status;
        emit ExcludedFromTax(account, status);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
