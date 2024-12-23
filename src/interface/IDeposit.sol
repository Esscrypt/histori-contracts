// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

enum APITier { Starter, Growth, Business }
enum RPCTier { Starter, Growth, Business }

interface IDeposit {

    function depositForAPI(
        uint256 amount,
        APITier tier,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function depositForRPC(
        uint256 amount,
        RPCTier tier,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function releaseRewards() external;

    function withdraw(uint256 amount) external;
}
