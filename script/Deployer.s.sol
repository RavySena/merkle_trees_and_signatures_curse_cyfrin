// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";
import { BagelToken } from "../src/BagelToken.sol";

import { Script } from "forge-std/Script.sol";


contract Deployer is Script {
    bytes32 constant MERKLE_ROOT = 0xc566334c73cacafab433fd59b4398a6a9a80bd51b236cdbb9b814744a8d6d42a; 
    uint256 constant BALANCE_INITIAL = 100 ether;


    function run() public returns (BagelToken bagelToken, MerkleAirdrop merkleAirdrop) {
        vm.startBroadcast();

        bagelToken = new BagelToken();
        merkleAirdrop = new MerkleAirdrop(address(bagelToken), MERKLE_ROOT);

        bagelToken.mint(address(merkleAirdrop), BALANCE_INITIAL);

        vm.stopBroadcast();
    }
}