// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Define IERC20 interface HERE in this file
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

/**
 * (2) Minimal Lender DAO Contract
 */
contract LenderDAO {
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function executeLoan(address loanContract, bytes calldata data) external {
        require(msg.sender == admin, "Only admin");
        (bool success, ) = loanContract.call(data);
        require(success, "Loan execution failed");
    }

    // Add this function so can send USDC to the daoloancontract:
    function transferTokens(IERC20 token, address to, uint256 amount) external {
        require(msg.sender == admin, "Only admin");
        token.transfer(to, amount);
    }
}

