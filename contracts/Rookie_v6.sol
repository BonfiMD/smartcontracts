pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.5.0;

contract Rookie_v6 is Ownable {
    using SafeMath for uint256;

    /**
     *  @dev Structs to store user staking data.
     */
    struct Deposits {
        // address depositor;
        uint256 depositAmount;
        uint256 depositTime;
        uint256 userIndex;
        bool paid;
        bool eligible;
    }

    /**
     *  @dev Structs to store interest rate change.
     */
    struct Rates {
        uint256 newInterestRate;
        uint256 timeStamp;
    }

    mapping(address => bool) private hasStaked;
    mapping(address => Deposits) private deposits;
    mapping(uint256 => Rates) public rates;
    // mapping(address => bool) public eligible;

    string public name;
    address public tokenAddress;
    uint256 public stakedTotal;
    uint256 public totalReward;
    uint256 public rewardBalance;
    uint256 public stakedBalance;
    // uint256 public minStakeAmount;
    uint256 public rate;
    uint256 public lockduration;
    uint256 public index;
    uint256 public eligibilityAmount;

    IERC20 public ERC20Interface;

    /**
     *  @dev Emitted when user stakes 'stakedAmount' value of tokens
     */
    event Staked(
        address indexed token,
        address indexed staker_,
        uint256 stakedAmount_
    );

    /**
     *  @dev Emitted when user withdraws his stakings
     */
    event PaidOut(
        address indexed token,
        address indexed staker_,
        uint256 amount_,
        uint256 reward_
    );

    /**
     *   @param
     *   name_, name of the contract
     *   tokenAddress_, contract address of the token
     *   rate_, rate multiplied by 100
     *   lockduration_, duration in days
     */

    constructor(
        string memory name_,
        address tokenAddress_,
        uint256 rate_,
        uint256 lockduration_
    ) public Ownable() {
        name = name_;
        require(tokenAddress_ != address(0), "Token address: 0 address");
        tokenAddress = tokenAddress_;
        require(rate_ != 0, "Zero interest rate");
        rate = rate_;
        lockduration = lockduration_;
        rates[index] = Rates(rate, block.timestamp);
    }

    // function setMinStakeAmount(uint256 amount_) public onlyOwner {
    //     minStakeAmount = amount_;
    // }

    /**
     *  Requirements:
     *  `rate_` New effective interest rate multiplied by 100
     *  @dev to set interest rates
     */
    function setRate(uint256 rate_) public onlyOwner {
        require(rate_ != 0, "Zero interest rate");
        index++;
        rates[index] = Rates(rate_, block.timestamp);
        rate = rate_;
    }

    /**
     *  Requirements:
     *  `amount_` Eligibility amount to be set for Professional Tier unlocks
     *  @dev to set eligibility amount
     */
    function setEligibilityAmount(uint256 amount_) public onlyOwner {
        eligibilityAmount = amount_;
    }

    /**
     *  Requirements:
     *  `user_` User wallet address
     *  @dev to view eligibility status of user
     */
    function eligibility(address user_) public view returns (bool) {
        return deposits[user_].eligible;
    }

    /**
     *  @dev to return the eligibility amount. Used by the Legendary contract
     */
    function viewEligibilityAmount() public view returns (uint256) {
        return eligibilityAmount;
    }

    /**
     *  Requirements:
     *  `rewardAmount` rewards to be added to the staking contract
     *  @dev to add rewards to the staking contract
     *  once the allowance is given to this contract for 'rewardAmount' by the user
     */
    function addReward(uint256 rewardAmount)
        public
        _hasAllowance(msg.sender, rewardAmount)
        returns (bool)
    {
        require(rewardAmount > 0, "Reward must be positive");
        address from = msg.sender;
        if (!_payMe(from, rewardAmount)) {
            return false;
        }
        //Rewards added to staking contract
        totalReward = totalReward.add(rewardAmount);
        rewardBalance = rewardBalance.add(rewardAmount);
        return true;
    }

    /**
     *  Requirements:
     *  `user` User wallet address
     *  @dev returns user staking data
     */
    function userDeposits(address user)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        if (hasStaked[user]) {
            return (
                deposits[user].depositAmount,
                deposits[user].depositTime,
                deposits[user].userIndex,
                deposits[user].paid
            );
        }
    }

    /**
     *  Requirements:
     *  `amount` Amount to be staked
     /**
     *  @dev to stake 'amount' value of tokens 
     *  once the user has given allowance to the staking contract
     */
    function stake(uint256 amount) public returns (bool) {
        require(amount > 0, "Can't stake 0 amount");
        address from = msg.sender;
        require(hasStaked[from] == false, "Already staked");
        return _stake(from, amount);
    }

    // function changeEligibility(address user) public returns (bool) {
    //     //add modifier - onlyLegend
    //     eligible[user] = false;
    // }

    /**
     * @dev to withdraw user stakings after the lock period ends.
     */
    function withdraw() public _staked(msg.sender) returns (bool) {
        address from = msg.sender;
        require(
            block.timestamp >= (deposits[from].depositTime).add(60), //(lockduration * 24 * 3600),
            "Requesting before lock time"
        );
        require(deposits[from].paid == false, "Already paid out");

        uint256 amount = deposits[from].depositAmount;
        uint256 _userIndex = deposits[from].userIndex;
        uint256 _depositTime = deposits[from].depositTime;
        return _withdrawAfterClose(from, amount, _userIndex, _depositTime);
    }

    function _withdrawAfterClose(
        address from,
        uint256 amount,
        uint256 userIndex,
        uint256 depositTime
    ) private returns (bool) {
        uint256 totalAmount = _calculate(amount, userIndex, depositTime);

        uint256 reward = totalAmount.sub(amount);

        require(reward <= rewardBalance, "Not enough rewards");

        uint256 payOut = amount.add(reward);
        stakedBalance = stakedBalance.sub(amount);
        rewardBalance = rewardBalance.sub(reward);
        deposits[from].paid = true;
        hasStaked[from] = false;
        // if (eligible[from]) {
        //     eligible[from] = false;
        // }
        deposits[from].eligible = false;
        if (_payDirect(from, payOut)) {
            emit PaidOut(tokenAddress, from, amount, reward);
            return true;
        }
        return false;
    }

    /**
     *  Requirements:
     *  `amount` User staking amount
     *  `userIndex` User interest rate index
     *  `depositTime` User deposit Time
     * @dev to calculate the rewards based on user staked 'amount'
     * 'userIndex' - the index of the interest rate at the time of user stake.
     * 'depositTime' - time of staking
     */
    function calculate(
        uint256 amount,
        uint256 userIndex,
        uint256 depositTime
    ) public view returns (uint256) {
        return _calculate(amount, userIndex, depositTime);
    }

    function _calculate(
        uint256 amount,
        uint256 userIndex,
        uint256 depositTime
    ) private view returns (uint256) {
        uint256 endTime = depositTime.add(60); //replace 60 with (lockduration * 24 * 3600)
        uint256 time;
        for (uint256 i = userIndex; i < index; i++) {
            //loop runs till the latest index/interest rate change
            if (endTime < rates[i + 1].timeStamp) {
                //if the change occurs after the endTime loop breaks
                break;
            } else {
                time = rates[i + 1].timeStamp.sub(depositTime);
                uint256 num = amount.mul(rates[i].newInterestRate).mul(time);
                uint256 denom = 600000; //Replace with (lockduration * 24 * 3600 * 10000)
                uint256 interest = num.div(denom);
                amount += interest;
                depositTime = rates[i + 1].timeStamp;
                userIndex++;
            }
        }

        if (depositTime < endTime) {
            //final calculation for the remaining time period
            time = endTime.sub(depositTime);
            uint256 finalInterest;

            {
                uint256 num = time.mul(amount);
                uint256 denom = 600000; //Replace with (lockduration * 24 * 3600 * 10000)
                finalInterest = num.div(denom).mul(
                    rates[userIndex].newInterestRate
                );
            }
            amount += finalInterest;
        }

        return (amount);
    }

    //Gas optimisation
    // function _calculate(
    //     uint256 amount,
    //     uint256 userIndex,
    //     uint256 depositTime
    // ) private view returns (uint256) {
    //     uint256 endTime = depositTime.add(60); //replace with (lockduration * 24 * 3600)
    //     uint256 time;
    //     uint256 interest;
    //     for (uint256 i = userIndex; i < index; i++) {
    //         //loop runs till the latest index/interest rate change
    //         if (endTime < rates[i + 1].timeStamp) {
    //             //if the change occurs after the endTime loop breaks
    //             break;
    //         } else {
    //             time = rates[i + 1].timeStamp.sub(depositTime);
    //             interest = amount.mul(rates[i].newInterestRate).mul(time).div(
    //                 600000
    //             ); //replace with (lockduration * 24 * 3600 * 10000)
    //             amount += interest;
    //             depositTime = rates[i + 1].timeStamp;
    //             userIndex++;
    //         }
    //     }

    //     if (depositTime < endTime) {
    //         //final calculation for the remaining time period
    //         time = endTime.sub(depositTime);

    //         interest = time
    //             .mul(amount)
    //             .mul(rates[userIndex].newInterestRate)
    //             .div(600000); //replace with (lockduration * 24 * 3600 * 10000)

    //         amount += interest;
    //     }

    //     return (amount);
    // }

    function _stake(address staker, uint256 amount)
        private
        // _minStake(amount)
        _hasAllowance(staker, amount)
        returns (bool)
    {
        if (!_payMe(staker, amount)) {
            return false;
        }
        //set the staking status to true
        hasStaked[staker] = true;
        bool stakerEligibility;
        if (amount >= eligibilityAmount) {
            stakerEligibility = true;
        }
        deposits[staker] = Deposits(
            // staker,
            amount,
            block.timestamp,
            index,
            false,
            stakerEligibility
        );
        emit Staked(tokenAddress, staker, amount);

        // Transfer is completed
        stakedBalance = stakedBalance.add(amount);
        stakedTotal = stakedTotal.add(amount);
        return true;
    }

    function _payMe(address payer, uint256 amount) private returns (bool) {
        return _payTo(payer, address(this), amount);
    }

    function _payTo(
        address allower,
        address receiver,
        uint256 amount
    ) private _hasAllowance(allower, amount) returns (bool) {
        // Request to transfer amount from the contract to receiver.
        // contract does not own the funds, so the allower must have added allowance to the contract
        // Allower is the original owner.
        ERC20Interface = IERC20(tokenAddress);
        return ERC20Interface.transferFrom(allower, receiver, amount);
    }

    function _payDirect(address to, uint256 amount) private returns (bool) {
        ERC20Interface = IERC20(tokenAddress);
        return ERC20Interface.transfer(to, amount);
    }

    modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        ERC20Interface = IERC20(tokenAddress);
        uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
        require(amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }

    modifier _staked(address from) {
        //to check the user status
        require(hasStaked[from] == true, "No stakes found for user");
        _;
    }
}
