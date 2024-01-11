// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const ContractFactory = await hre.ethers.getContractFactory("ContractFactory");
  const contractFactory = await ContractFactory.deploy("0xda28919a4F12eD1963f4f5fEAd8D49FbDE0125Db","100000000000", 1000000000);

  await contractFactory.deployed();

  console.log(
    `contractFactory deployed to ${contractFactory.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
