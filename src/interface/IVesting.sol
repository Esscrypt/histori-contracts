// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
    
struct Beneficiary {
    uint256 totalAllocation; // Total tokens allocated to the beneficiary
    uint256 released;         // Tokens released to the beneficiary
    uint256 start;           // Start time of the vesting period
    uint256 cliff;           // Cliff duration in seconds
    uint256 duration;        // Total vesting duration in seconds
}

interface IVesting {

    function beneficiaries(address beneficiary) external view returns (
        uint256 totalAllocation,
        uint256 released,
        uint256 start,
        uint256 cliff,
        uint256 duration
    );

    function addBeneficiary(
        address beneficiary,
        uint256 totalAllocation,
        uint256 cliffDuration,
        uint256 vestingDuration
    ) external;

    function release() external;

    function getBeneficiaryDetails(address beneficiary) external view returns (
        uint256 totalAllocation,
        uint256 released,
        uint256 start,
        uint256 cliff,
        uint256 duration
    );
}
