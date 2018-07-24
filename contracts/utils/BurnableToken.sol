pragma solidity 0.4.24;

//
// This source file is part of the inmediate-contracts open source project
// Copyright 2018 Zerion LLC
// Licensed under Apache License v2.0
//

import './StandardToken.sol';

contract BurnableToken is StandardToken {

	address public burner;

	modifier onlyBurner {
		require(msg.sender == burner);
		_;
	}

	event NewBurner(address burner);

	function setBurner(address _burner)
		public
		onlyOwner
	{
		burner = _burner;
		emit NewBurner(_burner);
	}

	function burn(uint256 amount)
		public
		onlyBurner
	{
		require(balanceOf(msg.sender) >= amount);
		balances[msg.sender] = balances[msg.sender].sub(amount);
		totalSupply = totalSupply.sub(amount);
		emit Transfer(msg.sender, address(0x0000000000000000000000000000000000000000), amount);
	}
}
