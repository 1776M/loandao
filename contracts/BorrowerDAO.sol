// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * (1) Minimal Borrower DAO Contract
 */
contract BorrowerDAO {
    address public owner;
    IERC20 public daoToken;

    constructor(IERC20 _daoToken) {
        owner = msg.sender;
        daoToken = _daoToken;
    }

    function approveLoanCollateral(address loanContract, uint256 amount) external {
        require(msg.sender == owner, "Not DAO owner");
        daoToken.approve(loanContract, amount);
    }

    // 🌟 NEW FIX 1: Allows the DAO to approve USDC (or any ERC20) to the loan contract.
    function approveToken(IERC20 token, address spender, uint256 amount) external onlyOwner {
        token.approve(spender, amount);
    }

    // 🌟 NEW FIX 2: Allows the DAO to call functions on the loan contract,
    // ensuring the DAO (this contract) is the msg.sender.
    function executeLoanAction(address loanContract, bytes calldata data) external onlyOwner {
        (bool success, ) = loanContract.call(data);
        require(success, "DAO execution failed");
    }

}

