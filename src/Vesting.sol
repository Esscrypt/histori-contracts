// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

import "./interface/IVesting.sol";

/**
 * @title Vesting Contract
 * @dev This contract allows the vesting of tokens over time for beneficiaries.
 */
contract Vesting is IVesting, Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20 for ERC20PermitUpgradeable;

    mapping(address => Beneficiary) public beneficiaries;
    ERC20PermitUpgradeable public token;

    event TokensReleased(address indexed beneficiary, uint256 amount);

    // Initialize the contract with the token
    function initialize(ERC20PermitUpgradeable _token) public initializer {
        __Ownable_init(msg.sender); // Initialize the Ownable module
        token = _token;
    }

    /**
     * @notice Adds a beneficiary with vesting rules.
     * @param beneficiary The address of the beneficiary.
     * @param totalAllocation The total tokens allocated to the beneficiary.
     * @param cliffDuration The cliff duration in seconds.
     * @param vestingDuration The total vesting duration in seconds.
     * @dev Only the owner can call this function.
     */
    function addBeneficiary(
        address beneficiary,
        uint256 totalAllocation,
        uint256 cliffDuration, // in seconds
        uint256 vestingDuration // in seconds
    ) external onlyOwner {
        // Checks
        require(beneficiaries[beneficiary].totalAllocation == 0, "Beneficiary already exists");
        require(totalAllocation > 0, "Allocation must be greater than 0");

        // Effects
        beneficiaries[beneficiary] = Beneficiary({
            totalAllocation: totalAllocation,
            released: 0,
            start: block.timestamp,
            cliff: cliffDuration,
            duration: vestingDuration
        });
    }

    /**
     * @notice Releases tokens to the beneficiary.
     * @dev This function calculates the releasable tokens and transfers them to the beneficiary.
     */
    function release() external nonReentrant {
        // Checks
        Beneficiary storage beneficiary = beneficiaries[msg.sender];
        require(beneficiary.totalAllocation > 0, "No tokens to release");

        uint256 unreleased = _releasableAmount(beneficiary);
        require(unreleased > 0, "No tokens are due");

        // Effects
        beneficiary.released += unreleased;

        // Interactions
        token.safeTransfer(msg.sender, unreleased); // Safe transfer of tokens

        emit TokensReleased(msg.sender, unreleased);
    }

    /**
     * @dev Calculates the releasable amount based on vesting rules.
     * @param beneficiary The beneficiary structure.
     * @return The amount of tokens that can be released.
     */
    function _releasableAmount(Beneficiary memory beneficiary) internal view returns (uint256) {
        if (block.timestamp < beneficiary.start + beneficiary.cliff) {
            return 0; // Cliff not reached
        } else if (block.timestamp >= beneficiary.start + beneficiary.duration) {
            return beneficiary.totalAllocation - beneficiary.released; // All tokens are releasable
        } else {
            uint256 elapsedTime = block.timestamp - beneficiary.start - beneficiary.cliff;
            uint256 totalVestingTime = beneficiary.duration - beneficiary.cliff;
            uint256 vestedAmount = (beneficiary.totalAllocation * elapsedTime) / totalVestingTime;
            return vestedAmount - beneficiary.released; // Vested amount minus already released tokens
        }
    }

    /**
     * @notice Retrieves details about a specific beneficiary.
     * @param beneficiary The address of the beneficiary.
     * @return totalAllocation Total tokens allocated to the beneficiary.
     * @return released Tokens released to the beneficiary.
     * @return start Start time of the vesting period.
     * @return cliff Cliff duration in seconds.
     * @return duration Total vesting duration in seconds.
     */
    function getBeneficiaryDetails(address beneficiary) external view returns (
        uint256 totalAllocation,
        uint256 released,
        uint256 start,
        uint256 cliff,
        uint256 duration
    ) {
        Beneficiary memory b = beneficiaries[beneficiary];
        return (b.totalAllocation, b.released, b.start, b.cliff, b.duration);
    }

    /**
     * @dev Required override function for UUPS.
     */
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}
}
