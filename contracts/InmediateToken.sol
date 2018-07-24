pragma solidity 0.4.24;

//
// This source file is part of the inmediate-contracts open source project
// Copyright 2018 Zerion LLC <inbox@zerion.io>
// Licensed under Apache License v2.0
//

import './utils/Token.sol';


/// @title Token contract - Implements Standard ERC20 Token for Inmediate project.
/// @author Zerion - <inbox@zerion.io>
contract InmediateToken is Token {

	/// TOKEN META DATA
	string constant public name = 'Inmediate';
	string constant public symbol = 'DIT';
	uint8  constant public decimals = 8;


	/// ALOCATIONS
	// To calculate vesting periods we assume that 1 month is always equal to 30 days 


	/*** Initial Investors' tokens ***/

	// 400,000,000 (40%) tokens are distributed among initial investors
	// These tokens will be distributed without vesting

	address public investorsAllocation = address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);
	uint256 public investorsTotal = 400000000e8;


	/*** Tokens reserved for the Inmediate team ***/

	// 100,000,000 (10%) tokens will be eventually available for the team
	// These tokens will be distributed querterly after a 6 months cliff
	// 20,000,000 will be unlocked immediately after 6 months
	// 10,000,000 tokens will be unlocked quarterly within 2 years after the cliff

	address public teamAllocation  = address(0x1111111111111111111111111111111111111111);
	uint256 public teamTotal = 100000000e8;
	uint256 public teamPeriodAmount = 10000000e8;
	uint256 public teamCliff = 6 * 30 days;
	uint256 public teamUnlockedAfterCliff = 20000000e8;
	uint256 public teamPeriodLength = 3 * 30 days;
	uint8   public teamPeriodsNumber = 8;

	/*** Tokens reserved for Advisors ***/

	// 50,000,000 (5%) tokens will be eventually available for advisors
	// These tokens will be distributed querterly after a 6 months cliff
	// 10,000,000 will be unlocked immediately after 6 months
	// 10,000,000 tokens will be unlocked quarterly within a year after the cliff

	address public advisorsAllocation  = address(0x2222222222222222222222222222222222222222);
	uint256 public advisorsTotal = 50000000e8;
	uint256 public advisorsPeriodAmount = 10000000e8;
	uint256 public advisorsCliff = 6 * 30 days;
	uint256 public advisorsUnlockedAfterCliff = 10000000e8;
	uint256 public advisorsPeriodLength = 3 * 30 days;
	uint8   public advisorsPeriodsNumber = 4;


	/*** Tokens reserved for pre- and post- ICO Bounty ***/

	// 50,000,000 (5%) tokens will be spent on various bounty campaigns
	// These tokens are available immediately, without vesting


	address public bountyAllocation  = address(0x3333333333333333333333333333333333333333);
	uint256 public bountyTotal = 50000000e8;


	/*** Liquidity pool ***/

	// 150,000,000 (15%) tokens will be used to manage token volatility
	// These tokens are available immediately, without vesting


	address public liquidityPoolAllocation  = address(0x4444444444444444444444444444444444444444);
	uint256 public liquidityPoolTotal = 150000000e8;


	/*** Tokens reserved for Contributors ***/

	// 250,000,000 (25%) tokens will be used to reward parties that contribute to the ecosystem
	// These tokens are available immediately, without vesting


	address public contributorsAllocation  = address(0x5555555555555555555555555555555555555555);
	uint256 public contributorsTotal = 250000000e8;


	/// CONSTRUCTOR

	constructor() public {
		//  Overall, 1,000,000,000 tokens exist
		totalSupply = 1000000000e8;

		balances[investorsAllocation] = investorsTotal;
		balances[teamAllocation] = teamTotal;
		balances[advisorsAllocation] = advisorsTotal;
		balances[bountyAllocation] = bountyTotal;
		balances[liquidityPoolAllocation] = liquidityPoolTotal;
		balances[contributorsAllocation] = contributorsTotal;
		

		// Unlock some tokens without vesting
		allowed[investorsAllocation][msg.sender] = investorsTotal;
		allowed[bountyAllocation][msg.sender] = bountyTotal;
		allowed[liquidityPoolAllocation][msg.sender] = liquidityPoolTotal;
		allowed[contributorsAllocation][msg.sender] = contributorsTotal;
	}

	/// DISTRIBUTION

	function distributeInvestorsTokens(address _to, uint256 _amountWithDecimals)
		public
		onlyOwner
	{
		require(transferFrom(investorsAllocation, _to, _amountWithDecimals));
	}

	/// VESTED ALLOCATIONS

	function withdrawTeamTokens(address _to, uint256 _amountWithDecimals)
		public
		onlyOwner 
	{
		allowed[teamAllocation][msg.sender] = allowance(teamAllocation, msg.sender);
		require(transferFrom(teamAllocation, _to, _amountWithDecimals));
	}

	function withdrawAdvisorsTokens(address _to, uint256 _amountWithDecimals)
		public
		onlyOwner 
	{
		allowed[advisorsAllocation][msg.sender] = allowance(advisorsAllocation, msg.sender);
		require(transferFrom(advisorsAllocation, _to, _amountWithDecimals));
	}


	/// UNVESTED ALLOCATIONS

	function withdrawBountyTokens(address _to, uint256 _amountWithDecimals)
		public
		onlyOwner
	{
		require(transferFrom(bountyAllocation, _to, _amountWithDecimals));
	}

	function withdrawLiquidityPoolTokens(address _to, uint256 _amountWithDecimals)
		public
		onlyOwner
	{
		require(transferFrom(liquidityPoolAllocation, _to, _amountWithDecimals));
	}

	function withdrawContributorsTokens(address _to, uint256 _amountWithDecimals)
		public
		onlyOwner
	{
		require(transferFrom(contributorsAllocation, _to, _amountWithDecimals));
	}
	
	/// OVERRIDEN FUNCTIONS

	/// @dev Overrides StandardToken.sol function
	function allowance(address _owner, address _spender)
		public
		view
		returns (uint256 remaining)
	{   
		if (_spender != owner) {
			return allowed[_owner][_spender];
		}

		uint256 unlockedTokens;
		uint256 spentTokens;

		if (_owner == teamAllocation) {
			unlockedTokens = _calculateUnlockedTokens(
				teamCliff, teamUnlockedAfterCliff,
				teamPeriodLength, teamPeriodAmount, teamPeriodsNumber
			);
			spentTokens = balanceOf(teamAllocation) < teamTotal ? teamTotal.sub(balanceOf(teamAllocation)) : 0;
		} else if (_owner == advisorsAllocation) {
			unlockedTokens = _calculateUnlockedTokens(
				advisorsCliff, advisorsUnlockedAfterCliff,
				advisorsPeriodLength, advisorsPeriodAmount, advisorsPeriodsNumber
			);
			spentTokens = balanceOf(advisorsAllocation) < advisorsTotal ? advisorsTotal.sub(balanceOf(advisorsAllocation)) : 0;
		} else {
			return allowed[_owner][_spender];
		}

		return unlockedTokens.sub(spentTokens);
	}

	/// @dev Overrides Owned.sol function
	function confirmOwnership()
		public
		onlyPotentialOwner
	{   
		// Forbids the old owner to distribute investors' tokens
		allowed[investorsAllocation][owner] = 0;

		// Allows the new owner to distribute investors' tokens
		allowed[investorsAllocation][msg.sender] = balanceOf(investorsAllocation);

		// Forbidsthe old owner to withdraw any tokens from the reserves
		allowed[teamAllocation][owner] = 0;
		allowed[advisorsAllocation][owner] = 0;
		allowed[bountyAllocation][owner] = 0;
		allowed[liquidityPoolAllocation][owner] = 0;
		allowed[contributorsAllocation][owner] = 0;

		// Allows the new owner to withdraw tokens from the unvested allocations
		allowed[bountyAllocation][msg.sender] = balanceOf(bountyAllocation);
		allowed[liquidityPoolAllocation][msg.sender] = balanceOf(liquidityPoolAllocation);
		allowed[contributorsAllocation][msg.sender] = balanceOf(contributorsAllocation);
		
		super.confirmOwnership();
	}

	/// PRIVATE FUNCTIONS

	function _calculateUnlockedTokens(
		uint256 _cliff,
		uint256 _unlockedAfterCliff,
		uint256 _periodLength,
		uint256 _periodAmount,
		uint8 _periodsNumber
	)
		private
		view
		returns (uint256) 
	{
		/* solium-disable-next-line security/no-block-members */
		if (now < creationTime.add(_cliff)) {
			return 0;
		}
		/* solium-disable-next-line security/no-block-members */
		uint256 periods = now.sub(creationTime.add(_cliff)).div(_periodLength);
		periods = periods > _periodsNumber ? _periodsNumber : periods;
		return _unlockedAfterCliff.add(periods.mul(_periodAmount));
	}
}
