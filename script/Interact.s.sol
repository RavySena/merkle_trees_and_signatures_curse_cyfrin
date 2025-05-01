// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";

import { Script, console } from "forge-std/Script.sol";


contract Interact is Script {
    MerkleAirdrop public merkleAirdrop;

    address public constant CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 public constant AMOUNT_TO_COLLECT = 25 ether;

    bytes constant SIGNATURE = hex"4f6df8983bfcb2bf429270bf3e56717601ea8a548721e638282e57421f978c016e56417323b881f1d2ef8c6f1ab7c304aa963b6fdf4eaf1543595ce9d1e792a51b"; 

    bytes32 public proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proofs = [proof1, proof2];


    function run() public {
        claimAirdrop();
    }


    function claimAirdrop() public {
        merkleAirdrop = MerkleAirdrop(getLastDeployedAddress());

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);

        vm.startBroadcast();
        merkleAirdrop.claim(CLAIMING_ADDRESS, AMOUNT_TO_COLLECT, proofs, v, r, s);
        vm.stopBroadcast();
    }


    function splitSignature(bytes memory signature) public returns (uint8 v, bytes32 r, bytes32 s) {
        if (signature.length == 65) {
            assembly ("memory-safe") {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        }
    }


    function getLastDeployedAddress() internal view returns (address) {
        string memory path = "broadcast/Deployer.s.sol/31337/run-latest.json";
        string memory json = vm.readFile(path);
        
        return vm.parseJsonAddress(json, ".transactions[1].contractAddress");
    }

}