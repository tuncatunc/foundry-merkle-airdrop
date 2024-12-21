// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BigganosToken} from "../src/BigganosToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot;

    uint256 private BIG_CONTRACTORS_WALLET_PRIVATE_KEY = vm.envUint("BIG_CONTRACTORS_WALLET_PRIVATE_KEY");
    address private BIG_CONTRACTORS_WALLET_ADDRESS = vm.envAddress("BIG_CONTRACTORS_WALLET_ADDRESS");
    address private BIG_CODESTUDIO_WALLET_ADDRESS = vm.envAddress("BIG_CODESTUDIO_WALLET_ADDRESS");
    address private BIG_PUBLIC_WALLET_ADDRESS = vm.envAddress("BIG_PUBLIC_WALLET_ADDRESS");
    address private BIG_PARKSTONE_WALLET_ADDRESS = vm.envAddress("BIG_PARKSTONE_WALLET_ADDRESS");
    address private BIG_WALLET_ADDRESS = vm.envAddress("BIG_WALLET_ADDRESS");

    function deploy() public returns (MerkleAirdrop, BigganosToken) {
        console.log("Deploying MerkleAirdrop and BigganosToken contracts");
        _loadMerkleRootFromOutputJson();
        vm.startBroadcast();
        // deploy BeagleToken contract
        BigganosToken bigganosToken = new BigganosToken(
            BIG_CONTRACTORS_WALLET_ADDRESS,
            BIG_CODESTUDIO_WALLET_ADDRESS,
            BIG_PUBLIC_WALLET_ADDRESS,
            BIG_PARKSTONE_WALLET_ADDRESS,
            BIG_WALLET_ADDRESS
        );
        // deploy MerkleAirdrop contract
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(s_merkleRoot);
        vm.stopBroadcast();

        vm.startBroadcast(BIG_CONTRACTORS_WALLET_PRIVATE_KEY);
        bigganosToken.transfer(address(merkleAirdrop), bigganosToken.CONTRACTORS_ALLOCATION());
        vm.stopBroadcast();

        vm.startBroadcast();
        merkleAirdrop.setAirdropToken(address(bigganosToken));
        vm.stopBroadcast();
        return (merkleAirdrop, bigganosToken);
    }

    function run() public returns (MerkleAirdrop, BigganosToken) {
        return deploy();
    }

    function _loadMerkleRootFromOutputJson() private {
        string memory json = vm.readFile("./script/target/output.json");
        bytes32 root = bytes32(vm.parseJson(json, "[0].root"));
        console.log("Merkle root:");
        console.logBytes32(root);
        s_merkleRoot = root;
    }
}
