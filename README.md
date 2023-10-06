# MerkleProof Airdrop Distributor

This is Smart contract that distributes ERC20 tokens to addresses using merkle root proof.

The following specification/features were implemented.

- There is an ERC20 token
- There is a script that interact generates the merkle root proof and their interacts with the smart contract for airdrop distribution.
- There is a CSV of whitelisted addresses to claim and the amount each user has to claim.
- The markle hash is stored in the contract and verified each time a user clicks on the claimAirdrop() method.
