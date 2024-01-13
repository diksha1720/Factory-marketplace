
const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
var Web3 = require('web3');  
const nftAbi = require('../artifacts/contracts/NFTContract.sol/NFTContract.json');
const currencyabi = require('../artifacts/contracts/CurrencyContract.sol/CurrencyContract.json');

const {createMerkleTree ,getMerkleProof} = require('../utils/commonUtils')


const ContractFactory = hre.artifacts.readArtifact("ContractFactory");
let owner ,account1, account2, account3, account4, account5 , account6
let contractFactory
let primaryMarketPlace
let secondaryMarketPlace
let eventId
let nftContract 
let NFTContract
let currencyContract
let CurrencyContract
let tokenId
let merkleTreeMain

describe("Game Contract Test Cases", () => {
    before(async () => {
        [owner, organizer , account2, account3 ,account4, account5 , account6] = await ethers.getSigners();
        let ContractFactory = await ethers.getContractFactory("ContractFactory")
        contractFactory = await ContractFactory.deploy()

        let PrimaryMarketPlace = await ethers.getContractFactory("PrimaryMarketPlace")
        primaryMarketPlace = await PrimaryMarketPlace.deploy()

        let SecondaryMarketPlace = await ethers.getContractFactory("SecondaryMarketPlace")
        secondaryMarketPlace = await SecondaryMarketPlace.deploy()
    })

    it("print contract address", async () => {
        console.log("contractFactory address",contractFactory.address)
        console.log("primaryMarketPlace address",primaryMarketPlace.address)
        console.log("secondaryMarketPlace address",secondaryMarketPlace.address)
    })

    it("should create an event", async() =>{

        let whiteListedAddress = [account2.address, account3.address, account4.address,account5.address]
        let [rootHash , merkleTree] =   createMerkleTree(whiteListedAddress)
        merkleTreeMain = merkleTree
        eventId = 1

        await expect(contractFactory.connect(organizer).createEvent(eventId , "event1", "evt1", "event happening in blr" , "1000000", 100, "10000000", '0x'+ rootHash)).to.be.revertedWith("Global var not updated")

        await expect(contractFactory.connect(account2).setGlobalVar( primaryMarketPlace.address , secondaryMarketPlace.address )).to.be.reverted
        await contractFactory.setGlobalVar( primaryMarketPlace.address , secondaryMarketPlace.address )
   
        var txn = await contractFactory.connect(organizer).createEvent(eventId , "event1", "evt1", "event happening in blr" , "1000000", 100, "10000000", '0x'+ rootHash)
        var res = await txn.wait()
        nftContract = res.events.slice(-1)[0].args.nftContract
        currencyContract = res.events.slice(-1)[0].args.currencyContract
        const provider = ethers.getDefaultProvider()
        NFTContract = new 
        ethers.Contract(
            nftContract,
            nftAbi.abi,
            provider
        );
        CurrencyContract = new 
        ethers.Contract(
            currencyContract,
            currencyabi.abi,
            provider
        );
    })

    it("should initialize primary merketPlace contract", async() =>{
        await expect(primaryMarketPlace.connect(account2).addFactoryContract(contractFactory.address)).to.be.reverted
        await primaryMarketPlace.addFactoryContract(contractFactory.address)
    })

    it("should mint tokens from primary market place", async()=>{
        var proof = getMerkleProof(merkleTreeMain , account6.address)
        await expect(primaryMarketPlace.connect(account6).mintTokens(eventId,"1000000",proof )).to.be.revertedWith("Not whitelisted")

        var proof = getMerkleProof(merkleTreeMain , account2.address)
   
        await expect(primaryMarketPlace.connect(account2).mintTokens(eventId,"10000000000000",proof )).to.be.revertedWith("mint amount exceeds allowance")

        await primaryMarketPlace.connect(account2).mintTokens(eventId,"1000000",proof )

    })

    // return 

    it("should mint nft from the secondary marketplace", async()=>{

        var txn =await CurrencyContract.connect(account2).approve(primaryMarketPlace.address , "10000000")
        var proof = getMerkleProof(merkleTreeMain , account2.address)
       
        await  expect(primaryMarketPlace.connect(account6).mintNFT(eventId, 1 , proof)).to.be.revertedWith("Not whitelisted")

        await  expect(primaryMarketPlace.connect(account2).mintNFT(eventId, 1000 , proof)).to.be.revertedWith("mint amount exceeds allowance")

        await  expect(primaryMarketPlace.connect(account2).mintNFT(eventId, 100 , proof)).to.be.revertedWith("insufficient funds")

        var txn1 = await primaryMarketPlace.connect(account2).mintNFT(eventId, 1 , proof)
        var res = await txn1.wait()
        tokenId = res.events.slice(-1)[0].args.fromTokenId;
    })

    it("should initialize secondary merketPlace contract", async() =>{
        await expect(secondaryMarketPlace.connect(account2).addFactoryContract(contractFactory.address)).to.be.reverted

        await secondaryMarketPlace.addFactoryContract(contractFactory.address)
    })

    it("should resell the minted NFT on secondary marketplace", async() => {
        var tx = await NFTContract.connect(account2).setApprovalForAll(secondaryMarketPlace.address, true)
        
        await expect(secondaryMarketPlace.connect(account3).listNFT(eventId, tokenId , "10000")).to.be.revertedWith("Not the owner")

        await secondaryMarketPlace.connect(account2).listNFT(eventId, tokenId , "10000")
    })

    it("another user should be able to buy the listed NFTs ", async() =>{
        await expect(secondaryMarketPlace.connect(account6).buyNFT(nftContract , tokenId + 1 , {value :"10000" })).to.be.revertedWith("NFT not listed")
        
        await secondaryMarketPlace.connect(account6).buyNFT(nftContract , tokenId , {value :"10000" })
    })

    it("end user can list the bought NFT to the secondary marketplace again", async function(){
        var tx = await NFTContract.connect(account6).setApprovalForAll(secondaryMarketPlace.address, true)
        
        await expect(secondaryMarketPlace.connect(account3).listNFT(eventId, tokenId , "10000")).to.be.revertedWith("Not the owner")

        await expect(secondaryMarketPlace.connect(account6).listNFT(eventId, tokenId , "1000000")).to.be.revertedWith("listing price can't exceed mint price")

        await secondaryMarketPlace.connect(account6).listNFT(eventId, tokenId , "10000")
   
    })

})




