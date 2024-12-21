// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BigganosToken} from "../src/BigganosToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    BigganosToken bigganosToken;
    MerkleAirdrop merkleAirdrop;
    bytes32 private constant ROOT = 0xd401bdf61394d1d8ffb6bae1ff3bafdf012cde348d23b8cd1aa31d5952bf4736;
    address user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 userPrivKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    Account invalidUser = makeAccount("invalidUser");
    uint256 private constant AMOUNT = 20000000000000000000000;
    bytes32 proof1 = 0x304d3be6f1a4ac2a93f1c9157a67a50831bf91bcf43c4bdd1656fb2ed4e16640;
    bytes32 proof2 = 0xc3dbce72883189407bd608d3dadf912f45389ab16e6a6de2e1f151f99161f3ce;
    bytes32 proof3 = 0xfbcd54c88c1f5ae43f859537f26b897578c1af9afb0e3a262d2ec0721e94bda9;
    bytes32[] PROOF = [proof1, proof2, proof3];

    function setUp() external {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (merkleAirdrop, bigganosToken) = deployer.deploy();
    }

    function testDeploy() public pure {
        assert(true);
    }

    function testUsersCanClaim() public {
        // Checks
        uint256 previousBalance = bigganosToken.balanceOf(user);

        // Effects

        vm.prank(user);
        merkleAirdrop.claim(AMOUNT, PROOF);

        uint256 newBalance = bigganosToken.balanceOf(user);
        assertEq(newBalance, previousBalance + AMOUNT);
    }

    function testUsersCannotClaimTwice() public {
        // Checks
        uint256 previousBalance = bigganosToken.balanceOf(user);

        // Effects
        vm.prank(user);
        merkleAirdrop.claim(AMOUNT, PROOF);

        // Interactions
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(MerkleAirdrop.MerkleAirdrop__TokensAlreadyClaimed.selector, user));
        merkleAirdrop.claim(AMOUNT, PROOF);

        uint256 newBalance = bigganosToken.balanceOf(user);
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
