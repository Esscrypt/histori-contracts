// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title HistoriToken
 * @dev ERC20 Token with permit functionality for gasless approvals.
 */
contract HistoriToken is ERC20Permit, Ownable {
    uint256 public constant INITIAL_SUPPLY = 10_000_000 * 10 ** 18; // Initial supply of 10 million tokens

    constructor() ERC20("Histori", "HST") ERC20Permit("Histori") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY); // Mint initial supply to the contract deployer
    }
}
