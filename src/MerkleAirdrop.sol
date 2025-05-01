// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import { Script, console } from "forge-std/Script.sol";


contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;


    /*------------------------------------------ TYPE DECLARATIONS -------------------------------------------*/
    struct AirdropStructureSignature{
        address userSig;
        uint256 amountSig;
    }

    mapping(address user => bool claimed) private alreadyClaimed;


    /*----------------------------------------------- CONSTANTS ----------------------------------------------*/
    IERC20 private immutable i_bagelToken;

    bytes32 private immutable i_rootProof;


    /*------------------------------------------------ EVENTS ------------------------------------------------*/
    event Claim(address indexed account, uint256 indexed amount);


    /*------------------------------------------------ ERRORS ------------------------------------------------*/
    error MerkleAirdrop__userHasAlreadyClaimed(address user);
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__InvalidSignature();


    constructor(address _bagelToken, bytes32 _rootProof) EIP712("Airdrop", "1") {
        i_bagelToken = IERC20(_bagelToken);
        i_rootProof = _rootProof;
    }


    /*------------------------------------------         -----------------------------------------------------*/
    /*------------------------------------------ FUNCTIONS PUBLICS -------------------------------------------*/
    /*----------------------------------------------------         -------------------------------------------*/
    function getMessage(address user, uint256 amount) public returns (bytes32 messageHash) {
        messageHash = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("AirdropStructureSignature(address userSig,uint256 amountSig)"),
            user,
            amount
        )));
    }


    /*------------------------------------------         -----------------------------------------------------*/
    /*------------------------------------------ FUNCTIONS EXTERNAL ------------------------------------------*/
    /*----------------------------------------------------          ------------------------------------------*/
    function claim(address user, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external {
        if (alreadyClaimed[user]) {
            revert MerkleAirdrop__userHasAlreadyClaimed(user);
        }


        bytes32 messageHash = getMessage(user, amount);
        if (_verifySignature(messageHash, v, r, s) != user) {
            revert MerkleAirdrop__InvalidSignature();
        }


        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(user, amount))));
        if (!MerkleProof.verify(merkleProof, i_rootProof, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        alreadyClaimed[user] = true;

        i_bagelToken.safeTransfer(user, amount);
        emit Claim(user, amount);
    }


    /*-----------------------------------               ------------------------------------------------------*/
    /*----------------------------------- FUNCTIONS INTERNAL AND PRIVATES ------------------------------------*/
    /*---------------------------------------------------                 ------------------------------------*/
    function _verifySignature(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (address signer) {
        (signer,,) = ECDSA.tryRecover(hash, v, r, s);
    }

}









