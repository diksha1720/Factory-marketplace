const {MerkleTree} = require("merkletreejs");
const keccak256 = require("keccak256");
 
 const contractFactoryContractAddress = "0xDdcB5c666A6Ce2A7DCCa25A359dc86148ED8E40b";
 const primaryMarketPlaceContractAddress = "0x4bA6f74aCa6a7068590D7a62C968bA13352249ff";
 const secondaryMarketPlaceContractAddress = "0x9AAB94e400c26bc1A6Fab1ef04Fd17668399A25c";


 function createMerkleTree(whiteListedAddresses){
    let whitelist = whiteListedAddresses;
    let leaves = whitelist.map(addr => keccak256(addr));
    let merkleTree = new MerkleTree(leaves, keccak256, {sortPairs: true});
    let rootHash =merkleTree.getRoot().toString('hex');
    return [rootHash , merkleTree]
}

function getMerkleProof(merkleTree, address){
    const proof =  merkleTree.getHexProof(keccak256(address));
    // console.log(proof)
    return proof
}

 module.exports =  {contractFactoryContractAddress,primaryMarketPlaceContractAddress, secondaryMarketPlaceContractAddress , createMerkleTree ,getMerkleProof }