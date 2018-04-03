pragma solidity ^0.4.18;

import './Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract Token is Ownable {

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
        symbol = 'TET';
        name = 'Testy';
        decimals = 18;
        totalSupply = 1000000;
        balances[msg.sender] = totalSupply;
        Transfer(address(0), msg.sender, totalSupply);
    }

    function() public payable { revert(); }

    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
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
        Transfer(msg.sender, _to, _value);
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
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value)
      public
      returns (bool success)
   {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

   function burn(uint256 _value) public returns (bool success) {
       require(balances[msg.sender] >= _value);

       balances[msg.sender] -= _value;
       totalSupply -= _value;
       Burn(msg.sender, _value);
       return true;
   }

   function burnFrom(address _from, uint256 _value) public returns (bool success) {
       require(balances[_from] >= _value);
       require(_value <= allowed[_from][msg.sender]);

       balances[_from] -= _value;
       allowed[_from][msg.sender] -= _value;
       totalSupply -= _value;
       Burn(_from, _value);
       return true;
   }

   function mintTokens(uint256 mintAmount) ownerOnly public {
     totalSupply += mintAmount;
     Transfer(0, this, mintAmount);
   }

   function freezeAccount(address account, bool status) ownerOnly public {
     frozenAccounts[account] = status;
     FrozenAccount(account, status);
   }
}
