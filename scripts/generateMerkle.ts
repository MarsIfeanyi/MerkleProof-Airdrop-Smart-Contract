import { MerkleTree } from "merkletreejs";
import { keccak256 } from "ethers/lib/utils";
import csv from "csv-parser";
import fs from "fs";
import { utils } from "ethers";
import path from "path";

function main() {
  // create web3 instance (no provider needed)

  let root: string | undefined;

  // Files for each airdrop
  // Import distribution from this file
  const filename: string = path.join(__dirname, "userData/data.csv");

  // What file should we write the merkle proofs to?
  const output_file: string = path.join(__dirname, "genFiles/claimer.json");

  // File that has the user claim list
  const userclaimFile: string = path.join(__dirname, "genFiles/userClaim.json");

  // Contract of items being sent out
  const airdropContract: string = "0xCAFd0a3053f00C17bF6014Ab610811E459BDC5Ec";
  // Used to store one leaf for each line in the distribution file
  const token_dist: string[] = [];

  // Used for tracking user_id of each leaf so we can write to proofs file accordingly
  const user_dist_list: [string, string][] = [];

  // Open distribution csv
  fs.createReadStream(filename)
    .pipe(csv())
    .on("data", (row) => {
      const user_dist: [string, string] = [row["address"], row["amount"]]; // create a record to track user_id of leaves
      const leaf_hash = utils.solidityKeccak256(
        ["address", "uint256"],
        [row["address"], row["amount"]]
      ); // encode base data like solidity abi.encode
      user_dist_list.push(user_dist); // add record to the index tracker
      token_dist.push(leaf_hash); // add leaf hash to distribution
    })
    .on("end", () => {
      // Create merkle tree from token distribution
      const merkle_tree = new MerkleTree(token_dist, keccak256, {
        sortPairs: true,
      });
      // Get root of our tree
      root = merkle_tree.getHexRoot();
      // Create proof file
      write_leaves(merkle_tree, user_dist_list, token_dist, root);
    });

  // Write leaves & proofs to a JSON file
  function write_leaves(
    merkle_tree: MerkleTree,
    user_dist_list: [string, string][],
    token_dist: string[],
    root: string | undefined
  ) {
    console.log("Begin writing leaves to file...");
    const full_dist: Record<
      string,
      { leaf: string; proof: string[] } // Change the type of proof to string[]
    > = {};
    const full_user_claim: Record<string, { address: string; amount: string }> =
      {};

    for (let line = 0; line < user_dist_list.length; line++) {
      // Generate leaf hash from raw data
      const leaf = token_dist[line];

      // Create dist object
      const user_dist = {
        leaf: leaf,
        proof: merkle_tree.getHexProof(leaf),
      };
      // Add record to our distribution
      full_dist[user_dist_list[line][0]] = user_dist;
    }

    fs.writeFile(output_file, JSON.stringify(full_dist, null, 4), (err) => {
      if (err) {
        console.error(err);
        return;
      }

      const dropObjs = {
        dropDetails: {
          contractAddress: airdropContract,
          merkleroot: root,
        },
      };

      for (let line = 0; line < user_dist_list.length; line++) {
        const other = user_dist_list[line];
        const user_claim = {
          address: other[0],
          amount: other[1],
        };
        full_user_claim[user_dist_list[line][0]] = user_claim;
      }
      const newObj = Object.assign(full_user_claim, dropObjs);
      // Append to airdrop list to have a comprehensive overview
      fs.writeFile(userclaimFile, JSON.stringify(newObj, null, 4), (err) => {
        if (err) {
          console.error(err);
          return;
        }
      });
      console.log(output_file, "has been written with a root hash of:\n", root);
    });
  }
}

main();
