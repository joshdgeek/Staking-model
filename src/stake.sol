// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Stake is ERC20, ERC20Permit, Ownable {
    address public _admin;

    constructor(address admin, uint256 mintAmount) ERC20("Polyblade", "PBD") Ownable(admin) ERC20Permit("Polyblade") {
        _admin = admin;
        _mint(address(this), mintAmount);
    }

    //mappimgs
    mapping(address => uint256) public stakedTS; //Time stamp of staking action
    mapping(address => uint256) public staked; //address to amount staked
    mapping(address => uint256) public timeOfLockUp; //address to expected time of lockUp

    //
    uint256 penaltyPercentage;
    uint256 percentageRate;

    //restricted function to request for token
    function requestToken(uint256 amount) public onlyOwner {
        _transfer(address(this), msg.sender, amount);
    }

    // restricted function to set penalty percentage
    function setPenaltyPercentage(uint256 penalty) public onlyOwner {
        penaltyPercentage = penalty;
    }

    // restricted function to set percentage rate
    function setPercentageRate(uint256 rate) public onlyOwner {
        percentageRate = rate;
    }

    function stake(uint256 amount, uint256 time_months) external {
        require(time_months > 0, "invalid duration");
        require(amount > 0, "amount is less than zero");
        require(balanceOf(msg.sender) >= amount, "not enough amount to initiate staking");

        uint256 timeInMonths = time_months * 30 days;
        _transfer(msg.sender, address(this), amount);

        if (staked[msg.sender] > 0) {
            claim();
        }
        stakedTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
        timeOfLockUp[msg.sender] = timeInMonths; // * 86400 * 30; //using 30 days in a month
    }

    function unStake(uint256 amount, uint256 durationOfLockUp) external {
        //uint durationOfLockUp = block.timestamp - stakedTS[msg.sender];

        uint256 penaltyFee = (amount * 5) / 100; // Apply penalty fee on the unstaked amount

        require(amount > 0, "Amount must be greater than zero");
        require(staked[msg.sender] >= amount, "Amount must be less than or equal to staked balance");

        // Mint staking rewards to the user's address
        claim();

        if (durationOfLockUp < timeOfLockUp[msg.sender]) {
            // Deduct the penalty from the unstaked amount
            uint256 amountAfterPenalty = amount - penaltyFee;
            staked[msg.sender] -= amount; // Reduce the full unstaked amount
            _transfer(address(this), msg.sender, amountAfterPenalty); // Transfer after penalty
        } else {
            staked[msg.sender] -= amount; // Reduce the full unstaked amount
            _transfer(address(this), msg.sender, amount); // No penalty, transfer full amount
        }

        // Reset the timestamp if all tokens are unstaked
        if (staked[msg.sender] == 0) {
            stakedTS[msg.sender] = 0;
        }
    }

    function reward(address user) public view returns (uint256) {
        uint256 duration = 35 days; //block.timestamp + stakedTS[user];
        require(duration > 1 seconds, "duration should be greater than zero");

        //get reward of 50% per 30 days
        uint256 yearlyRoundUp = (staked[user] * 100) / 31536000;

        //return income per second using reward per annum as a frame of reference
        return ((yearlyRoundUp * duration) / 31536000) * 100;
    }

    //function to claim rewards on staked token
    function claim() public {
        require(staked[msg.sender] > 0, "No Token Staked");
        uint256 _reward = reward(msg.sender);

        //mint new tokens to the address
        _mint(msg.sender, _reward);
    }
}
