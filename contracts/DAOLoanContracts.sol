// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * (3) Loan Contract with Collateral Support
 */
interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract DAOLoanContract {
    address public borrower;
    address public lender;

    IERC20 public usdc;
    IERC20 public collateralToken;

    uint256 public principal;
    uint256 public interestRate; // e.g., 5% = 500 (bps)
    uint256 public collateralAmount;
    uint256 public startTime;
    uint256 public loanDuration = 20 minutes;
    uint256 public quarterly = 5 minutes;
    uint256 public numPayments = 4;
    bool public disbursed;
    uint256 public paymentsMade;

    constructor(
        address _borrower,
        address _lender,
        IERC20 _usdc,
        IERC20 _collateralToken,
        uint256 _principal,
        uint256 _interestRate,
        uint256 _collateralAmount
    ) {
        borrower = _borrower;
        lender = _lender;
        usdc = _usdc;
        collateralToken = _collateralToken;
        principal = _principal;
        interestRate = _interestRate;
        collateralAmount = _collateralAmount;
    }

    function fundLoan() external {
        require(msg.sender == lender, "Only lender");
        require(!disbursed, "Already disbursed");

        startTime = block.timestamp;
        disbursed = true;

        // Lock collateral
        collateralToken.transferFrom(borrower, address(this), collateralAmount);

        // Transfer loan to borrower
        usdc.transfer(borrower, principal);

    }

    function payInterest() external {
        require(disbursed, "Loan not active");
        require(msg.sender == borrower, "Only borrower");
        require(paymentsMade < numPayments, "All payments made");

        uint256 dueDate = startTime + quarterly * paymentsMade;
        require(block.timestamp >= dueDate, "Too early for this payment");

        uint256 interest = (principal * interestRate) / 10000 / 4; // Quarterly interest
        usdc.transferFrom(borrower, lender, interest);
        paymentsMade++;
    }

    function repayPrincipal() external {
        require(msg.sender == borrower, "Only borrower");
        require(block.timestamp >= startTime + loanDuration, "Too early");

        usdc.transferFrom(borrower, lender, principal);
        collateralToken.transfer(borrower, collateralAmount);
    }

    function claimCollateral() external {
        require(msg.sender == lender, "Only lender");
        require(block.timestamp > startTime + loanDuration, "Loan not expired");
        require(paymentsMade < numPayments, "No default");

        collateralToken.transfer(lender, collateralAmount);
    }
}

