// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./SigUtils.sol";
import "../src/Deposit.sol";
import "../src/interface/IDeposit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

contract ERC20PermitMock is ERC20Permit {
    constructor() ERC20("MockToken", "MTK") ERC20Permit("MockToken") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}

contract DepositTest is Test {
    Deposit public depositContract;
    ERC20Permit public tokenPermit;
    ERC20PermitUpgradeable public tokenUpgradable;

    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;

    function setUp() public {
        // Deploy MockToken and Deposit contract
        tokenPermit = new ERC20PermitMock();
        tokenUpgradable = ERC20PermitUpgradeable(address(tokenPermit));

        sigUtils = new SigUtils(tokenPermit.DOMAIN_SEPARATOR());

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);

        depositContract = new Deposit();
        
        // Initialize Deposit contract
        vm.startPrank(owner);
        depositContract.initialize(tokenUpgradable);
        vm.stopPrank();

                // Distribute tokens to users
        tokenPermit.transfer(owner, 1000 * 10**18);
        tokenPermit.transfer(spender, 1000 * 10**18);
    
    }


    // function testInitialize() public {
    //     assertEq(address(depositContract.token()), address(tokenPermit));
    //     assertEq(depositContract.rewardsRate(), 2_500_000 * 10**18 / (10 * 365 days));
    // }

    function test_Permit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1e18,
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        tokenPermit.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(tokenPermit.allowance(owner, spender), 1e18);
        assertEq(tokenPermit.nonces(owner), 1);
    }

    function testDepositForAPI() public {
        vm.startPrank(owner);
        
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(depositContract),
            value: 1e18,
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        // Approve tokens and deposit for API
        depositContract.depositForAPI(1e18, APITier.Starter, 1 days, v, r, s);

        // Check if deposit was recorded
        assertEq(depositContract.apiDeposits(owner), 1e18);
        assertEq(uint(depositContract.apiUserTiers(owner)), uint(APITier.Starter));
        vm.stopPrank();
    }

    // function testReleaseRewards() public {
    //     vm.startPrank(user1);
    //     uint256 amount = 100 * 10**18;
    //     uint256 deadline = block.timestamp + 1 hours;

    //     // Deposit for API
    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1, amount, deadline);
    //     depositContract.depositForAPI(amount, Deposit.APITier.Starter, deadline, abi.encodePacked(r, s, v));
    //     vm.stopPrank();

    //     // Fast-forward time to simulate rewards accumulation
    //     skip(30 days);

    //     // Check and release rewards
    //     vm.startPrank(user1);
    //     uint256 rewardsBefore = tokenPermit.balanceOf(user1);
    //     depositContract.releaseRewards();
    //     uint256 rewardsAfter = tokenPermit.balanceOf(user1);

    //     assertGt(rewardsAfter, rewardsBefore); // Ensure rewards were released
    //     vm.stopPrank();
    // }

    // function testWithdraw() public {
    //     vm.startPrank(owner);

    //     // Deposit tokens to the contract and withdraw
    //     uint256 depositAmount = 500 * 10**18;
    //     tokenPermit.transfer(address(depositContract), depositAmount);

    //     uint256 initialBalance = tokenPermit.balanceOf(owner);
    //     depositContract.withdraw(100 * 10**18);
    //     uint256 finalBalance = tokenPermit.balanceOf(owner);

    //     assertEq(finalBalance, initialBalance + 100 * 10**18);
    //     vm.stopPrank();
    // }

    // function testWithdrawRevertsForNonOwner() public {
    //     vm.prank(user1); // Simulate transaction from user1
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     depositContract.withdraw(100 * 10**18); // Should revert because user1 is not the owner
    // }

    // function testCannotDepositZero() public {
    //     vm.startPrank(user1);
    //     uint256 deadline = block.timestamp + 1 hours;
    //     bytes memory sig = new bytes(65);

    //     vm.expectRevert("Amount must be greater than 0");
    //     depositContract.depositForAPI(0, Deposit.APITier.Starter, deadline, sig);
    //     vm.stopPrank();
    // }

    // function testTotalRewardsExceedReverts() public {
    //     vm.startPrank(user1);
    //     uint256 amount = 1_000_000 * 10**18; // A very large amount to simulate exceeding rewards
    //     uint256 deadline = block.timestamp + 1 hours;

    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1, amount, deadline);
    //     tokenPermit.permit(user1, address(depositContract), amount, deadline, v, r, s);
    //     tokenPermit.approve(address(depositContract), amount);
    //     depositContract.depositForAPI(amount, Deposit.APITier.Starter, deadline, abi.encodePacked(r, s, v));
    //     vm.stopPrank();

    //     skip(365 days * 10); // Fast forward to try exceeding rewards

    //     vm.startPrank(user1);
    //     vm.expectRevert("Total rewards exceeded");
    //     depositContract.releaseRewards();
    //     vm.stopPrank();
    // }
}
