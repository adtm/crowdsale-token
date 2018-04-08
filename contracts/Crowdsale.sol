pragma solidity ^0.4.18;

import "./Token.sol";

contract Crowdsale {

  address public owner;

  uint public amountRaised;
  uint public fundingGoal;
  bool public goalReached;

  uint public startDate;
  uint public endDate;
  bool public crowdsaleClosed;

  Token public token;
  uint public price;


  modifier afterDeadline() { if (now >= endDate) _; }

  event GoalReached(address recipient, uint totalAmountReached);
  event FundTransfer(address backer, uint amount);

  function Crowdsale(
    uint _fundingGoalInWei,
    uint _price,
    uint _startDate,
    uint _endDate,
    Token _token
  ) public
  {
    owner = msg.sender;
    fundingGoal = _fundingGoalInWei;
    price = _price;
    startDate = _startDate;
    endDate = _endDate;
    token = _token;

    crowdsaleClosed = false;
    goalReached = false;
  }

  function buyTokens() public payable {
    require(!crowdsaleClosed);
    uint amount = msg.value;
    token.aquireToken(msg.sender, amount / price);
    amountRaised += amount;
    FundTransfer(msg.sender, amount);
  }

  function checkGoalReached() public afterDeadline {
    if (amountRaised >= fundingGoal){
      GoalReached(owner, amountRaised);
      goalReached = true;
      crowdsaleClosed = true;
    }
  }

}
