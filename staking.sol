// Minor update: Comment added for GitHub contributions
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract Staking {
    address public owner;
    IERC20 public stakingToken;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public rewardDebt;

    uint256 public rewardRate = 100; // پاداش به ازای هر واحد استیک
    uint256 public totalStaked;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor(address _stakingToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this");
        _;
    }

    // استیک کردن توکن
    function stake(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");

        stakedAmount[msg.sender] += amount;
        totalStaked += amount;

        // انتقال توکن‌ها به قرارداد
        stakingToken.transferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    // انصراف از استیک کردن و برداشت توکن‌ها
    function unstake(uint256 amount) public {
        require(amount > 0 && stakedAmount[msg.sender] >= amount, "Invalid amount");

        stakedAmount[msg.sender] -= amount;
        totalStaked -= amount;

        // انتقال توکن‌ها به کاربر
        stakingToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    // محاسبه پاداش برای کاربر
    function calculateReward(address user) public view returns (uint256) {
        return (stakedAmount[user] * rewardRate) / 1000;
    }

    // برداشت پاداش
    function claimReward() public {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards to claim");

        rewardDebt[msg.sender] += reward;

        // انتقال پاداش به کاربر
        stakingToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    // تغییر نرخ پاداش (فقط برای مالک)
    function setRewardRate(uint256 rate) public onlyOwner {
        rewardRate = rate;
    }

    // مشاهده موجودی استیک شده
    function getStakedAmount(address user) public view returns (uint256) {
        return stakedAmount[user];
    }
}
