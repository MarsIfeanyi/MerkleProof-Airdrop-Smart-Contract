import { ethers } from "hardhat";
async function main() {
  const merkleProofAirdropContract = await ethers.deployContract(
    "MerkleProofAirdrop"
  );

  await merkleProofAirdropContract.waitForDeployment();

  console.log(`MerkleProofAirdrop Contract deployed at ${merkleProofAirdropContract.target}
`);

  const txReceipt = await merkleProofAirdropContract.claimAirdrop(
    [],
    "0xC76F962e24F4345301296Bf111529047ec3cA96E",
    0,
    "1000000000000000000000"
  );

  console.log(txReceipt);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
