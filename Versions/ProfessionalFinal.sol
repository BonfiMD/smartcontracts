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

pragma solidity ^0.5.8;

contract Professional {
    using SafeMath for uint256;

    struct Deposits {
        address depositor;
        uint256 depositAmount;
        uint256 depositTime;
        bool paid;
    }

    mapping(address => bool) private hasStaked;
    mapping(address => Deposits) private deposits;

    string public name;
    address public tokenAddress;
    uint256 public stakedTotal;
    uint256 public totalReward;
    uint256 public rewardBalance;
    uint256 public stakedBalance;

    IERC20 public ERC20Interface;
    event Staked(
        address indexed token,
        address indexed staker_,
        uint256 requestedAmount_
    );
    event PaidOut(
        address indexed token,
        address indexed staker_,
        uint256 amount_,
        uint256 reward_
    );

    constructor(string memory name_, address tokenAddress_) public {
        name = name_;
        require(tokenAddress_ != address(0), "Token address: 0 address");
        tokenAddress = tokenAddress_;
    }

    function addReward(uint256 rewardAmount)
        public
        returns (
            //_hasAllowance(msg.sender, rewardAmount)
            bool
        )
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
            bool
        )
    {
        address user = msg.sender;
        return (
            deposits[user].depositAmount,
            deposits[user].depositTime,
            deposits[user].paid
        );
    }

    /**
     * Requirements:
     * - `amount` Amount to be staked
     */
    function stake(uint256 amount)
        public
        _positive(amount)
        returns (
            //_realAddress(msg.sender)
            bool
        )
    {
        address from = msg.sender;
        require(hasStaked[from] == false, "Already staked");
        return _stake(from, amount);
    }

    function withdraw()
        public
        //_realAddress(msg.sender)
        _staked(msg.sender)
        returns (bool)
    {
        address from = msg.sender;
        require(
            block.timestamp >= (deposits[from].depositTime).add(60), //(90 * 24 * 3600),
            "Requesting before lock time"
        );
        require(deposits[from].paid == false, "Already paid out");

        uint256 amount = deposits[from].depositAmount;
        return _withdrawAfterClose(from, amount);
    }

    function _withdrawAfterClose(address from, uint256 amount)
        private
        returns (
            //_realAddress(from)
            bool
        )
    {
        deposits[from].paid = true;

        //uint256 noOfDecimals = 1000000000000000000;
        uint256 num = amount.mul(271);
        uint256 denom = 10000;
        uint256 reward = num.div(denom);

        // /uint256 reward = ((amount * 58) / (100 * 100));

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
        _positive(amount)
        returns (
            //_hasAllowance(staker, amount)
            bool
        )
    {
        if (!_payMe(staker, amount)) {
            return false;
        }
        //set the staking status to true
        hasStaked[staker] = true;
        deposits[staker] = Deposits(staker, amount, block.timestamp, false);
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
    )
        private
        returns (
            //_hasAllowance(allower, amount)
            bool
        )
    {
        // Request to transfer amount from the contract to receiver.
        // contract does not own the funds, so the allower must have added allowance to the contract
        // Allower is the original owner.
        ERC20Interface = IERC20(tokenAddress);
        return ERC20Interface.transferFrom(allower, receiver, amount);
    }

    function _payDirect(address to, uint256 amount)
        private
        _positive(amount)
        returns (bool)
    {
        ERC20Interface = IERC20(tokenAddress);
        return ERC20Interface.transfer(to, amount);
    }

    // modifier _realAddress(address addr) {
    //     require(addr != address(0), "Zero address");
    //     _;
    // }

    modifier _positive(uint256 amount) {
        require(amount >= 0, "Negative amount");
        _;
    }

    // modifier _hasAllowance(address allower, uint256 amount) {
    //     // Make sure the allower has provided the right allowance.
    //     ERC20Interface = IERC20(tokenAddress);
    //     uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
    //     require(amount <= ourAllowance, "Make sure to add enough allowance");
    //     _;
    // }

    modifier _staked(address from) {
        //to check the user status
        require(hasStaked[from] == true, "No stakes found for user");
        _;
    }
}
