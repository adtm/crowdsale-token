pragma solidity ^0.4.18;

import "./Token.sol";

contract Crowdsale {

  address public owner;

  uint public amountRaised;
  uint public fundingGoal;

  uint public startDate;
  uint public endDate;

  Token public token;
  uint public price;

  modifier crowdsaleClose {
    require(block.timestamp > startDate);
    require(block.timestamp < endDate);
    _;
  }

  event GoalReached(address recipient, uint totalAmountReached);
  event FundTransfer(address backer, uint amount);

  function Crowdsale(
    address _owner,
    uint _fundingGoalInEther,
    uint _price,
    uint _startDate,
    uint _endDate
  ) public
  {
    owner = _owner;
    fundingGoal = _fundingGoalInEther;
    price = _price;
    startDate = _startDate;
    endDate = _endDate;
  }

  function () crowdsaleClose payable {
    uint amount = msg.value;
    token.transfer(msg.sender, amount / price);
    amountRaised += amount;
    FundTransfer(msg.sender, amount);
  }

}
