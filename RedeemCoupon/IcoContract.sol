// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./SafeMath.sol";
import "./Pausable.sol";
import "./IcoToken.sol";

contract IcoContract is Pausable{
//define SafeMath library for uint256/
using SafeMath for uint256;
IcoToken public ico ;
uint256 public tokenCreationCap;
uint256 public totalSupply;
uint256 public fundingStartTime;
uint256 public fundingEndTime;
uint256 public minContribution;
uint256 public tokenExchangeRate;
address payable public ethFundDeposit;
address public icoAddress;

bool public isFinalized;

event LogCreateICO(address indexed from, address indexed to, uint256 val);

function CreateIco(address to, uint256 val) internal returns (bool success) {
    emit LogCreateICO(address(0), to, val);
    return ico.sell(to, val);/*call to IcoToken sell() method*/
}

constructor(
    address payable _ethFundDeposit,
    address _icoAddress,
    uint256 _tokenCreationCap,
    uint256 _tokenExchangeRate,
    uint256 _fundingStartTime,
    uint256 _fundingEndTime,
    uint256 _minContribution
) {
    ethFundDeposit = _ethFundDeposit;
    icoAddress = _icoAddress;
    tokenCreationCap = _tokenCreationCap;
    tokenExchangeRate = _tokenExchangeRate;
    fundingStartTime = _fundingStartTime;
    minContribution = _minContribution;
    fundingEndTime = _fundingEndTime;
    ico = IcoToken(icoAddress);
    isFinalized = false;
}

/*call fallback method*/
receive() external payable{
    createTokens(msg.sender, msg.value);
}

function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
    require(tokenCreationCap > totalSupply, "Token creation cap reached");
    require(block.timestamp >= fundingStartTime, "Funding has not started yet");
    require(block.timestamp <= fundingEndTime, "Funding has ended");
    require(_value >= minContribution, "Contribution amount is less than minimum");
    require(!isFinalized, "Contract is already finalized");
    
    uint256 tokens = _value.mul(tokenExchangeRate);
    uint256 checkSupply = totalSupply.add(tokens);
    
    if (tokenCreationCap < checkSupply) {
        uint256 tokenToAllocate = tokenCreationCap.sub(totalSupply);
        uint256 tokenToRefund = tokens.sub(tokenToAllocate);
        uint256 etherToRefund = tokenToRefund / tokenExchangeRate;
        totalSupply = tokenCreationCap;
        
        require(CreateIco(_beneficiary, tokenToAllocate));
        payable(msg.sender).transfer(etherToRefund);
        ethFundDeposit.transfer(address(this).balance);
        return;
    }
    
    totalSupply = checkSupply;
    require(CreateIco(_beneficiary, tokens));
    ethFundDeposit.transfer(address(this).balance);
}

function finalize() external onlyOwner {
    require(!isFinalized, "Contract is already finalized");
    isFinalized = true;
    ethFundDeposit.transfer(address(this).balance);
}
}