// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title MerkleProof For Airdrop Distribution
 * @author Marcellus Ifeanyi
 * @notice Uses MerkleProof to verify and disributes ERC20 token airdrop to only verified users.
 */
contract MerkleProofAirdrop is ERC20 {
    bytes32 merkleRoot;

    constructor(bytes32 _merkleRoot) ERC20("BridgeWaters", "BWS") {
        merkleRoot = _merkleRoot;
    }

    mapping(address => bool) hasClaimed;

    event AirdropClaimed(address account, uint256 amount);

    error AlreadyClaimed(string message);
    error InvalidProofForUser(string);

    function claimAirdrop(
        bytes32[] calldata _merkleProof,
        address claimer,
        uint256 _amount
    ) external returns (bool success) {
        if (hasClaimed[claimer])
            revert AlreadyClaimed({message: "You have already claimed!"});

        bytes32 node = keccak256(abi.encodePacked(claimer, _amount));

        success = MerkleProof.verify(_merkleProof, merkleRoot, node);

        if (!success)
            revert InvalidProofForUser("MerkleDistributor: Invalid proof");

        _mint(claimer, _amount);
        hasClaimed[claimer] = true;

        emit AirdropClaimed(claimer, _amount);
    }
}
