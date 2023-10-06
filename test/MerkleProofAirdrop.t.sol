// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";
import {MerkleProofAirdrop} from "../src/MerkleProofAirdrop.sol";

contract MerkleProofAirdropTest is Test {
    MerkleProofAirdrop public merkleProofAirdrop;

    using stdJson for string;

    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    bytes32 root =
        0x96b85c6f94988c8f96d7945455908ebeb1f5ff439b8d8474c226b4ad05ce0744;

    address user1 = 0x001Daa61Eaa241A8D89607194FC3b1184dcB9B4C;
    uint user1Amt = 45000000000000;

    address user2 = 0x005FbBABD1e619324011d3312CF6166921A294aF;
    uint user2Amt = 47000000000000;

    Result public result;

    function setUp() public {
        merkleProofAirdrop = new MerkleProofAirdrop(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");
        string memory json = vm.readFile(path);

        bytes memory res = json.parseRaw(
            string.concat(".", vm.toString(user2))
        );

        result = abi.decode(res, (Result));
    }

    function _claim() internal returns (bool success) {
        success = merkleProofAirdrop.claimAirdrop(
            result.proof,
            user2,
            user2Amt
        );
    }

    function testUserCantClaimTwice() public {
        _claim();

        vm.expectRevert(
            abi.encodeWithSelector(
                MerkleProofAirdrop.AlreadyClaimed.selector,
                "You have already claimed!"
            )
        );
        _claim();
    }

    function testClaim() public {
        bool success = _claim();
        assertEq(merkleProofAirdrop.balanceOf(user2), user2Amt);
        assertTrue(success);
    }

    function testInvalidProofForUser() public {
        bytes32[] memory proof_;
        vm.expectRevert(
            abi.encodeWithSelector(
                MerkleProofAirdrop.InvalidProofForUser.selector,
                "MerkleDistributor: Invalid proof"
            )
        );

        merkleProofAirdrop.claimAirdrop(proof_, user2, user2Amt);
    }
}
