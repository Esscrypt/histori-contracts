// scripts/deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "forge-std/Script.sol";
import {Vesting} from "../src/Vesting.sol";

import "openzeppelin-foundry-upgrades/Upgrades.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

import {console2} from "forge-std/console2.sol";

contract DeployVesting is Script {
    function run() external {
        // Load environment variables
        string memory rpcUrl = vm.envString("RPC_URL");
        string memory privateKey = vm.envString("PRIVATE_KEY");

        // Set the RPC URL and account for the broadcast
        vm.setEnv("RPC_URL", rpcUrl);
        vm.setEnv("PRIVATE_KEY", privateKey);

        // Start broadcasting the transaction
        vm.startBroadcast();

        ERC20PermitUpgradeable token = ERC20PermitUpgradeable(0x31bCEaf326759672bD9C72c6D465bDEEC0C188A8);
        //NOTE: this is for ethereum sepolia, replace with your own token address
        address proxy = Upgrades.deployUUPSProxy(
            "Vesting.sol",
            abi.encodeCall(Vesting.initialize, (token))
        );

        // Log the deployed proxy address and chain ID
        console2.log("Deployed Vesting UUPS Proxy at address:", address(proxy));

        console2.log("Token address:", address(Vesting(proxy).token()));
        console2.log("Chain ID:", block.chainid);

        vm.stopBroadcast();
    }
}
