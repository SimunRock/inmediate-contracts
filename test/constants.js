//
// This source file is part of the inmediate-contracts open source project
// Copyright 2018 Zerion LLC
// Licensed under Apache License v2.0
//
const BigNumber = web3.BigNumber;

function define(name, value) {
    Object.defineProperty(exports, name, {
        value: value,
        enumerable: true
    });
}


/** Addresses **/
define('owner', '0xaec3ae5d2be00bfc91597d7a1b2c43818d84396a');
define('newOwner', '0xf1f42f995046e67b79dd5ebafd224ce964740da3');
define('investor', '0xd646e8c228bfcc0ec6067ad909a34f14f45513b0');


/** Token meta information **/
define('decimals', 8);
define('name', 'Inmediate');
define('symbol', 'DIT');


/** Alocations **/

let stringDecimals = '00000000';

// Initial Investors
define('investorsAllocation', '0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF');
define('investorsTotal', new BigNumber('400000000' + stringDecimals));

// Team 
define('teamAllocation', '0x1111111111111111111111111111111111111111');
define('teamTotal', new BigNumber('100000000' + stringDecimals));
define('teamPeriodAmount', new BigNumber('10000000' + stringDecimals));
define('teamCliff', 6 * 30 * 24 * 60 * 60);
define('teamUnlockedAfterCliff', new BigNumber('20000000' + stringDecimals));
define('teamPeriodLength', 3 * 30 * 24 * 60 * 60);
define('teamPeriodsNumber', 8);

// Advisors
define('advisorsAllocation', '0x2222222222222222222222222222222222222222');
define('advisorsTotal', new BigNumber('50000000' + stringDecimals));
define('advisorsPeriodAmount', new BigNumber('10000000' + stringDecimals));
define('advisorsCliff', 6 * 30 * 24 * 60 * 60);
define('advisorsUnlockedAfterCliff', new BigNumber('10000000' + stringDecimals));
define('advisorsPeriodLength', 3 * 30 * 24 * 60 * 60);
define('advisorsPeriodsNumber', 4);

// Bounty
define('bountyAllocation', '0x3333333333333333333333333333333333333333');
define('bountyTotal', new BigNumber('50000000' + stringDecimals));

// Liquidity Pool
define('liquidityPoolAllocation', '0x4444444444444444444444444444444444444444');
define('liquidityPoolTotal', new BigNumber('150000000' + stringDecimals));

// Contributors
define('contributorsAllocation', '0x5555555555555555555555555555555555555555');
define('contributorsTotal', new BigNumber('250000000' + stringDecimals));
