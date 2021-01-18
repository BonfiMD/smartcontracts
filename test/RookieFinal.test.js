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
    const totalSupply = 100000000000000000000;
    before(async() => {
        token = await Token.new("MineToken", "MNT", 18, totalSupply.toString(), accounts[0]);
        instance = await Rookie.new("Rookie", token.address);
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
            const reward = 1000000000000000000;
            await token.approve(instance.address, reward.toString());
            await instance.addReward(reward.toString());
            const totalReward = await instance.totalReward();
            totalReward.toString().should.equal('1000000000000000000', "Total rewards is correct");
            const rewardBalance = await instance.rewardBalance();
            rewardBalance.toString().should.equal('1000000000000000000', "Reward balance is correct");
        })
    })

    describe('Staking', async() => {
        it('should not stake 0 amount', async() => {
            await truffleAssert.reverts(instance.stake(0), "Negative amount")
        })

        it('should not add greater than allowance', async() => {
            const approval = 1000000000000000000;
            const stake = 10000000000000000000;
            await token.approve(instance.address, approval.toString());
            await truffleAssert.reverts(instance.stake(stake.toString()), "Make sure to add enough allowance");
        })

        it('adds stakes', async() => {
            const stake = 1000000000000000000;
            await token.approve(instance.address, stake.toString());
            await instance.stake(stake.toString(), {from: accounts[0]});
            const deposits = await instance.userDeposits();
            deposits[0].toString().should.equal('1000000000000000000', "Staked correctly");
            deposits[2].should.equal(false, "Staked correctly");
            const stakedBalance = await instance.stakedBalance();
            stakedBalance.toString().should.equal('1000000000000000000', "Staked Balance is correct");
            const stakedTotal = await instance.stakedTotal();
            stakedTotal.toString().should.equal('1000000000000000000', "Staked total is correct");
        })

        it('should not allow multiple stakes from same user', async() => {
            const stake = 1000000000000000000;
            await truffleAssert.reverts(instance.stake(stake.toString()), "Already staked");
        })
    })

    describe('Withdraw', async() => {

        it('should not allow withdraw before deposit time', async() => {
            await truffleAssert.reverts(instance.withdraw(), "Requesting before lock time");
        })

        it('withdraws successfully', async() => {
            const balance = await token.balanceOf(accounts[0]);
            const amount = await instance.userDeposits();
            const depositAmount = amount[0];
            const stakedBalance = await instance.stakedBalance();
            const rewardBalance = await instance.rewardBalance();
            function timeout(ms) {
                return new Promise(resolve => setTimeout(resolve, ms));
            }
            await timeout(10000);
            await instance.withdraw();
            const reward = (depositAmount * 58)/10000;
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