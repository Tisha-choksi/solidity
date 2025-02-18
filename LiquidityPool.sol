// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityLocker is Ownable {
    IERC20 public tdtLpToken;
    uint256 public unlockTime;

    event LiquidityLocked(address indexed owner, uint256 amount, uint256 unlockTime);
    event LiquidityWithdrawn(address indexed owner, uint256 amount);

    constructor(address _tdtLpToken, uint256 _lockDuration) Ownable(msg.sender) {
        tdtLpToken = IERC20(_tdtLpToken);
        unlockTime = block.timestamp + _lockDuration;
    }

    function lockLiquidity(uint256 amount) external onlyOwner {
        tdtLpToken.transferFrom(msg.sender, address(this), amount);
        emit LiquidityLocked(msg.sender, amount, unlockTime);
    }

    function withdrawLiquidity() external onlyOwner {
        require(block.timestamp >= unlockTime, "Liquidity is still locked");
        uint256 balance = tdtLpToken.balanceOf(address(this));
        require(balance > 0, "No liquidity to withdraw");

        tdtLpToken.transfer(msg.sender, balance);
        emit LiquidityWithdrawn(msg.sender, balance);
    }
}
