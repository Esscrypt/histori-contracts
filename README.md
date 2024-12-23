## Rebuild
```
forge clean && forge build
```

## Deploy using Foundry -> Sepolia and Mainnet
```
source .env
forge script script/deploy-token.s.sol --broadcast --fork-url $RPC_URL  --private-key $PRIVATE_KEY --verify
forge script script/deploy-deposit.s.sol --broadcast --fork-url $RPC_URL  --private-key $PRIVATE_KEY --verify
forge script script/deploy-vesting.s.sol --broadcast --fork-url $RPC_URL  --private-key $PRIVATE_KEY --verify
```

## Deploy using Foundry -> zksync
```
source .env
# zkSync Sepolia
forge script script/deploy-deposit.s.sol --zksync --broadcast --fork-url $RPC_URL  --private-key $PRIVATE_KEY --verifier zksync --verifier-url https://explorer.sepolia.era.zksync.dev/contract_verification --verify

forge script script/deploy-vesting.s.sol --zksync --broadcast --fork-url $RPC_URL  --private-key $PRIVATE_KEY --verifier zksync --verifier-url https://explorer.sepolia.era.zksync.dev/contract_verification --verify



#zkSync Mainnet
forge script script/deploy-deposit.s.sol --zksync --broadcast --fork-url $RPC_URL  --private-key $PRIVATE_KEY --verifier zksync --verify

forge script script/deploy-vesting.s.sol --broadcast --fork-url $RPC_URL  --private-key $PRIVATE_KEY --verify
```
