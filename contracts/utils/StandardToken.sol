pragma solidity 0.4.24;

//
// This source file is part of the inmediate-contracts open source project
// Copyright 2018 Zerion LLC
// Licensed under Apache License v2.0
//

import './AbstractToken.sol';
import './Owned.sol';
import './SafeMath.sol';


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
contract StandardToken is AbstractToken, Owned {
	using SafeMath for uint256;

	/*
	 *  Data structures
	 */
	mapping (address => uint256) internal balances;
	mapping (address => mapping (address => uint256)) internal allowed;
	uint256 public totalSupply;

	/*
	 *  Read and write storage functions
	 */
	/// @dev Transfers sender's tokens to a given address. Returns success.
	/// @param _to Address of token receiver.
	/// @param _value Number of tokens to transfer.
	function transfer(address _to, uint256 _value) public returns (bool success) {
		return _transfer(msg.sender, _to, _value);
	}

	/// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
	/// @param _from Address from where tokens are withdrawn.
	/// @param _to Address to where tokens are sent.
	/// @param _value Number of tokens to transfer.
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(_value <= allowed[_from][msg.sender]);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		return _transfer(_from, _to, _value);
	}

	/// @dev Returns number of tokens owned by given address.
	/// @param _owner Address of token owner.
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

	/// @dev Sets approved amount of tokens for spender. Returns success.
	/// @param _spender Address of allowed account.
	/// @param _value Number of approved tokens.
	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	/*
	 * Read storage functions
	 */
	/// @dev Returns number of allowed tokens for given address.
	/// @param _owner Address of token owner.
	/// @param _spender Address of token spender.
	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

	/**
	* @dev Private transfer, can only be called by this contract.
	* @param _from The address of the sender.
	* @param _to The address of the recipient.
	* @param _value The amount to send.
	* @return success True if the transfer was successful, or throws.
	*/
	function _transfer(address _from, address _to, uint256 _value) private returns (bool success) {
		require(_value <= balances[_from]);
		require(_to != address(0));

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(_from, _to, _value);
		return true;
	}
}
