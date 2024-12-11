// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MerkleAirdrop is Ownable {
    using SafeERC20 for IERC20;

    modifier notClaimed(address account) {
        if (s_claimed[account]) {
            revert MerkleAirdrop__TokensAlreadyClaimed(account);
        }

        _;
    }

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__TokensAlreadyClaimed(address account);
    // some list of addresses
    // allow someone in the list to claim ERC-20 tokens

    event MerkleAirdrop__Claim(address account, uint256 amount);

    bytes32 private immutable i_merkleRoot;
    address private immutable i_token;
    mapping(address claimer => bool claimed) private s_claimed;

    constructor(bytes32 merkleRoot, address token) Ownable(msg.sender) {
        i_merkleRoot = merkleRoot;
        i_token = token;
    }

    function claim(address account, uint256 amount, bytes32[] memory proof) external notClaimed(account) {
        // Checks
        bytes32 node = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(proof, i_merkleRoot, node)) {
            revert MerkleAirdrop__InvalidProof();
        }

        // Effects
        s_claimed[account] = true;
        emit MerkleAirdrop__Claim(account, amount);

        // Interactions
        IERC20(i_token).safeTransfer(account, amount);
        //s_claimed[account] = true; // this is against Check Effects Interactions pattern and it can lead to reentrancy
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (address) {
        return i_token;
    }
}
