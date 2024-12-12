// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BeagleToken} from "../src/BeagleToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "@foundry-devops/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    BeagleToken beagleToken;
    MerkleAirdrop merkleAirdrop;
    bytes32 private constant ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address user;
    uint256 userPrivKey;
    Account invalidUser = makeAccount("invalidUser");
    uint256 private constant AMOUNT = 25e18;
    bytes32 proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [proof1, proof2];

    function setUp() external {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (merkleAirdrop, beagleToken) = deployer.deploy();
        } else {
            beagleToken = new BeagleToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, address(beagleToken));
            beagleToken.mint(beagleToken.owner(), AMOUNT);
            beagleToken.transfer(address(merkleAirdrop), AMOUNT); // transfer the tokens to the airdrop contract
        }
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function testUsersCanClaim() public {
        // Checks
        uint256 previousBalance = beagleToken.balanceOf(user);

        // Effects

        vm.prank(user);
        merkleAirdrop.claim(AMOUNT, PROOF);

        uint256 newBalance = beagleToken.balanceOf(user);
        assertEq(newBalance, previousBalance + AMOUNT);
    }

    function testUsersCannotClaimTwice() public {
        // Checks
        uint256 previousBalance = beagleToken.balanceOf(user);

        // Effects
        vm.prank(user);
        merkleAirdrop.claim(AMOUNT, PROOF);

        // Interactions
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(MerkleAirdrop.MerkleAirdrop__TokensAlreadyClaimed.selector, user));
        merkleAirdrop.claim(AMOUNT, PROOF);

        uint256 newBalance = beagleToken.balanceOf(user);
        assertEq(newBalance, previousBalance + AMOUNT);
    }

    function testUnauthorizedUsersCannotClaim() public {
        // Checks
        // Effects
        // Interactions
        vm.prank(invalidUser.addr);
        vm.expectRevert(abi.encodeWithSelector(MerkleAirdrop.MerkleAirdrop__InvalidProof.selector));
        merkleAirdrop.claim(AMOUNT, PROOF);
    }
}
