// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleProofAirdrop is ERC20 {
    bytes32 merkleRoot;

    constructor() ERC20("BridgeWaters", "BWS") {}

    mapping(address => bool) hasClaimed;
    event AirdropClaimed(address account, uint256 itemId, uint256 amount);

    function claimAirdrop(
        bytes32[] calldata _merkleProof,
        address claimer,
        uint256 _itemId,
        uint256 _amount
    ) external {
        require(!hasClaimed[claimer], "You have already claimed!");
        bytes32 node = keccak256(abi.encodePacked(claimer, _itemId, _amount));
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, node),
            "MerkleDistributor: Invalid proof."
        );
        _mint(claimer, _amount * 10 ** 18);
        hasClaimed[claimer] = true;
        emit AirdropClaimed(claimer, _itemId, _amount);
    }
}
