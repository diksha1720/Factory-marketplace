const { ethers, network, run } = require("hardhat");
require("dotenv").config();
const {contractFactoryContractAddress, primaryMarketPlaceContractAddress , secondaryMarketPlaceContractAddress , createMerkleTree ,getMerkleProof } = require('../utils/commonUtils')

let contractFactory
let primaryMarketPlace
let secondaryMarketPlace
let admin, organizer , whitelistedUser1, whitelistedUser2 ,endUser
const eventId = 3 // fetch latest eventId from db and increment it to assign

async function createNewEvent(){
    const eventName = "eventONE"
    const tokenSymbol = "$ONE"
    const maxMints = 10
    const maxAllowance = 1000
    const nftPrice = 100
    const whiteListedAddress = [whitelistedUser1.address, whitelistedUser2.address]
    const [rootHash , merkleTree] =   createMerkleTree(whiteListedAddress) //store merkle tree in the DB for each event

    var txn = await contractFactory.connect(organizer).createEvent(eventId , eventName , tokenSymbol  , nftPrice , maxMints , maxAllowance , '0x' +rootHash ,  {gasLimit : 10000000})

    var rec = await txn.wait()

    var nftContract = rec.events.slice(-2)[0].args.nftContract //store nftContract address in the DB 
    var currencyContract = rec.events.slice(-2)[0].args.currencyContract // store currencycontract in the DB

    console.log("event added")
    console.log("nftContract" , nftContract)
    console.log("currencyContract" , currencyContract)

}

async function updateExistingEvent(){
    const maxMints = 20
    const maxAllowance = 2000
    const nftPrice = 200
    const whiteListedAddress = [whitelistedUser1.address, whitelistedUser2.address]
    const [rootHash , merkleTree] =   createMerkleTree(whiteListedAddress) //store merkle tree in the DB for each event

    var txn = await contractFactory.connect(organizer).updateEvent(eventId , nftPrice , maxMints , maxAllowance , '0x' + rootHash)
    await txn.wait()

    console.log("event updated")
}

async function main(){
    [admin, organizer , whitelistedUser1, whitelistedUser2 ,endUser] = await ethers.getSigners();

    contractFactory = await hre.ethers.getContractAt("ContractFactory", contractFactoryContractAddress);
    primaryMarketPlace = await hre.ethers.getContractAt("PrimaryMarketPlace", primaryMarketPlaceContractAddress);
    secondaryMarketPlace = await hre.ethers.getContractAt("SecondaryMarketPlace", secondaryMarketPlaceContractAddress);

    createNewEvent()
    // updateExistingEvent()

}

main()
