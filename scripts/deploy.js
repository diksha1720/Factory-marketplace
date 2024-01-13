// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const ContractFactory = await hre.ethers.getContractFactory("ContractFactory");
  const contractFactory = await ContractFactory.deploy();

  await contractFactory.deployed();

  console.log(
    `contractFactory deployed to ${contractFactory.address}`
  );


  const PrimaryMarketPlace = await hre.ethers.getContractFactory("PrimaryMarketPlace");
  const primaryMarketPlace = await PrimaryMarketPlace.deploy();

  await primaryMarketPlace.deployed();

  console.log(
    `primaryMarketPlace deployed to ${primaryMarketPlace.address}`
  );


  const SecondaryMarketPlace = await hre.ethers.getContractFactory("SecondaryMarketPlace");
  const secondaryMarketPlace = await SecondaryMarketPlace.deploy();

  await secondaryMarketPlace.deployed();

  console.log(
    `secondaryMarketPlace deployed to ${secondaryMarketPlace.address}`
  );

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
