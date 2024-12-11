// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BeagleToken} from "../src/BeagleToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private constant AMOUNT_TO_AIRDROP = 25 * 1e18;
    uint256 private constant AMOUNT_TO_TRANSFER = 4 * AMOUNT_TO_AIRDROP;

    function deploy() public returns (MerkleAirdrop, BeagleToken) {
        vm.startBroadcast();
        // deploy BeagleToken contract
        BeagleToken beagleToken = new BeagleToken();
        // deploy MerkleAirdrop contract
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(s_merkleRoot, address(beagleToken));
        // mint tokens to the airdrop contract
        beagleToken.mint(address(beagleToken.owner()), AMOUNT_TO_TRANSFER);
        beagleToken.transfer(address(merkleAirdrop), AMOUNT_TO_TRANSFER);
        vm.stopBroadcast();
        return (merkleAirdrop, beagleToken);
    }

    function run() public returns (MerkleAirdrop, BeagleToken) {
        // deploy MerkleAirdrop contract
        return deploy();
    }
}
