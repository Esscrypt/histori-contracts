// scripts/upgrade.s.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "forge-std/Script.sol";
import {Deposit} from "../src/Deposit.sol";

import "openzeppelin-foundry-upgrades/Upgrades.sol";

contract UpgradeDeposit is Script {

    function run() external {
        // Load environment variables
        string memory rpcUrl = vm.envString("RPC_URL");
        string memory privateKey = vm.envString("PRIVATE_KEY");

        // Set the RPC URL and account for the broadcast
        vm.setEnv("RPC_URL", rpcUrl);
        vm.setEnv("PRIVATE_KEY", privateKey);

        // Start broadcasting the transaction
        vm.startBroadcast();

        // Upgrades.upgradeProxy(
        //     transparentProxy,
        //     "DepositV2.sol",
        //     "" // optionally heve we can call an additional function: abi.encodeCall(MyContractV2.foo, ("arguments for foo"))
        // );
        // console.log("Upgraded Deposit contract at address:", DEPOSIT_ADDRESS);

        vm.stopBroadcast();
    }
}
