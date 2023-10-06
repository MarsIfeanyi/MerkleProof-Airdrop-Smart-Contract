// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleProofAirdrop is ERC20 {
    bytes32 merkleRoot;

    constructor(bytes32 _merkleRoot) ERC20("BridgeWaters", "BWS") {
        merkleRoot = _merkleRoot;
    }

    mapping(address => bool) hasClaimed;

    event AirdropClaimed(address account, uint256 amount);

    error MerkleProofAirdrop_AlreadyClaimed(string message);
    error MerkleProofAirdrop_InvalidProof(string);

    function claimAirdrop(
        bytes32[] calldata _merkleProof,
        address claimer,
        uint256 _amount
    ) external returns (bool success) {
        if (hasClaimed[claimer])
            revert MerkleProofAirdrop_AlreadyClaimed({
                message: "You have already claimed!"
            });

        bytes32 node = keccak256(abi.encodePacked(claimer, _amount));

        success = MerkleProof.verify(_merkleProof, merkleRoot, node);

        if (!success)
            revert MerkleProofAirdrop_InvalidProof(
                "MerkleDistributor: Invalid proof."
            );

        _mint(claimer, _amount * 10 ** 18);
        hasClaimed[claimer] = true;

        emit AirdropClaimed(claimer, _amount);
    }
}
