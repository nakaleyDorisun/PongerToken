// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OnlyOwner {
    address owner;
    modifier onlyOwner {
    require (msg.sender == owner, 'You are not an owner');
    _;
    }
}

contract PingPongToken is OnlyOwner {
    string public name;
    string public symbol;
    uint public totalSupply;
    mapping (address => uint256) public token;
    mapping (address => mapping(address => uint)) public allowance;

    constructor (string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }
  
    function _name() external view returns(string memory){
        return name;
        }

    function _symbol() external view returns(string memory){
        return symbol;
        }

    function decimals() public view returns (uint8) {
        return 18;
        }

    function _totalSupply() external view returns(uint){
        return totalSupply;
        }

    function balance(address _player) public view returns(uint) {
        return token[_player];
        }

    function _allowances(address _owner, address _spender) external view returns(uint) {
        return allowance[_owner][_spender];
        }

    function _approve(address _owner, address _spender, uint _amount) external {
        allowance[_owner][_spender] = _amount;
        }
    }

    /* ------------------------------------------- MAIN PROCESS --------------------------------------------------- */

    contract Score is OnlyOwner, PingPongToken {

    constructor(string memory _name, string memory _symbol) PingPongToken(_name, _symbol) {
        owner = msg.sender;

    }
    address public treasure = address(this);
    mapping (address => uint256) private score;
    uint public coefficient = 10;
    address[2] public _pariArray;
    address[] public _winList;

    
    function _treasureBalance() external view returns(uint){
        return token[treasure];
    }

    function viewScore(address _player) public view returns(uint) {
        return score[_player];
    }

    function addScore(address _player, uint _score) public onlyOwner {
        require (_score >= 1 && _score <= 5, 'Added score must be in range from 1 to 5');
        score[_player] += _score;
        tokenMint(_player, _score);
        }

    function setCoefficient(uint _newCoefficient) public onlyOwner {
        coefficient = _newCoefficient;
        }

    function removeScore(address _player, uint _score) public onlyOwner {
        score[_player] -= _score;
        }

    // token and treasure
    function tokenMint(address _player, uint _score) internal {
        uint a = _score * coefficient;
        uint b = (_score * coefficient) / 5;
        token[_player] += a - b;
        totalSupply += a;
        rewardToTreasure(b);
        }

    function rewardToTreasure(uint b) internal {
        token[treasure] += b;
        } 

    function withdrawFromTreasure(address _to, uint _amount) public onlyOwner {
        require (_amount <= token[treasure], 'Amount must be less than');
        require (_to != address(0), 'Stop to burn, man');
        token[treasure] -= _amount;
        token[_to] += _amount;

        }

    function getInPari() external { 
        require (_pariArray[0] == address(0) || _pariArray[1] == address(0), 'Pari pool is full');
        require (_pariArray[0] != msg.sender && _pariArray[1] != msg.sender, 'You are already in the pari');
        require (token[msg.sender] >= 1, 'You have not enough tokens');
        token[msg.sender] -= 1;
        token[owner] += 1;
        _pariArrayAdd();
    }

    function _pariArrayAdd() internal{
        if (_pariArray[0] == address(0)) 
        { 
            _pariArray[0] = msg.sender;
        }
        else 
        {
            _pariArray[1] = msg.sender;
        }
    }

    function setWinner(address _winner) public onlyOwner {
        _winList.push(_winner);
        uint win = 2; 
        token[_winner] += win;
        token[owner] -= win;
        _pariArray[0] = address(0);
        _pariArray[1] = address(0);
    }
}
