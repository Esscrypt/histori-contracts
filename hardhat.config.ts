import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  paths: {
    sources: "./src",
    tests: "./test",
    cache: "./cache",
    artifacts: "./out"
  },
  networks: {
    sepolia: {
        url: `https://sepolia.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
        accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    mainnet: {
        url: `https://mainnet.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
        accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    zkTestnet: {
        url: "https://sepolia.era.zksync.dev", // The testnet RPC URL of ZKsync Era network.
        ethNetwork: "sepolia", // The Ethereum Web3 RPC URL, or the identifier of the network (e.g. `mainnet` or `sepolia`)
        zksync: true,
        accounts: [`0x${process.env.PRIVATE_KEY}`],
      },
    zkSyncMainnet: {
        url: "https://mainnet.era.zksync.io", // The testnet RPC URL of ZKsync Era network.
        ethNetwork: "mainnet", // The Ethereum Web3 RPC URL, or the identifier of the network (e.g. `mainnet` or `sepolia`)
        zksync: true,
        accounts: [`0x${process.env.PRIVATE_KEY}`],
    }
},
};

export default config;
