const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');

const Rookie = artifacts.require('./RookieFinal.sol');
const Token = artifacts.require('./Token.sol');

require('chai')
    .use(require('chai-as-promised'))
    .should();  

contract('Rookie', (accounts) => {
    let instance;
    let token;
    const totalSupply = 200000000000000000000;
    before(async() => {
        token = await Token.new("MineToken", "MNT", 18, totalSupply.toString(), accounts[0]);
        instance = await Rookie.new("Rookie", token.address, 58, 30);
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
            name.should.equal("Rookie");
        })

        it('has tokenAddress', async() => {
            const tokenAddress = await instance.tokenAddress();
            assert.equal(tokenAddress.toString(), token.address);
        })

        it('has rate', async() => {
            const rate = await instance.rate();
            assert.equal(rate, 58);
        })

        it('has lock duration', async() => {
            const lockduration = await instance.lockduration();
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

    describe('Setting rate and minStakeAmount', async() => {
        it('should set rate by owner', async() => {
            await instance.setRate(60, {from: accounts[0]});
            const rate = await instance.rate();
            rate.toString().should.equal('60', "Rate set successfully by owner");
        })

        it('should set minStakeAmount by owner', async() => {
            const minAmount = 1000000000000000000;
            await instance.setMinStakeAmount(minAmount.toString(), {from: accounts[0]});
            const amount = await instance.minStakeAmount();
            amount.toString().should.equal(minAmount.toString(), "Min Stake Amount set successfully by owner");
        })

        it('should not allow others to set rate', async() => {
            await truffleAssert.reverts(instance.setRate(66, {from: accounts[1]}), "Ownable: caller is not the owner");
        })

        it('should not allow others to set minStakeAmount', async() => {
            const minAmount = 1000000000000000000;
            await truffleAssert.reverts(instance.setMinStakeAmount(minAmount.toString(), {from: accounts[2]}), "Ownable: caller is not the owner");
        })
    })

    describe('Staking', async() => {
        it('should not stake 0 amount', async() => {
            await truffleAssert.reverts(instance.stake(0), "Less than min stake amount")
        })

        it('should not stake less than min stake amount', async() => {
            const stake = 1000000000000000000;
            const minStake = 2000000000000000000;
            await instance.setMinStakeAmount(minStake.toString());
            await truffleAssert.reverts(instance.stake(stake.toString()), "Less than min stake amount");
        })

        it('should not add greater than allowance', async() => {
            const approval = 4000000000000000000;
            const stake = 50000000000000000000;
            await token.approve(instance.address, approval.toString());
            await truffleAssert.reverts(instance.stake(stake.toString()), "Make sure to add enough allowance");
        })

        it('adds stakes', async() => {
            const stake = 2000000000000000000;
            await token.approve(instance.address, stake.toString());
            await instance.stake(stake.toString(), {from: accounts[0]});
            const deposits = await instance.userDeposits();
            deposits[0].toString().should.equal('2000000000000000000', "Staked correctly");
            deposits[3].should.equal(false, "Staked correctly");
            const stakedBalance = await instance.stakedBalance();
            stakedBalance.toString().should.equal('2000000000000000000', "Staked Balance is correct");
            const stakedTotal = await instance.stakedTotal();
            stakedTotal.toString().should.equal('2000000000000000000', "Staked total is correct");
        })

        it('should not allow multiple stakes from same user', async() => {
            const stake = 2000000000000000000;
            await truffleAssert.reverts(instance.stake(stake.toString()), "Already staked");
        })

        it('should stake according to the changes in rates', async() => {
            const deposits = await instance.userDeposits();
            const rate = await instance.rate();
            rate.toString().should.equal(deposits[2].toString(), "Rates are synced");
            await instance.setRate(70);
            const stake = 2000000000000000000;
            await token.transfer(accounts[1], stake.toString());
            await token.approve(instance.address, stake.toString(), { from: accounts[1]});
            await instance.stake(stake.toString(), {from: accounts[1]});
            const deposits1 = await instance.userDeposits({from: accounts[1]});
            const rate1 = await instance.rate();
            rate1.toString().should.equal(deposits1[2].toString(), "Rates are synced");
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
            await timeout(10000);
            await truffleAssert.reverts(instance.withdraw({from: accounts[2]}), "Not enough rewards");
        })

        it('withdraws successfully', async() => {
            const balance = await token.balanceOf(accounts[0]);
            const amount = await instance.userDeposits();
            const depositAmount = amount[0];
            const stakedBalance = await instance.stakedBalance();
            const rewardBalance = await instance.rewardBalance();
            const deposits = await instance.userDeposits();
            function timeout(ms) {
                return new Promise(resolve => setTimeout(resolve, ms));
            }
            await timeout(10000);
            await instance.withdraw();
            const rate = deposits[2];
            const reward = (depositAmount * rate)/10000;
            const latestBalance = await token.balanceOf(accounts[0]);
            const withdrawAmount = latestBalance - balance;
            const paidAmount = depositAmount.add(web3.utils.toBN(reward));
            withdrawAmount.toString().should.equal(paidAmount.toString(), "Withdraw successfull");
            const latestStakedBalance = await instance.stakedBalance();
            const latestRewardBalance = await instance.rewardBalance();
            latestStakedBalance.toString().should.equal((stakedBalance - depositAmount).toString(), "Staked Balance updated correctly");
            latestRewardBalance.toString().should.equal((rewardBalance - reward).toString(), "Reward Balance updated successfully");
        })
        
        it('should not withdraw twice', async() => {
            await truffleAssert.reverts(instance.withdraw(), "No stakes found for user");
        })
    })
})