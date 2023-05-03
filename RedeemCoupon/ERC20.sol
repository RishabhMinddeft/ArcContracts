// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract ERC20 {
    uint256  public  totalSupply;

    function balanceOf(address account) public virtual view returns (uint256) {}

    function allowance(address owner, address spender) public virtual view returns (uint256) {}

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {}

    function approve(address spender, uint256 amount) public virtual returns (bool) {}

    function transferFrom(address sender, address recipient, uint256 amount) virtual public returns (bool) {}

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
