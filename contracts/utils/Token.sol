pragma solidity 0.4.24;

//
// This source file is part of the inmediate-contracts open source project
// Copyright 2018 Zerion LLC
// Licensed under Apache License v2.0
//

import './BurnableToken.sol';

/// @title Token contract - Implements Standard ERC20 with additional features.
/// @author Zerion - <inbox@zerion.io>
contract Token is BurnableToken {

	// Time of the contract creation
	uint256 public creationTime;

	constructor() public {
		/* solium-disable-next-line security/no-block-members */
		creationTime = now;
	}

	/// @dev Owner can transfer out any accidentally sent ERC20 tokens
	function transferERC20Token(AbstractToken _token, address _to, uint256 _value)
		public
		onlyOwner
		returns (bool success)
	{
		require(_token.balanceOf(address(this)) >= _value);
		uint256 receiverBalance = _token.balanceOf(_to);
		require(_token.transfer(_to, _value));

		uint256 receiverNewBalance = _token.balanceOf(_to);
		assert(receiverNewBalance == receiverBalance.add(_value));

		return true;
	}

	/// @dev Increases approved amount of tokens for spender. Returns success.
	function increaseApproval(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_value);
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	/// @dev Decreases approved amount of tokens for spender. Returns success.
	function decreaseApproval(address _spender, uint256 _value) public returns (bool success) {
		uint256 oldValue = allowed[msg.sender][_spender];
		if (_value > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue.sub(_value);
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
}
