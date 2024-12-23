// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IReactorCallback} from "./interface/IReactorCallback.sol";
import {ResolvedOrder} from "./structs/ReactorStructs.sol";

contract Executor is IReactorCallback {
    address public owner;
    address public reactor;

    /// @notice Sets the owner of the contract
    constructor(address _reactor) {
        owner = msg.sender;
        reactor = _reactor;
    }

    /// @notice Allows the owner to withdraw ERC20 tokens sent to the contract by mistake
    function withdrawERC20(address token, uint256 amount) external {
        require(msg.sender == owner, "Executor: Only owner");
        IERC20(token).transfer(msg.sender, amount);
    }

    /// @notice Called by the reactor during the execution of an order
    /// @param resolvedOrders Contains inputs and outputs for the orders
    /// @param callbackData Arbitrary callback data specified for the order execution
    /// @dev Approves the output tokens to the reactor for transfer
    function reactorCallback(ResolvedOrder[] memory resolvedOrders, bytes memory callbackData) external override {
        for (uint256 i = 0; i < resolvedOrders.length; i++) {
            ResolvedOrder memory order = resolvedOrders[i];

            // Use permit if available, otherwise fallback to approve
            if (supportsInterface(address(order.input.token), type(IERC20Permit).interfaceId) && callbackData.length > 0) {
                // Decode the callbackData for permit approval
                (uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) = abi.decode(
                    callbackData,
                    (uint256, uint256, uint8, bytes32, bytes32)
                );

                // Call the permit function to approve the reactor
                IERC20Permit(address(order.input.token)).permit(msg.sender, reactor, value, deadline, v, r, s);
            } else {
                // Fallback to approve
                IERC20(order.input.token).approve(reactor, type(uint256).max);
            }
        }
    }

    /// @notice Executes a custom strategy before approving tokens to the reactor
    /// @param order The order to process
    /// @param callbackData Data required for executing the custom strategy
    function executeStrategy(ResolvedOrder memory order, bytes memory callbackData) external {
        // Implement your custom strategy here. For example:
        // Swap tokens, interact with liquidity pools, etc.

        // Approve output tokens to the reactor after the strategy
        // Use permit if available, otherwise fallback to approve
        if (supportsInterface(address(order.input.token), type(IERC20Permit).interfaceId) && callbackData.length > 0) {
            // Decode the callbackData for permit approval
            (uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) = abi.decode(
                callbackData,
                (uint256, uint256, uint8, bytes32, bytes32)
            );

            // Call the permit function to approve the reactor
            IERC20Permit(address(order.input.token)).permit(msg.sender, reactor, value, deadline, v, r, s);
        } else {
            // Fallback to approve
            IERC20(order.input.token).approve(reactor, type(uint256).max);
        }
    }

    /// @notice Checks if a token supports a specific interface
    /// @param token The address of the token to check
    /// @param interfaceId The interface identifier (ERC165)
    /// @return True if the token supports the specified interface, false otherwise
    function supportsInterface(address token, bytes4 interfaceId) internal view returns (bool) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId)
        );
        return success && data.length == 32 && abi.decode(data, (bool));
    }
}