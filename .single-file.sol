pragma solidity ^0.4.21;

contract Ownable {
  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  modifier ownerOnly {
    require(msg.sender == owner);
    _;
  }

}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Token is Ownable {

    address public owner; // debugging

    using SafeMath for uint;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint public totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => bool) public frozenAccounts;

    event Transfer(
      address _from,
      address _to,
      uint _value
    );

    event Approval(
      address  _owner,
      address _spender,
      uint _value
    );

    event Burn(
      address _from,
      uint _value
    );

    event FrozenAccount(
      address account,
      bool status
    );

    modifier notFrozen (address _to) {
      require(!frozenAccounts[_to]);
      require(!frozenAccounts[msg.sender]);
      _;
    }

    function Token() public {
        owner = msg.sender;
        symbol = 'TET';
        name = 'Testy';
        decimals = 18;
        totalSupply = 1000000;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function() public payable { revert(); }

    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function aquireToken(address _to, uint _value)
      public payable
      returns (bool success) {
        require(_value > 0);
        if (balances[_to] >= 0) {
          balances[_to] += _value;
        } else {
          balances[_to] = _value;
        }
        return true;
    }

    function transfer(address _to, uint _value)
      notFrozen(_to)
      public payable
      returns (bool success)
    {
        require(_value > 0);
        require(balances[msg.sender] >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value)
      notFrozen(_to)
      public payable
      returns (bool success)
    {
        require(allowed[_from][msg.sender] > 0);
        require(_value > 0);
        require(allowed[_from][msg.sender] >= _value && balances[_from] >= _value);


        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value)
      public
      returns (bool success)
   {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

   function burn(uint256 _value) public returns (bool success) {
       require(balances[msg.sender] >= _value);

       balances[msg.sender] -= _value;
       totalSupply -= _value;
       emit Burn(msg.sender, _value);
       return true;
   }

   function burnFrom(address _from, uint256 _value) public returns (bool success) {
       require(balances[_from] >= _value);
       require(_value <= allowed[_from][msg.sender]);

       balances[_from] -= _value;
       allowed[_from][msg.sender] -= _value;
       totalSupply -= _value;
       emit Burn(_from, _value);
       return true;
   }

   function mintTokens(uint256 mintAmount) ownerOnly public {
     totalSupply += mintAmount;
     emit Transfer(0, this, mintAmount);
   }

   function freezeAccount(address account, bool status) ownerOnly public {
     frozenAccounts[account] = status;
     emit FrozenAccount(account, status);
   }
}

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
    emit FundTransfer(msg.sender, amount);
  }

  function checkGoalReached() public afterDeadline {
    if (amountRaised >= fundingGoal){
      emit GoalReached(owner, amountRaised);
      goalReached = true;
      crowdsaleClosed = true;
    }
  }

}
