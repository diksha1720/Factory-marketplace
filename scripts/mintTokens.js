const { ethers, network, run } = require("hardhat");
require("dotenv").config();
const {contractFactoryContractAddress, primaryMarketPlaceContractAddress , secondaryMarketPlaceContractAddress , createMerkleTree ,getMerkleProof } = require('../utils/commonUtils')

const eventId = 1 
const nftContractAddress = "0x94a082820837ad8Cd0175cFb82BD3e1999c2E7A2"
const currencyContractAddress = "0xe034331eCd5b6d41BC2938e02320aD7113F3AE22" //fetch these values from DB

let contractFactory
let primaryMarketPlace
let secondaryMarketPlace , nftContract , currencyContract
let admin, organizer , whitelistedUser1, whitelistedUser2 ,endUser
let merkleProof

async function mintTokens(){
    var amount = 500
    var txn = await primaryMarketPlace.connect(whitelistedUser1).mintTokens(eventId,amount,merkleProof )
    await txn.wait()
    console.log("tokens minted!!")
}

async function mintNFT(){

    var txn =await currencyContract.connect(whitelistedUser1).approve(primaryMarketPlace.address , "10000000")
    await txn.wait()

    var amount = 1
    var txn = await primaryMarketPlace.connect(whitelistedUser1).mintNFT(eventId,amount,merkleProof )
    var rec = await txn.wait()
    console.log("from tokenId", rec.events.slice(-2)[0].args.fromTokenId)
    console.log("to tokenId", rec.events.slice(-2)[0].args.toTokenId) //store the minted token Ids in the DB
}

async function main(){
    [admin, organizer , whitelistedUser1, whitelistedUser2 ,endUser] = await ethers.getSigners();

    contractFactory = await hre.ethers.getContractAt("ContractFactory", contractFactoryContractAddress);
    primaryMarketPlace = await hre.ethers.getContractAt("PrimaryMarketPlace", primaryMarketPlaceContractAddress);
    secondaryMarketPlace = await hre.ethers.getContractAt("SecondaryMarketPlace", secondaryMarketPlaceContractAddress);
    nftContract = await hre.ethers.getContractAt("NFTContract" , nftContractAddress)
    currencyContract = await hre.ethers.getContractAt("CurrencyContract" , currencyContractAddress)

    var whiteListedAddress = [whitelistedUser1.address, whitelistedUser2.address]
    var [rootHash , merkleTree] =   createMerkleTree(whiteListedAddress) //fetch the  merkle tree from the DB for each event
    merkleProof = getMerkleProof(merkleTree , whitelistedUser1.address)

    // mintTokens()
    mintNFT()
}

main()