// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./StandardToken.sol";
import "./SafeMath.sol";
import "./Pausable.sol";

abstract contract IcoToken is StandardToken, Pausable {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    string public version;
    uint8 public decimals;
    address public icoSaleDeposit;
    address public icoContract;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, string memory _version) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        version = _version;
    }

    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(recipient, amount);
    }

    function approve(address spender, uint256 amount) public override whenNotPaused returns (bool) {
        return super.approve(spender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }

    function setIcoContract(address _icoContract) public onlyOwner {
        if(_icoContract != address(0)){
            icoContract = _icoContract;
        }
   
    }
     function sell(address _recipient, uint256 _value) public whenNotPaused returns (bool success){
        assert(_value > 0);
        require(msg.sender == icoContract);
        
        _balances[_recipient] = _balances[_recipient].add(_value);
        totalSupply = totalSupply.add(_value);
        
        emit Transfer(address(0),owner,_value);
        emit Transfer(owner,_recipient,_value);
        return true;
    }
}