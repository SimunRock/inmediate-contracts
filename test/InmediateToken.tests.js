//
// This source file is part of the inmediate-contracts open source project
// Copyright 2018 Zerion LLC
// Licensed under Apache License v2.0
//
let assertRevert = require('./helpers/AssertRevert');
let increaseTime = require('./helpers/TimeTravel');

const constants = require('./constants.js');
const token = artifacts.require('../contracts/InmediateToken.sol');
const BigNumber = web3.BigNumber;

require('chai')
	.use(require('chai-as-promised'))
	.use(require('chai-bignumber')(BigNumber))
	.should();


contract('InmediateToken', function (accounts) {

	describe('Check constant field values', function () {

		let contract;

		it('Should check allocation addresses', async function () {
			contract = await token.new();

			constants.investorsAllocation.should.be.bignumber.equal(await contract.investorsAllocation.call());
			constants.teamAllocation.should.be.bignumber.equal(await contract.teamAllocation.call());
			constants.advisorsAllocation.should.be.bignumber.equal(await contract.advisorsAllocation.call());
			constants.bountyAllocation.should.be.bignumber.equal(await contract.bountyAllocation.call());
			constants.liquidityPoolAllocation.should.be.bignumber.equal(await contract.liquidityPoolAllocation.call());
			constants.contributorsAllocation.should.be.bignumber.equal(await contract.contributorsAllocation.call());
		});

		it('Should check total numbers', async function () {
			constants.investorsTotal.should.be.bignumber.equal(await contract.investorsTotal.call());
			constants.teamTotal.should.be.bignumber.equal(await contract.teamTotal.call());
			constants.advisorsTotal.should.be.bignumber.equal(await contract.advisorsTotal.call());
			constants.bountyTotal.should.be.bignumber.equal(await contract.bountyTotal.call());
			constants.liquidityPoolTotal.should.be.bignumber.equal(await contract.liquidityPoolTotal.call());
			constants.contributorsTotal.should.be.bignumber.equal(await contract.contributorsTotal.call());
		});

		it('Should check the team tokens vesting', async function () {
			constants.teamPeriodAmount.should.be.bignumber.equal(await contract.teamPeriodAmount.call());
			constants.teamCliff.should.be.bignumber.equal(await contract.teamCliff.call());
			constants.teamUnlockedAfterCliff.should.be.bignumber.equal(await contract.teamUnlockedAfterCliff.call());
			constants.teamPeriodLength.should.be.bignumber.equal(await contract.teamPeriodLength.call());
			constants.teamPeriodsNumber.should.be.bignumber.equal(await contract.teamPeriodsNumber.call());
		});

		it('Should check the advisors tokens vesting', async function () {
			constants.advisorsPeriodAmount.should.be.bignumber.equal(await contract.advisorsPeriodAmount.call());
			constants.advisorsCliff.should.be.bignumber.equal(await contract.advisorsCliff.call());
			constants.advisorsUnlockedAfterCliff.should.be.bignumber.equal(await contract.advisorsUnlockedAfterCliff.call());
			constants.advisorsPeriodLength.should.be.bignumber.equal(await contract.advisorsPeriodLength.call());
			constants.advisorsPeriodsNumber.should.be.bignumber.equal(await contract.advisorsPeriodsNumber.call());
		});
	});

	it('Should check allocation balances', async function () {
		let contract = await token.new();

		constants.investorsTotal.should.be.bignumber.equal(await contract.balanceOf.call(constants.investorsAllocation));
		constants.teamTotal.should.be.bignumber.equal(await contract.balanceOf.call(constants.teamAllocation));
		constants.advisorsTotal.should.be.bignumber.equal(await contract.balanceOf.call(constants.advisorsAllocation));
		constants.bountyTotal.should.be.bignumber.equal(await contract.balanceOf.call(constants.bountyAllocation));
		constants.liquidityPoolTotal.should.be.bignumber.equal(await contract.balanceOf.call(constants.liquidityPoolAllocation));
		constants.contributorsTotal.should.be.bignumber.equal(await contract.balanceOf.call(constants.contributorsAllocation));
	});

	it('Should check available token numbers', async function () {
		let contract = await token.new();

		// No tokens should be available for withdrawal in the beginning
		(await contract.allowance.call(constants.teamAllocation, constants.owner)).should.be.bignumber.equal(0);
		(await contract.allowance.call(constants.advisorsAllocation, constants.owner)).should.be.bignumber.equal(0);

		// All tokens should be withdrawable immediately 
		constants.investorsTotal.should.be.bignumber.equal(await contract.allowance.call(constants.investorsAllocation, constants.owner));
		constants.bountyTotal.should.be.bignumber.equal(await contract.allowance.call(constants.bountyAllocation, constants.owner));
		constants.liquidityPoolTotal.should.be.bignumber.equal(await contract.allowance.call(constants.liquidityPoolAllocation, constants.owner));
		constants.contributorsTotal.should.be.bignumber.equal(await contract.allowance.call(constants.contributorsAllocation, constants.owner));
	});

	it('Should check that a random address can not withdraw tokens from the allocations', async function () {
		let contract = await token.new();

		await assertRevert(
			contract.transferFrom(constants.investorsAllocation, constants.investor, 1, { from: constants.investor })
		);
		await assertRevert(
			contract.transferFrom(constants.bountyAllocation, constants.investor, 1, { from: constants.investor })
		);
		await assertRevert(
			contract.transferFrom(constants.liquidityPoolAllocation, constants.investor, 1, { from: constants.investor })
		);
		await assertRevert(
			contract.transferFrom(constants.contributorsAllocation, constants.investor, 1, { from: constants.investor })
		);
	});

	it('Should check that owner can distribute tokens allocated for investors', async function () {
		let contract = await token.new();

		let investorBalance = await contract.balanceOf.call(constants.investor);
		investorBalance.should.be.bignumber.equal(0);
		await contract.transferFrom(constants.investorsAllocation, constants.investor, constants.investorsTotal, { from: constants.owner });
		let investorNewBalance = await contract.balanceOf.call(constants.investor);
		investorNewBalance.should.be.bignumber.equal(constants.investorsTotal);
		let investorsAllocationBalance = await contract.balanceOf.call(constants.investorsAllocation);
		investorsAllocationBalance.should.be.bignumber.equal(0);
	});

	describe('Test vesting', function () {

		let month = 30 * 24 * 60 * 60 * 1000; // milliseconds

		async function setTime(date) {
			let block = await web3.eth.getBlock(web3.eth.blockNumber);
			let nodeTime = block.timestamp * 1000;

			await increaseTime((date - nodeTime) / 1000);

			block = await web3.eth.getBlock(web3.eth.blockNumber);
			nodeTime = block.timestamp * 1000;

			date.should.be.bignumber.closeTo(nodeTime, date, 5000);  // +/- 5 seconds
		}

		it('Should test team\'s tokens vesting', async function () {
			console.log('Test team\'s tokens vesting...');
			let contract = await token.new();
			let creationTime = await contract.creationTime.call() * 1000;
			let cliff = constants.teamCliff * 1000;

			for (let i = 0; i < 31; ++i) {
				let newTime = creationTime + month * i;
				await setTime(newTime);

				let available = await contract.allowance.call(constants.teamAllocation, constants.owner);
				console.log('' + (i + 1) + "'th month:", available.toNumber() / Math.pow(10, constants.decimals));

				if (newTime < creationTime + cliff) {
					available.should.be.bignumber.equal(0);
				} else if (i === Math.floor(cliff / month)) {
					available.should.be.bignumber.equal(constants.teamUnlockedAfterCliff);
				} else {
					available.should.be.bignumber.equal(
						constants.teamUnlockedAfterCliff
						.plus(
							constants.teamPeriodAmount.times(Math.floor((newTime - cliff - creationTime) / (constants.teamPeriodLength * 1000)))
						)
					);
				}
			}
		});

		it('Should test advisors\' tokens vesting', async function () {
			console.log('Test advisors\' tokens vesting...');
			let contract = await token.new();
			let creationTime = await contract.creationTime.call() * 1000;
			let cliff = constants.teamCliff * 1000;

			for (let i = 0; i < 19; ++i) {
				let newTime = creationTime + month * i;
				await setTime(newTime);

				let available = await contract.allowance.call(constants.advisorsAllocation, constants.owner);
				console.log('' + (i + 1) + "'th month:", available.toNumber() / Math.pow(10, constants.decimals));

				if (newTime < creationTime + cliff) {
					available.should.be.bignumber.equal(0);
				} else if (i === Math.floor(cliff / month)) {
					available.should.be.bignumber.equal(constants.advisorsUnlockedAfterCliff);
				} else {
					available.should.be.bignumber.equal(
						constants.advisorsUnlockedAfterCliff
						.plus(
							constants.advisorsPeriodAmount.times(Math.floor((newTime - cliff - creationTime) / (constants.advisorsPeriodLength * 1000)))
						)
					);
				}
			}
		});
	});
});
