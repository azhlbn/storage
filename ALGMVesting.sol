// SPDX-License-Identifier: MIT
//
//
// UI:
//
// - function "createVesting" ===================================> [address] Create Vesting. Can be called only one by contract deployer
// - function "claim" ===========================================> [uint256] Provide vesting index from 0 to 7. Can be called only owner of exact vesting.
// - struct "vesting" ===========================================> [index] Provide vesting index from 0 to 7. Show full information about exact vesting.
//
//
// DEPLOYMENT:
// 
// - Depoloy contract with no arguments
// - Use function createVesting for create vesting and begin vesting timer and provide those addresses:
//      address team, teamPrivateSale, advisors, marketing, NFTHolders, liquidity, treasury, stakingReward
// 
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/* 
tasks:
- Add events
- Add adding vesting / remove vesting 
*/

contract ALGMVesting is Ownable, ReentrancyGuard {
  // -------------------------------------------------------------------------------------------------------
  // ------------------------------- VESTING PARAMETERS
  // -------------------------------------------------------------------------------------------------------

    using SafeERC20 for IERC20;
    IERC20 public token;

    uint256 constant public ONE_WEEK = 7 days;

    bool public vestingsStarted;

    mapping(address => Vesting) public vestingByAddress;

    address[] public vestings;

    // @notice                              provide full information of exact vesting 
    struct Vesting {
        address beneficiary;                   //The only owner can call vesting claim function
        uint256 claimCounter;                  //Currect claim number
        uint256 totalClaimNum;                 //Maximum amount of claims for this vesting
        uint256 nextUnlockDate;                //Next date of tokens unlock 
        uint256 tokensRemaining;               //Remain amount of token
        uint256 tokensToUnlockPerMonth;        //Amount of token can be uncloked each month
        uint256 id;
    }

    constructor(IERC20 _token) {
        token = _token;
    }

    // @notice                             only contract deployer can call this method and only once
    function createVesting(
        address _beneficiary,
        uint256 _cliff,
        uint256 _tokensRemaining,
        uint256 _tokensToUnlockPerMonth,
        uint256 _durationInMonths
    ) external onlyOwner {
        require(vestingByAddress[_beneficiary].beneficiary != address(0), "Vesting already created");

        Vesting storage vesting = vestingByAddress[_beneficiary];

        vesting.beneficiary = _beneficiary;
        vesting.claimCounter = 0;
        vesting.totalClaimNum = _durationInMonths * 4; // four claims in a month
        vesting.nextUnlockDate = _cliff;
        vesting.tokensRemaining = _tokensRemaining;
        vesting.tokensToUnlockPerMonth = _tokensToUnlockPerMonth;

        vestings.push(vesting.beneficiary);
        vesting.id = vestings.length - 1;
    }

    function removeVesting(address _beneficiary) external onlyOwner {
        Vesting storage vesting = vestingByAddress[_beneficiary];
        require(vesting.beneficiary != address(0), "No such vesting extists");

        // remove vesting from mapping
        delete vestingByAddress[_beneficiary];

        // remove vesting from array 
        address lastVestingAddress = vestings[vestings.length - 1];
        vestingByAddress[lastVestingAddress].id = vestingByAddress[_beneficiary].id;
        vestingByAddress[_beneficiary] = vestingByAddress[lastVestingAddress];
        vestings.pop();
    }

    function startAllVestings() external onlyOwner {
        require(!vestingsStarted, "Vestings are already started");
        require(vestings.length > 0, "No vesting was found");

        vestingsStarted = true;

        for (uint256 i; i < vestings.length;) {
            vestingByAddress[vestings[i]].nextUnlockDate += block.timestamp + ONE_WEEK;
            unchecked { ++i; }
        }
    }

    function claim() external nonReentrant {
        Vesting memory vesting  = vestingByAddress[msg.sender];

        require(vesting.beneficiary != address(0), "No such vesting");
        require(block.timestamp > vesting.nextUnlockDate, "Tokens are still locked");
        require(vesting.tokensRemaining > 0, "Nothing to claim");

        if(vesting.claimCounter + 1 < vesting.totalClaimNum) {
            uint256 toSend = vesting.tokensToUnlockPerMonth;
            vesting.tokensRemaining -= toSend;
            vesting.nextUnlockDate += ONE_WEEK;
            vesting.claimCounter++;
            token.safeTransfer(msg.sender, toSend);
        } else {
            token.safeTransfer(msg.sender, vesting.tokensRemaining);
            vesting.tokensRemaining = 0;
        }
    }

    function getAllVestings() external view returns (Vesting[] memory) {
        Vesting[] memory arr = new Vesting[](vestings.length);

        for (uint256 i; i < vestings.length;) {
            arr[i] = vestingByAddress[vestings[i]];
            unchecked { ++i; }
        }

        return arr;
    }
}

