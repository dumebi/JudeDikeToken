pragma solidity >=0.4.22 <0.6.0;
import "./ownable.sol";
import "./safemath.sol";

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
    // Get the total token supply
    function totalSupply() view public returns (uint256);

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) view public returns (uint256);

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) public returns (bool success);

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) view public returns (uint256 remaining);

    // Sets a minter
    function setMinter(address _newMinter) public returns (bool);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    // Triggered when minting is done
    event Mint(address indexed to, uint256 amount);

    // Triggered when minting is done
    event Minter(address indexed minter);
}


contract JudeDikeToken is ERC20Interface, Ownable {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;
    
    string symbol;
    string public name;
    uint256 public constant decimals = 18;
    uint256 public _totalSupply;
    address public minter;

    // Owner of this contract
    // address public owner;

    // Balances for each account
    mapping (address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) allowed;

    constructor(string memory _symbol, string memory _name, uint256 _supply) public payable onlyOwner {
        symbol = _symbol;
        name = _name;
        _totalSupply = _supply;
        address owner = owner();
        balances[owner] = _supply;
    }
    
    function details() public view returns (string memory, string memory, uint256){
        return(symbol, name, _totalSupply);
    }

    // What total number of this token in circulation
    function totalSupply() view public returns (uint256) {
        return _totalSupply;
    }

    // increase the total supply of this token in circulation
    function addTotalSupply(uint256 _volume) public {
        _totalSupply = _totalSupply.add(_volume);
    }

    // What is the balance of a particular account?
    function balanceOf(address _owner) view public returns (uint256) {
        return balances[_owner];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Receiver address is not available");
        require(_value <= balances[msg.sender], "Not enough coins for this transaction"); 
        balances[msg.sender] = balances[msg.sender].sub(_value); 
        balances[_to] = balances[_to].add(_value); 
        emit Transfer(msg.sender, _to, _value); 
        return true; 
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(
    address _from,
    address _to,
    uint256 _value
    ) public returns (bool) {
        require(_to != address(0), "Receiver address is not available");
        require(_value > 0, "value needs to be specified");
        require(_value <= balances[_from], "not enough coins to be transfered");
        require(_value <= allowed[_from][msg.sender], "you do not have permission to spend these coins"); 
        balances[_from] = balances[_from].sub(_value); 
        balances[_to] = balances[_to].add(_value); 
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value); 
        emit Transfer(_from, _to, _value); 
        return true; 
    }


    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function setMinter(address _newMinter) public onlyOwner returns (bool) {
        // require(msg.sender == minter || msg.sender == owner);
        minter = _newMinter;
        emit Minter(_newMinter);
    }
    
    function mint(uint256 _value) public returns (bool) {
        require(_value > 0, "value needs to be specified");
        require(msg.sender == minter, "You are not authorized to mint");
        _totalSupply = _totalSupply.add(_value);
        address owner = owner();
        balances[owner] = balances[owner].add(_value);
        emit Mint(owner, _value);
        return true;
    }


}
