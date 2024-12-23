// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "forge-std/Script.sol";
import "../src/Vesting.sol"; // Adjust path as needed

contract AddBeneficiaries is Script {
    // Vesting contract address
    address public vestingContractAddress;
    
    function setUp() public {
        // Load the vesting contract address from the environment variable
        vestingContractAddress = vm.envAddress("VESTING_CONTRACT_ADDRESS");
    }

    function run() public {
        // Start broadcasting the transaction
        vm.startBroadcast();

        // Get the vesting contract instance
        Vesting vesting = Vesting(vestingContractAddress);

        // Define beneficiaries and their allocations according to tokenomics
        address[] memory beneficiaries = new address[](9);
        uint256 [] memory allocations = new uint256[](9);
        uint256 [] memory cliffDurations = new uint256[](9);
        uint256 [] memory vestingDurations = new uint256[](9);

        // beneficiaries[0] = 0x...; // Replace with actual address
        allocations[0] = 1_500_000 * 10**18; // 1,500,000 HST
        cliffDurations[0] = 365 days; // 12 months
        vestingDurations[0] = 24 * 30 days; // 24 months

        // beneficiaries[1] = 0x...; // Replace with actual address
        allocations[1] = 1_000_000 * 10**18; // 1,000,000 HST
        cliffDurations[1] = 365 days; // 12 months
        vestingDurations[1] = 36 * 30 days; // 36 months

        // beneficiaries[2] = 0x...; // Replace with actual address
        allocations[2] = 500_000 * 10**18; // 500,000 HST
        cliffDurations[2] = 180 days; // 6 months
        vestingDurations[2] = 12 * 30 days; // 12 months

        // beneficiaries[3] = 0x...; // Replace with actual address
        allocations[3] = 500_000 * 10**18; // 500,000 HST
        cliffDurations[3] = 180 days; // 6 months
        vestingDurations[3] = 12 * 30 days; // 12 months

        // beneficiaries[4] = 0x...; // Replace with actual address
        allocations[4] = 1_000_000 * 10**18; // 1,000,000 HST
        cliffDurations[4] = 0; // No cliff
        vestingDurations[4] = 10 * 365 days; // 10 years

        // beneficiaries[5] = 0x...; // Replace with actual address
        allocations[5] = 1_000_000 * 10**18; // 1,000,000 HST
        cliffDurations[5] = 0; // No cliff
        vestingDurations[5] = 10 * 365 days; // 10 years

        // beneficiaries[6] = 0x...; // Replace with actual address
        allocations[6] = 1_000_000 * 10**18; // 1,000,000 HST
        cliffDurations[6] = 0; // No cliff
        vestingDurations[6] = 10 * 365 days; // 10 years

        // beneficiaries[7] = 0x...; // Replace with actual address
        allocations[7] = 500_000 * 10**18; // 500,000 HST
        cliffDurations[7] = 0; // No cliff
        vestingDurations[7] = 0; // Available immediately

        // beneficiaries[8] = 0x...; // Replace with actual address
        allocations[8] = 500_000 * 10**18; // 500,000 HST
        cliffDurations[8] = 0; // No cliff
        vestingDurations[8] = 0; // Available immediately

        // Loop through each beneficiary and add them to the vesting contract
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            vesting.addBeneficiary(
                beneficiaries[i],
                allocations[i],
                cliffDurations[i],
                vestingDurations[i]
            );
            console.log("Added beneficiary:", beneficiaries[i]);
        }

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}
