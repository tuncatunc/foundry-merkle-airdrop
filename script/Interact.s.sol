// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script, stdJson} from "forge-std/Script.sol";

import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BeagleToken} from "../src/BeagleToken.sol";

contract ClaimAirdrop is Script {
    string private constant OUTPUT_PATH = "script/target/output.json";
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25e18;
    bytes32[] private s_proof;

    function claim() public {
        address merkleAirdropAddress = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        block.coinbase;
        MerkleAirdrop merkleAirdrop = MerkleAirdrop(merkleAirdropAddress);
        _readProofsFromFile();

        uint256 amount = 25e18;

        vm.startBroadcast();
        merkleAirdrop.claim(amount, s_proof);
        vm.stopBroadcast();
    }

    function _readProofsFromFile() internal {
        string memory json = vm.readFile(OUTPUT_PATH);
        bytes memory rawData = bytes(json);
        bytes memory rawProof;

        for (uint256 i = 0; i < rawData.length; i++) {
            string memory addressPath = string(abi.encodePacked("[", vm.toString(i), "].inputs[0]"));
            address inputAddress = stdJson.readAddress(json, addressPath);
            if (inputAddress == CLAIMING_ADDRESS) {
                string memory proofPath = string(abi.encodePacked("[", vm.toString(i), "].proof"));
                rawProof = stdJson.parseRaw(json, proofPath);
                break;
            }
        }

        s_proof = abi.decode(rawProof, (bytes32[]));
    }

    function run() public {
        claim();
    }
}
