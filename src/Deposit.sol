// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

import "./interface/IDeposit.sol";

/**
 * @title Deposit Contract
 * @dev This contract allows users to deposit tokens and earn rewards based on their deposits.
 */
contract Deposit is IDeposit, Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20 for ERC20PermitUpgradeable;

    ERC20PermitUpgradeable public token;

    mapping(address => uint256) public apiDeposits;
    mapping(address => APITier) public apiUserTiers;

    mapping(address => uint256) public rpcDeposits;
    mapping(address => RPCTier) public rpcUserTiers;

    event DepositedForAPI(address indexed depositor, uint256 amount, APITier tier);
    event DepositedForRPC(address indexed depositor, uint256 amount, RPCTier tier);
    event Withdrawn(address indexed owner, uint256 amount);

    uint256 public constant TOTAL_REWARDS = 2_500_000 * 10**18;
    uint256 public totalReleasedRewards;
    uint256 public lastUpdateTime;
    uint256 public rewardsRate;

    function initialize(ERC20PermitUpgradeable _token) public initializer {
        __Ownable_init(msg.sender);
        token = _token;
        rewardsRate = TOTAL_REWARDS / (10 * 365 days);
        __ReentrancyGuard_init();
    }

    /**
     * @notice Deposit for API access with a specific tier.
     */
    function depositForAPI(
        uint256 amount,
        APITier tier,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");

        // Effects: update state before external interactions
        apiDeposits[msg.sender] += amount;
        apiUserTiers[msg.sender] = tier;

        // Interactions: token transfer
        depositWithPermit(amount, deadline, v, r, s);

        emit DepositedForAPI(msg.sender, amount, tier);
    }

    /**
     * @notice Deposit for RPC access with a specific tier.
     */
    function depositForRPC(
        uint256 amount,
        RPCTier tier,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");

        // Effects: update state before external interactions
        rpcDeposits[msg.sender] += amount;
        rpcUserTiers[msg.sender] = tier;

        // Interactions: token transfer
        depositWithPermit(amount, deadline, v, r, s);

        emit DepositedForRPC(msg.sender, amount, tier);
    }

    /**
     * @notice Common function to deposit tokens using a permit.
     */
    function depositWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {

        token.permit(msg.sender, address(this), amount, deadline, v, r, s);
        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice Release rewards for the caller based on their deposit.
     */
    function releaseRewards() external nonReentrant {
        uint256 rewards = calculateRewards(msg.sender);
        require(rewards > 0, "No rewards to release");

        // Effects: update state before external interactions
        totalReleasedRewards += rewards;
        require(totalReleasedRewards <= TOTAL_REWARDS, "Total rewards exceeded");

        // Interactions
        token.safeTransfer(msg.sender, rewards);
        lastUpdateTime = block.timestamp;
    }

    /**
     * @dev Calculate rewards for a user based on their deposited amount and time elapsed.
     */
    function calculateRewards(address user) internal view returns (uint256) {
        uint256 depositedAmount = apiDeposits[user] + rpcDeposits[user];
        if (depositedAmount == 0) return 0;

        uint256 timeElapsed = block.timestamp - lastUpdateTime;
        return (depositedAmount * rewardsRate * timeElapsed) / 10**18;
    }

    /**
     * @notice Withdraw a specific amount of tokens from the contract.
     */
    function withdraw(uint256 amount) external onlyOwner nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= IERC20(token).balanceOf(address(this)), "Insufficient contract balance");

        // Interactions
        token.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev Required override function for UUPS.
     */
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}
}
