const { ethers, network, run } = require("hardhat");
require("dotenv").config();
const {contractFactoryContractAddress, primaryMarketPlaceContractAddress , secondaryMarketPlaceContractAddress , createMerkleTree ,getMerkleProof } = require('../utils/commonUtils')

let contractFactory
let primaryMarketPlace
let secondaryMarketPlace
let admin, organizer , whitelistedUser1, whitelistedUser2 ,endUser
const eventId = 1 // fetch latest eventId from db and increment it to assign
const tokenId = 1
const nftContractAddress = "0x94a082820837ad8Cd0175cFb82BD3e1999c2E7A2"
const currencyContractAddress = "0xe034331eCd5b6d41BC2938e02320aD7113F3AE22" //fetch these values from DB


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