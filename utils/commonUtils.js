const {MerkleTree} = require("merkletreejs");
const keccak256 = require("keccak256");
 
const contractFactoryContractAddress = "0x5d1Cd793104cbE7Fdf83A34c6d29697eA637981B";
const primaryMarketPlaceContractAddress = "0xe987799C1E7a8c1cA7E639C1205Ce9C74fe48F51";
const secondaryMarketPlaceContractAddress = "0x1675E2435EF67A10752E9A928D03eB5f0bDc046B";


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