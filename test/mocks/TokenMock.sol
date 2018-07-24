pragma solidity ^0.4.24;

import "../../contracts/utils/Token.sol";


// mock class using Token
contract TokenMock is Token {
  constructor(address _initialAccount, uint256 _initialBalance) public {
    balances[_initialAccount] = _initialBalance;
    totalSupply = _initialBalance;
  }
}