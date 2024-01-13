const { ethers, network, run } = require("hardhat");
require("dotenv").config();
const {contractFactoryContractAddress, primaryMarketPlaceContractAddress , secondaryMarketPlaceContractAddress , createMerkleTree ,getMerkleProof } = require('../utils/commonUtils')

let contractFactory
let primaryMarketPlace
let secondaryMarketPlace
let admin, organizer , whitelistedUser1, whitelistedUser2 ,endUser
const eventId = 1 // fetch latest eventId from db and increment it to assign
const tokenId = 1
const nftContractAddress = "0x5f9a0c9Fa6D10B562ECc39b2923e1A6BffaD76b5"
const currencyContractAddress = "0x98A86af3CBFc8c66f076776350dff6bfAAc0cE38" //fetch these values from DB


async function putNftForSale(){

    var tx = await nftContract.connect(whitelistedUser1).approve(secondaryMarketPlace.address, tokenId)
    await tx.wait()

    var salePrice = "10" //MATIC
    var txn = await secondaryMarketPlace.connect(whitelistedUser1).listNFT(eventId, tokenId , salePrice)
    var res = await txn.wait()
    console.log("NFT Listed!!")
}

async function buyNFT(){

    await secondaryMarketPlace.connect(endUser).buyNFT(nftContractAddress , tokenId , {value :"10" })
    console.log("NFT bought!!")
}

async function main(){
    [admin, organizer , whitelistedUser1, whitelistedUser2 ,endUser] = await ethers.getSigners();

    contractFactory = await hre.ethers.getContractAt("ContractFactory", contractFactoryContractAddress);
    primaryMarketPlace = await hre.ethers.getContractAt("PrimaryMarketPlace", primaryMarketPlaceContractAddress);
    secondaryMarketPlace = await hre.ethers.getContractAt("SecondaryMarketPlace", secondaryMarketPlaceContractAddress);
    nftContract = await hre.ethers.getContractAt("NFTContract" , nftContractAddress)
    currencyContract = await hre.ethers.getContractAt("CurrencyContract" , currencyContractAddress)

    // putNftForSale()
    buyNFT()
}

main()