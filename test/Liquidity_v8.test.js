const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');

const Liquidity = artifacts.require('./Liquidity_v8.sol');
const Token = artifacts.require('./Token.sol');
const TestToken = artifacts.require('./TestToken.sol');

require('chai')
    .use(require('chai-as-promised'))
    .should();

contract('Liquidity', (accounts) => {
    let instance, token, rewardToken;
    const totalSupply = 200000000000000000000;
    before(async() => {
        token = await Token.new("MineToken", "MNT", 18, totalSupply.toString(), accounts[0]);
        rewardToken = await TestToken.new("RewardToken", "RWT", 18, totalSupply.toString(), accounts[0]);
        instance = await Liquidity.new("Liquidity", token.address, rewardToken.address, 148, 30);
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
            name.should.equal('Liquidity');
        })

        it('has token address', async() => {
            const tokenAddress = await instance.tokenAddress();
            tokenAddress.should.equal(token.address);
        })

        it('has reward token address', async() => {
            const rewardTokenAddress = await instance.rewardTokenAddress();
            rewardTokenAddress.should.equal(rewardToken.address);
        })

        it('has rate', async() => {
            const rate = await instance.rate();
            assert.equal(rate, 148);
        })

        it('has lock duration', async() => {
            const lockduration = await instance.lockDuration();
            assert.equal(lockduration.toString(),'30')
        })
    })

    describe('Rewards', async() => {
        it('should not add 0 rewards', async() => {
            await truffleAssert.reverts(instance.addReward(0), "Reward must be positive")
        })
        
        it('should not add reward greater than allowance', async() => {
            const approval = 1000000000000000000;
            const rewards = 2000000000000000000;
            await rewardToken.approve(instance.address, approval.toString());
            await truffleAssert.reverts(instance.addReward(rewards.toString()),"Make sure to add enough allowance");
        })

        it('adds rewards', async() => {
            const rewards = 500000000000000000;
            await rewardToken.approve(instance.address, rewards.toString());
            await instance.addReward(rewards.toString());
            const totalReward = await instance.totalReward();
            totalReward.toString().should.equal(rewards.toString(), "Total rewards are correct");
            const rewardBalance = await instance.rewardBalance();
            rewardBalance.toString().should.equal(rewards.toString(), "Rewards balance is correct");
        })
    })

    describe('Setting rate and minStakeAmount', async() => {
        it('should set rate by owner', async() => {
            await instance.setRate(150, {from: accounts[0]});
            const rate = await instance.rate();
            const index = await instance.index();
            rate.toString().should.equal('150', "Rate set successfully by owner");
            const newRate = await instance.rates(index);
            newRate[0].toString().should.equal('150', "Rate is updated");
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
            await truffleAssert.reverts(instance.setRate(160, {from: accounts[1]}), "Ownable: caller is not the owner");
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
            await truffleAssert.reverts(instance.stake(0), "Can't stake 0 amount");
        })

        // it('should not stake less than min stake amount', async() => {
        //     const stake = 1000000000000000000;
        //     const minStake = 2000000000000000000;
        //     await instance.setMinStakeAmount(minStake.toString());
        //     await truffleAssert.reverts(instance.stake(stake.toString()), "Less than min stake amount");
        // })

        it('should not add greater than allowance', async() => {
            const approval = 4000000000000000000;
            const stake = 5000000000000000000;
            await token.approve(instance.address, approval.toString());
            await truffleAssert.reverts(instance.stake(stake.toString()), "Make sure to add enough allowance");
        })

        it('adds stakes', async() => {
            const stake = 2000000000000000000;
            await instance.stake(stake.toString());
            const deposits = await instance.userDeposits(accounts[0]);
            const index = await instance.index();
            deposits[0].toString().should.equal(stake.toString(), "Staked successfully");
            deposits[3].toString().should.equal(index.toString(), "Index is set correctly");
            deposits[4].should.equal(false, "Staked successfully");
            const stakedBalance = await instance.stakedBalance();
            stakedBalance.toString().should.equal(stake.toString(), "Staked Balance is correct");
            const stakedTotal = await instance.stakedTotal();
            stakedTotal.toString().should.equal(stake.toString(), "Staked total is correct");
        })

        it('should not allow multiple stakes from same user', async() => {
            const stake = 2000000000000000000;
            await truffleAssert.reverts(instance.stake(stake.toString()), "Already staked");
        })

        it('should stake according to the changes in rates', async() => {
            const deposits = await instance.userDeposits(accounts[0]);
            const rate = await instance.rate();
            const userIndex = deposits[3].toString();
            const userRate = await instance.rates(userIndex);
            rate.toString().should.equal(userRate[0].toString(), "Rates are synced");
            await instance.setRate(160);
            const stake = 2000000000000000000;
            await token.transfer(accounts[1], stake.toString());
            await token.approve(instance.address, stake.toString(), { from: accounts[1]});
            await instance.stake(stake.toString(), {from: accounts[1]});
            const deposits1 = await instance.userDeposits(accounts[1]);
            const rate1 = await instance.rate();
            const userIndex1 = deposits1[3].toString();
            const userRate1 = await instance.rates(userIndex1);
            rate1.toString().should.equal(userRate1[0].toString(), "Rates are synced");
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
            const stake = 100000000000000000000;
            await token.transfer(accounts[2], stake.toString());
            await token.approve(instance.address, stake.toString(), { from: accounts[2]});
            await instance.stake(stake.toString(), {from: accounts[2]});
            function timeout(ms) {
                return new Promise(resolve => setTimeout(resolve, ms));
            }
            await timeout(60000);
            await truffleAssert.reverts(instance.withdraw({from: accounts[2]}), "Not enough rewards");
            //Test for next case
            const stake1 = 2000000000000000000;
            await token.transfer(accounts[3], stake1.toString());
            await token.approve(instance.address, stake1.toString(), {from: accounts[3]});
            await instance.stake(stake1.toString(), {from: accounts[3]});
        })

        it('withdraws successfully', async() => {
            const stakedBalance = await instance.stakedBalance();
            const rewardBalance = await instance.rewardBalance();
            console.log(stakedBalance.toString(), rewardBalance.toString());
            const balance = await token.balanceOf(accounts[3]);
            const userRewardBalance = await rewardToken.balanceOf(accounts[3]);
            console.log(balance.toString());
            const amount = await instance.userDeposits(accounts[3]);
            const depositAmount = amount[0];
            console.log(amount[2]);
            function timeout(ms) {
                return new Promise(resolve => setTimeout(resolve, ms));
            }
            await timeout(30000);
            await instance.setRate(170);
            await timeout(30000);
            await instance.withdraw({from: accounts[3]});
            const balance1 = await token.balanceOf(accounts[3]);
            console.log(balance1.toString());
            const latestUserRewardBalance = await rewardToken.balanceOf(accounts[3]);
            const latestStakedBalance = await instance.stakedBalance();
            latestStakedBalance.toString().should.equal(stakedBalance.sub(depositAmount).toString(), "Staked balance updated correctly");
            const reward = latestUserRewardBalance.sub(web3.utils.toBN(userRewardBalance));
            console.log(reward.toString());
            const latestRewardBalance = await instance.rewardBalance();
            latestRewardBalance.toString().should.equal(rewardBalance.sub(reward).toString(), "Reward Balance updated correctly");
        })

        it('should not withdraw twice', async() => {
            await instance.withdraw();
            await truffleAssert.reverts(instance.withdraw(), "No stakes found for user");
        })
     })
})

