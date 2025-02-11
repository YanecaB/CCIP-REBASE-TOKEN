// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RebaseToken is ERC20 {
    error RebaseToken__InterestRateMustDecrease();

    uint256 private constant PRECISION_FACTOR = 1e18;
    uint256 private s_interestRate = 5e10;

    mapping(address => uint256) private s_userInterestRate;
    mapping(address => uint256) private s_lastUpdatedTimestamp;

    event InterestRateSet(uint256 indexed interestRate);

    constructor() ERC20("Rebase Token", "RBT") {}

    function setInterestRate(uint256 _newInterestRate) external {
        // Set the interest rate
        if (_newInterestRate > s_interestRate) {
            revert RebaseToken__InterestRateMustDecrease();
        }

        s_interestRate = _newInterestRate;
        emit InterestRateSet(_newInterestRate);
    }

    function mint(address _to, uint256 _value) public {
        _mintAccruedInterest(_to);
        s_userInterestRate[_to] = s_interestRate;
        _mint(_to, _value);
    }

    function balanceOf(address user) public view override returns (uint256) {
        return super.balanceOf(user) * _calculateUserAccumulatedInterestSinceLastUpdate(user);
    }

    function _mintAccruedInterest(address _user) internal {
        // find their current balance of rebase tokens that have been minted to the user
        // calculate their current balance including any interest
        s_userInterestRate[_user] = s_interestRate;
    }

    function _calculateUserAccumulatedInterestSinceLastUpdate(address _user) internal view returns (uint256) {
        // get the time since the last update
        // calculate the interest that has accumulated since the last update
        // this is going to be linear growth with time
        //1. calculate the time since the last update
        //2. calculate the amount of linear growth
        //3. return the amount of linear growth

        uint256 timeElapsed = block.timestamp - s_lastUpdatedTimestamp[_user];
        return 1 + (s_userInterestRate[_user] * timeElapsed);
    }
}
