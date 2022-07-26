// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
contract PingPongScore {
    using SafeMath for uint;
    address private owner;
    string private name;
    string private symbol;
    mapping (address => uint256) private score;
    mapping (address => uint256) private token;
    mapping (address => mapping(address => uint)) private allowance;
    uint private totalSupply;
    uint public coefficient;
    address private treasure;
  

    constructor (string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        owner = msg.sender;
        coefficient = 10;
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
    function _treasureBalance() external view returns(uint){
        return token[treasure];
    }

    function viewScore(address _player) public view returns(uint) {
        return score[_player];
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


    modifier onlyOwner {
        require (msg.sender == owner, 'You are not an owner');
        _;
    }

    function setCoefficient(uint _newCoefficient) public onlyOwner {
        coefficient = _newCoefficient;
    }


    /* ------------------------------------------- MAIN PROCESS --------------------------------------------------- */


    // score
    function addScore(address _player, uint _score) public onlyOwner {
        require (_score >= 1 && _score <= 5, 'Added score must be in range from 1 to 5');
        score[_player] += _score;
        tokenMint(_player, _score);
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
        require (_amount >= token[treasure], 'Amount must be less than');
        require (_to != address(0), 'Stop to burn, man');
        token[treasure] -= _amount;
        token[_to] += _amount;

    }

    // pari-bet
    mapping (address => uint) private _pariList;
    address[2] public _pariArray;

    function testBalance(address _test) public view returns(uint){
        return _pariList[_test];
    }

    function getInPari() external { 
        require (_pariList[msg.sender] == 0, 'You already in pari');
        require (token[msg.sender] >= 1, 'You have not enough tokens');
        _pariList[msg.sender] += 1;
        token[msg.sender] -= 1;
        //address _toArray = msg.sender; 
        _pariArray[0] = msg.sender;
    }

    function _pariArrayAdd() internal{
        if (_pariArray[0] == address(0)) 
        { _pariArray[0] = msg.sender;}
        else {_pariArray[1] = msg.sender;}
    }
    function setWinner(address _winner) public onlyOwner{
        _pariList[_winner] -= 2;
        token[_winner] += 2;
        _pariArray[0] = address(0);
        _pariArray[1] = address(0);
    }

}
