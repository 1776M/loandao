// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Minimal ERC20 interface (compatible with MockUSDC and MockDAOToken)
interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

/**
 * (1) Minimal Borrower DAO Contract
 *
 * - Holds the DAO's governance token (collateral token)
 * - Approves collateral to the loan contract
 * - Approves USDC (or any ERC20) to the loan contract
 * - Executes loan actions so that the DAO contract is msg.sender in DAOLoanContract
 */
contract BorrowerDAO {
    address public owner;
    IERC20 public daoToken;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not DAO owner");
        _;
    }

    constructor(IERC20 _daoToken) {
        owner = msg.sender;
        daoToken = _daoToken;
    }

    /// Approve DAO collateral tokens to the loan contract (for fundLoan() to lock)
    function approveLoanCollateral(address loanContract, uint256 amount) external onlyOwner {
        daoToken.approve(loanContract, amount);
    }

    /// Generic token approval (e.g. USDC) from this DAO to `spender` (loan contract)
    function approveToken(IERC20 token, address spender, uint256 amount) external onlyOwner {
        token.approve(spender, amount);
    }

    /// Execute arbitrary loan actions so the DAO is msg.sender in DAOLoanContract
    function executeLoanAction(address loanContract, bytes calldata data) external onlyOwner {
        (bool success, ) = loanContract.call(data);
        require(success, "DAO execution failed");
    }
}
