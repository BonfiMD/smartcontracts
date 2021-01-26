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

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.5.8;

contract RookieFinalv3 is Ownable {
    using SafeMath for uint256;

    struct Deposits {
        address depositor;
        uint256 depositAmount;
        uint256 depositTime;
        uint256 interestRate;
        bool paid;
    }

    struct Rates {
        uint256 newInterestRate;
        uint256 timeStamp;
    }

    mapping(address => bool) private hasStaked;
    mapping(address => Deposits) private deposits;
    mapping(uint256 => Rates) public rates;

    string public name;
    address public tokenAddress;
    uint256 public stakedTotal;
    uint256 public totalReward;
    uint256 public rewardBalance;
    uint256 public stakedBalance;
    uint256 public minStakeAmount;
    uint256 public rate;
    uint256 public lockduration;
    uint256 public index;

    IERC20 public ERC20Interface;
    event Staked(
        address indexed token,
        address indexed staker_,
        uint256 stakedAmount_
    );
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

    function setMinStakeAmount(uint256 amount_) public onlyOwner {
        minStakeAmount = amount_;
    }

    function setRate(uint256 rate_) public onlyOwner {
        require(rate_ != 0, "Zero interest rate");
        index++;
        rates[index] = Rates(rate_, block.timestamp);
        rate = rate_;
    }

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

    function userDeposits()
        public
        view
        _staked(msg.sender)
        returns (
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        address user = msg.sender;
        return (
            deposits[user].depositAmount,
            deposits[user].depositTime,
            deposits[user].interestRate,
            deposits[user].paid
        );
    }

    /**
     * Requirements:
     * - `amount` Amount to be staked
     */
    function stake(uint256 amount) public _minStake(amount) returns (bool) {
        address from = msg.sender;
        require(hasStaked[from] == false, "Already staked");
        return _stake(from, amount);
    }

    function withdraw() public _staked(msg.sender) returns (bool) {
        address from = msg.sender;
        require(
            block.timestamp >= (deposits[from].depositTime).add(60), //(lockduration * 24 * 3600),
            "Requesting before lock time"
        );
        require(deposits[from].paid == false, "Already paid out");

        uint256 amount = deposits[from].depositAmount;
        uint256 userInterestRate = deposits[from].interestRate;
        return _withdrawAfterClose(from, amount, userInterestRate);
    }

    function _withdrawAfterClose(
        address from,
        uint256 amount,
        uint256 userInterestRate
    ) private returns (bool) {
        deposits[from].paid = true;

        uint256 i;
        uint256 initialRate = userInterestRate;
        uint256 initialTime = deposits[from].depositTime;
        uint256 endTime = initialTime.add(60); //(lockDuration * 24 * 3600);
        uint256 time;

        for (i = 1; i <= index; i++) {
            if (initialTime >= endTime) {
                break;
            } else {
                if (initialTime <= rates[i].timeStamp) {
                    if (endTime <= rates[i].timeStamp) {
                        time = rates[i].timeStamp.sub(endTime);
                    } else {
                        time = rates[i].timeStamp.sub(initialTime);
                        uint256 period = 60; //(lockduration * 24 * 3600);
                        uint256 initialAmount = deposits[from].depositAmount;
                        uint256 interest;
                        {
                            uint256 num =
                                time.mul(initialAmount.mul(initialRate));
                            uint256 denom = period.mul(10000);
                            uint256 interest1 = num.div(denom);
                            interest = interest1;
                        }
                        deposits[from].depositAmount = initialAmount.add(
                            interest
                        );
                        deposits[from].depositTime = rates[i].timeStamp;
                        deposits[from].interestRate = rates[i].newInterestRate;
                        initialRate = rates[i].newInterestRate;
                        initialTime = rates[i].timeStamp;
                    }
                }
            }
        }

        if (deposits[from].depositTime < endTime) {
            uint256 time1 = endTime.sub(deposits[from].depositTime);
            uint256 num =
                time1.mul(
                    deposits[from].depositAmount.mul(
                        deposits[from].interestRate
                    )
                );
            uint256 denom = 600000;
            uint256 interest = num.div(denom);
            deposits[from].depositAmount += interest;
        }

        uint256 reward = deposits[from].depositAmount.sub(amount);

        require(reward <= rewardBalance, "Not enough rewards");

        uint256 payOut = amount.add(reward);
        stakedBalance = stakedBalance.sub(amount);
        rewardBalance = rewardBalance.sub(reward);
        hasStaked[from] = false;
        if (_payDirect(from, payOut)) {
            emit PaidOut(tokenAddress, from, amount, reward);
            return true;
        }
        return false;
    }

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
        deposits[staker] = Deposits(
            staker,
            amount,
            block.timestamp,
            rate,
            false
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

    // modifier _realAddress(address addr) {
    //     require(addr != address(0), "Zero address");
    //     _;
    // }

    modifier _minStake(uint256 amount) {
        require(amount >= minStakeAmount, "Less than min stake amount");
        _;
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
