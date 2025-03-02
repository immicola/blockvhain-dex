// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0; 

 

contract SimpleERC20 { 

    string public name; 

    string public symbol; 

    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping(address => uint256) public balanceOf; 

    mapping(address => mapping(address => uint256)) public allowance; 

 

    event Transfer(address indexed from, address indexed to, uint256 value); 

    event Approval(address indexed owner, address indexed spender, uint256 value); 

 

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) { 

        name = _name; 

        symbol = _symbol; 

        decimals = 18; 

        totalSupply = _initialSupply * 10 ** uint256(decimals); 

        balanceOf[msg.sender] = totalSupply; 

        emit Transfer(address(0), msg.sender, totalSupply); 

    } 

 

    function transfer(address recipient, uint256 amount) external returns (bool) { 

        require(balanceOf[msg.sender] >= amount, "Insufficient balance"); 

        balanceOf[msg.sender] -= amount; 

        balanceOf[recipient] += amount; 

        emit Transfer(msg.sender, recipient, amount); 

        return true; 

    } 

 

    function approve(address spender, uint256 amount) external returns (bool) { 

        allowance[msg.sender][spender] = amount; 

        emit Approval(msg.sender, spender, amount); 

        return true; 

    } 

 

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) { 

        require(balanceOf[sender] >= amount, "Insufficient balance"); 

        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded"); 

        balanceOf[sender] -= amount; 

        balanceOf[recipient] += amount; 

        allowance[sender][msg.sender] -= amount; 

        emit Transfer(sender, recipient, amount); 

        return true; 

    } 

}