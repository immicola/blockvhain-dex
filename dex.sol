// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0; 

 

interface IERC20 { 

    function transfer(address recipient, uint256 amount) external returns (bool); 

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 

    function balanceOf(address account) external view returns (uint256); 

} 

 

contract SimpleDex { 

    address public owner; 

 

    event Deposit(address indexed user, address indexed token, uint256 amount); 

    event Withdraw(address indexed user, address indexed token, uint256 amount); 

    event Trade(address indexed user, address indexed tokenFrom, address indexed tokenTo, uint256 amountIn, uint256 amountOut); 

    event AddLiquidity(address indexed provider, address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB); 

    event RemoveLiquidity(address indexed provider, address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB); 

 

    mapping(address => mapping(address => uint256)) public balances; // User token balances 

    mapping(address => mapping(address => uint256)) public liquidity; // Liquidity pools 

 

    constructor() { 

        owner = msg.sender; 

    } 

 

    // Deposit tokens into the contract 

    function deposit(address token, uint256 amount) external { 

        require(amount > 0, "Amount must be greater than zero"); 

        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Token transfer failed"); 

 

        balances[msg.sender][token] += amount; 

 

        emit Deposit(msg.sender, token, amount); 

    } 

 

    // Withdraw tokens from the contract 

    function withdraw(address token, uint256 amount) external { 

        require(balances[msg.sender][token] >= amount, "Insufficient balance"); 

 

        balances[msg.sender][token] -= amount; 

        require(IERC20(token).transfer(msg.sender, amount), "Token transfer failed"); 

 

        emit Withdraw(msg.sender, token, amount); 

    } 

 

    // Trade tokens using liquidity pools 

    function trade(address tokenFrom, address tokenTo, uint256 amount) external { 

        require(balances[msg.sender][tokenFrom] >= amount, "Insufficient balance"); 

        require(tokenFrom != tokenTo, "Cannot trade the same token"); 

        require(liquidity[tokenFrom][tokenTo] > 0 && liquidity[tokenTo][tokenFrom] > 0, "No liquidity available"); 

 

        uint256 amountOut = getTradeAmount(tokenFrom, tokenTo, amount); 

 

        // Update user balances 

        balances[msg.sender][tokenFrom] -= amount; 

        balances[msg.sender][tokenTo] += amountOut; 

 

        // Update liquidity pools 

        liquidity[tokenFrom][tokenTo] += amount; 

        liquidity[tokenTo][tokenFrom] -= amountOut; 

 

        emit Trade(msg.sender, tokenFrom, tokenTo, amount, amountOut); 

    } 

 

    // Add liquidity to the pool 

    function addLiquidity( 

        address tokenA, 

        address tokenB, 

        uint256 amountA, 

        uint256 amountB 

    ) external { 

        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero"); 

        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountA), "TokenA transfer failed"); 

        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountB), "TokenB transfer failed"); 

 

        liquidity[tokenA][tokenB] += amountA; 

        liquidity[tokenB][tokenA] += amountB; 

 

        emit AddLiquidity(msg.sender, tokenA, tokenB, amountA, amountB); 

    } 

 

    // Remove liquidity from the pool 

    function removeLiquidity( 

        address tokenA, 

        address tokenB, 

        uint256 amountA, 

        uint256 amountB 

    ) external { 

        require(liquidity[tokenA][tokenB] >= amountA, "Insufficient liquidity for tokenA"); 

        require(liquidity[tokenB][tokenA] >= amountB, "Insufficient liquidity for tokenB"); 

 

        liquidity[tokenA][tokenB] -= amountA; 

        liquidity[tokenB][tokenA] -= amountB; 

 

        require(IERC20(tokenA).transfer(msg.sender, amountA), "TokenA transfer failed"); 

        require(IERC20(tokenB).transfer(msg.sender, amountB), "TokenB transfer failed"); 

 

        emit RemoveLiquidity(msg.sender, tokenA, tokenB, amountA, amountB); 

    } 

 

    // Get trade amount based on liquidity pool 

    function getTradeAmount(address tokenFrom, address tokenTo, uint256 amountIn) public view returns (uint256) { 

        uint256 reserveIn = liquidity[tokenFrom][tokenTo]; 

        uint256 reserveOut = liquidity[tokenTo][tokenFrom]; 

        require(reserveIn > 0 && reserveOut > 0, "Insufficient liquidity"); 

 

        // Simple constant product formula (x * y = k) 

        uint256 amountOut = (amountIn * reserveOut) / (reserveIn + amountIn); 

        return amountOut; 

    } 

 

    // Get liquidity for a pair of tokens 

    function getLiquidity(address tokenA, address tokenB) external view returns (uint256, uint256) { 

        return (liquidity[tokenA][tokenB], liquidity[tokenB][tokenA]); 

    } 

}