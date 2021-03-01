const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');

const Legendary = artifacts.require('./Legendary_v8.sol');
const Token = artifacts.require('./Token.sol');
const Rookie = artifacts.require('./Rookie_v8.sol');
const Professional = artifacts.require('./Professional_v8.sol');

require('chai')
    .use(require('chai-as-promised'))
    .should();  

contract('Legendary', (accounts) => {
    let instance;
    let token;
    const totalSupply = 900000000000000000000;
    before(async() => {
        token = await Token.new("MineToken", "MNT", 18, totalSupply.toString(), accounts[0]);
        rookie = await Rookie.new("Rookie", token.address, 58, 30);
        professional = await Professional.new("Professional", token.address, 150, 90);
        instance = await Legendary.new("Legendary", token.address, 271, 180, rookie.address, professional.address);
        });

    describe('deployment', async() => {
        it('deploys successfully', async() => {
            const address = await instance.address;
            assert.notEqual(address, 0x0);
            assert.notEqual(address, '');
            assert.notEqual(address, null);
            assert.notEqual(address, undefined);
        })

        it('has a name', async() => {
            const name = await instance.name();
            name.should.equal("Legendary");
        })

        it('has tokenAddress', async() => {
            const tokenAddress = await instance.tokenAddress();
            assert.equal(tokenAddress.toString(), token.address);
        })

        it('has rate', async() => {
            const rate = await instance.rate();
            assert.equal(rate, 271);
        })

        it('has lock duration', async() => {
            const lockduration = await instance.lockDuration();
            assert.equal(lockduration.toString(),'180')
        })

        it('has rookie address', async() => {
            const rookieAddress = await instance.rookieAddress();
            rookieAddress.should.equal(rookie.address);
        })

        it('has professional address', async() => {
            const professionalAddress = await instance.professionalAddress();
            professionalAddress.should.equal(professional.address);
        })
    })

    describe('Rewards', async() => {

        it('should not add 0 rewards', async() => {
            await truffleAssert.reverts(instance.addReward(0), "Reward must be positive")
        })
        
        it('should not add reward greater than allowance', async() => {
            const approval = 1000000000000000000;
            const rewards = 2000000000000000000;
            await token.approve(instance.address, approval.toString());
            await truffleAssert.reverts(instance.addReward(rewards.toString()),"Make sure to add enough allowance");
        })
        
        it('adds rewards', async() => {
            const reward = 500000000000000000;
            await token.approve(instance.address, reward.toString());
            await instance.addReward(reward.toString());
            const totalReward = await instance.totalReward();
            totalReward.toString().should.equal(reward.toString(), "Total rewards is correct");
            const rewardBalance = await instance.rewardBalance();
            rewardBalance.toString().should.equal(reward.toString(), "Reward balance is correct");
        })
    })

    describe('Setting rate and lockduration', async() => {

        it('should set rate by owner', async() => {
            await instance.setRate(60, {from: accounts[0]});
            const rate = await instance.rate();
            const index = await instance.index(); //Check the visibility after testing
            rate.toString().should.equal('60', "Rate set successfully by owner");
            const newRate = await instance.rates(index);
            newRate[0].toString().should.equal('60', "Rate is updated");
        })

        it('should not allow 0 interest rate', async() => {
            await truffleAssert.reverts(instance.setRate(0, {from: accounts[0]}), "Zero interest rate");
        })

        // it('should set minStakeAmount by owner', async() => {
        //     const minAmount = 1000000000000000000;
        //     await instance.setMinStakeAmount(minAmount.toString(), {from: accounts[0]});
        //     const amount = await instance.minStakeAmount();
        //     amount.toString().should.equal(minAmount.toString(), "Min Stake Amount set successfully by owner");
        // })

        it('should not allow others to set rate', async() => {
            await truffleAssert.reverts(instance.setRate(66, {from: accounts[1]}), "Ownable: caller is not the owner");
        })

        // it('should not allow others to set minStakeAmount', async() => {
        //     const minAmount = 1000000000000000000;
        //     await truffleAssert.reverts(instance.setMinStakeAmount(minAmount.toString(), {from: accounts[2]}), "Ownable: caller is not the owner");
        // })

        it('should change lockDuration by owner', async() => {
            await instance.changeLockDuration(60);
            const newLockDuration = await instance.lockDuration();
            newLockDuration.toString().should.equal("60", "Lock Duration changed successfully");
        })

        it('should not allow others to change the lockDuration', async() => {
            await truffleAssert.reverts(instance.changeLockDuration(60, {from: accounts[2]}), "Ownable: caller is not the owner");
        })
    })

    describe('Staking', async() => {
        it('should not stake 0 amount', async() => {
            const amount = 30;
            const stake = 10;
            await token.transfer(accounts[5], amount.toString());
            await token.approve(rookie.address, stake.toString(),{from: accounts[5]});
            await token.approve(professional.address, stake.toString(), {from: accounts[5]});
            await rookie.stake(stake.toString(), {from: accounts[5]});
            await professional.stake(stake.toString(), {from: accounts[5]});
            await truffleAssert.reverts(instance.stake(0, {from: accounts[5]}), "Can't stake 0 amount")
        })

        // it('should not stake less than min stake amount', async() => {
        //     const stake = 1000000000000000000;
        //     const minStake = 2000000000000000000;
        //     await instance.setMinStakeAmount(minStake.toString());
        //     await truffleAssert.reverts(instance.stake(stake.toString()), "Less than min stake amount");
        // })

        it('should not allow users to stake without eligibility from Rookie/Professional', async() => {
            const stake = 10;
            await token.approve(instance.address, stake.toString());
            await truffleAssert.reverts(instance.stake(stake.toString()), "Need to be eligible in either Rookie or Professional to stake");
        })

        it('should not add greater than allowance', async() => {
            const approval = 4000000000000000000;
            const stake = 50000000000000000000;
            const eligibility = 1000000000000000000;
            await rookie.setEligibilityAmount(eligibility.toString());
            await professional.setEligibilityAmount(eligibility.toString());
            await token.approve(rookie.address, eligibility.toString());
            await token.approve(professional.address, eligibility.toString());
            await rookie.stake(eligibility.toString());
            await professional.stake(eligibility.toString());
            await token.approve(instance.address, approval.toString());
            await truffleAssert.reverts(instance.stake(stake.toString()), "Make sure to add enough allowance");
        })

        it('adds stakes', async() => {
            const stake = 2000000000000000000;
            await token.approve(instance.address, stake.toString());
            await instance.stake(stake.toString(), {from: accounts[0]});
            const deposits = await instance.userDeposits(accounts[0]);
            const index = await instance.index();
            deposits[0].toString().should.equal('2000000000000000000', "Staked correctly");
            deposits[3].toString().should.equal(index.toString(), "Index is set correctly");
            deposits[4].should.equal(false, "Staked correctly");
            const stakedBalance = await instance.stakedBalance();
            stakedBalance.toString().should.equal('2000000000000000000', "Staked Balance is correct");
            const stakedTotal = await instance.stakedTotal();
            stakedTotal.toString().should.equal('2000000000000000000', "Staked total is correct");
        })

        it('should not allow multiple stakes from same user', async() => {
            const stake = 2000000000000000000;
            await token.approve(instance.address, stake.toString(), {from: accounts[0]});
            await truffleAssert.reverts(instance.stake(stake.toString(), {from: accounts[0]}), "Already Staked");
        })

        it('should stake according to the changes in rates', async() => {
            const deposits = await instance.userDeposits(accounts[0]);
            const rate = await instance.rate();
            const userIndex = deposits[3].toString();
            const userRate = await instance.rates(userIndex);
            rate.toString().should.equal(userRate[0].toString(), "Rates are synced1");
            await instance.setRate(70);
            const amount = 6000000000000000000;
            const stake = 2000000000000000000;
            await token.transfer(accounts[1], amount.toString());
            await token.approve(rookie.address, stake.toString(),{from: accounts[1]});
            await token.approve(professional.address, stake.toString(), {from: accounts[1]});
            await rookie.stake(stake.toString(), {from: accounts[1]});
            await professional.stake(stake.toString(), {from: accounts[1]});
            await token.approve(instance.address, stake.toString(), {from: accounts[1]});
            await instance.stake(stake.toString(), {from: accounts[1]});
            const deposits1 = await instance.userDeposits(accounts[1]);
            const rate1 = await instance.rate();
            const userIndex1 = deposits1[3].toString();
            const userRate1 = await instance.rates(userIndex1);
            rate1.toString().should.equal(userRate1[0].toString(), "Rates are synced2");
        })

        it('makes user eligible if staked more than eligibleAmount', async() => {
            const amount = 6000000000000000000;
            const stake = 2000000000000000000;
            const eligibility = 1000000000000000000;
            await token.transfer(accounts[4], amount.toString());
            await token.approve(rookie.address, stake.toString(),{from: accounts[4]});
            await token.approve(professional.address, stake.toString(), {from: accounts[4]});
            await rookie.stake(stake.toString(), {from: accounts[4]});
            await professional.stake(stake.toString(), {from: accounts[4]});
            await token.approve(instance.address, stake.toString(), {from: accounts[4]});
            await instance.setEligibilityAmount(eligibility.toString());
            await instance.stake(stake.toString(), {from: accounts[4]});
            const eligible = await instance.eligibility(accounts[4]);
            eligible.should.equal(true, "Eligibility set");
        })
    })

    describe('Withdraw', async() => {

        it('should not allow to withdraw without stakes', async() => {
            await truffleAssert.reverts(instance.withdraw({from: accounts[2]}), "No stakes found for user");
        })

        it('should not allow withdraw before deposit time', async() => {
            await truffleAssert.reverts(instance.withdraw(), "Requesting before lock time");
        })

        it('should not withdraw when rewards are low', async() => {
            const amount = 300000000000000000000;
            const stake = 100000000000000000000;
            await token.transfer(accounts[2], amount.toString());
            await token.approve(instance.address, stake.toString(), { from: accounts[2]});
            await token.approve(rookie.address, stake.toString(),{from: accounts[2]});
            await token.approve(professional.address, stake.toString(), {from: accounts[2]});
            await rookie.stake(stake.toString(), {from: accounts[2]});
            await professional.stake(stake.toString(), {from: accounts[2]});
            await instance.stake(stake.toString(), {from: accounts[2]});
            function timeout(ms) {
                return new Promise(resolve => setTimeout(resolve, ms));
            }
            await timeout(60000);
            await truffleAssert.reverts(instance.withdraw({from: accounts[2]}), "Not enough rewards");
            //Test for next case
            const amount1 = 6000000000000000000;
            const stake1 = 2000000000000000000;
            await token.transfer(accounts[3], amount1.toString());
            await token.approve(instance.address, stake1.toString(), {from: accounts[3]});
            await token.approve(rookie.address, stake1.toString(),{from: accounts[3]});
            await token.approve(professional.address, stake1.toString(), {from: accounts[3]});
            await rookie.stake(stake1.toString(), {from: accounts[3]});
            await professional.stake(stake1.toString(), {from: accounts[3]});
            await instance.stake(stake1.toString(), {from: accounts[3]});
            console.log('Wait for withdraw to happen in 60s');
        })

        it('withdraws successfully', async() => {
        
            const stakedBalance = await instance.stakedBalance();
            const rewardBalance = await instance.rewardBalance();
            console.log(stakedBalance.toString(), rewardBalance.toString());
            const balance = await token.balanceOf(accounts[3]);
            console.log(balance.toString());
            const amount = await instance.userDeposits(accounts[3]);
            const depositAmount = amount[0];
            console.log(amount[2]);
            function timeout(ms) {
                return new Promise(resolve => setTimeout(resolve, ms));
            }
            await timeout(30000);
            await instance.setRate(80);
            await timeout(30000);
            await instance.withdraw({from: accounts[3]});
            const balance1 = await token.balanceOf(accounts[3]);
            console.log(balance1.toString());
            const latestStakedBalance = await instance.stakedBalance();
            latestStakedBalance.toString().should.equal(stakedBalance.sub(depositAmount).toString(), "Staked balance updated correctly");
            const reward = balance1.sub(web3.utils.toBN(depositAmount));
            console.log(reward.toString());
            const latestRewardBalance = await instance.rewardBalance();
            latestRewardBalance.toString().should.equal(rewardBalance.sub(reward).toString(), "Reward Balance updated correctly");
        })
        
        it('should not withdraw twice', async() => {
            await instance.withdraw();
            await truffleAssert.reverts(instance.withdraw(), "No stakes found for user");
        })

        it('should set eligibility false after withdrawal', async() => {
            await instance.withdraw({from: accounts[4]});
            const eligible = await instance.eligibility(accounts[4]);
            eligible.should.equal(false, "Eligibility set correctly");
        })
    })
})