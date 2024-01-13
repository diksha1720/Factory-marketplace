const { ethers, network, run } = require("hardhat");
require("dotenv").config();
const {contractFactoryContractAddress, primaryMarketPlaceContractAddress , secondaryMarketPlaceContractAddress} = require('../utils/commonUtils')

const provider = new ethers.providers.JsonRpcProvider(process.env.POLYGON_MUMBAI_URL);
const signer = new ethers.Wallet(process.env.ACCOUNT_KEY);
const admin = signer.connect(provider);
  

async function main() {

    const contractFactory = await hre.ethers.getContractAt("ContractFactory", contractFactoryContractAddress);
    const primaryMarketPlace = await hre.ethers.getContractAt("PrimaryMarketPlace", primaryMarketPlaceContractAddress);
    const secondaryMarketPlace = await hre.ethers.getContractAt("SecondaryMarketPlace", secondaryMarketPlaceContractAddress);

    var txn1 = await contractFactory.setGlobalVar(primaryMarketPlaceContractAddress, secondaryMarketPlaceContractAddress)
    await txn1.wait()
    console.log("contract factory initialized")

    var txn2 = await primaryMarketPlace.addFactoryContract(contractFactoryContractAddress)
    await txn2.wait()
    console.log("primary marketplace initialised")

    var txn3 = await secondaryMarketPlace.addFactoryContract(contractFactoryContractAddress)
    await txn3.wait()

    var txn4 = await secondaryMarketPlace.setOrganizerFeePercent(20)
    await txn4.wait()
    console.log("secondary marketplace initialised")

}

main()
