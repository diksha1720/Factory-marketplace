require("@nomicfoundation/hardhat-toolbox");
// require("@nomiclabs/hardhat-waffle")
// require("@nomiclabs/hardhat-truffle5");
// require('hardhat-contract-sizer');
require("@nomiclabs/hardhat-etherscan");
require('solidity-coverage');
require('dotenv').config()
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.20",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                    outputSelection: {
                        "*": {
                            "*": [
                                "abi",
                                "evm.bytecode",
                                "evm.deployedBytecode",
                                "metadata", // <-- add this
                            ],
                        },
                    },
                },
            },
        ],
    },
    spdxLicenseIdentifier: {
        overwrite: true,
        runOnCompile: true,
    },
    defaultNetwork: "hardhat",
    mocha: {
        timeout: 10000000000000000000,
    },

    networks: {
        hardhat: {
            blockGasLimit: 10000000000000,
            allowUnlimitedContractSize: true,
            timeout: 10000000000000000000,
            accounts: {
                accountsBalance: "10000000000000000000000000",
                count: 20,
            },
        },
      
        polygonMumbai: {
            gasLimit: 205000,
            allowUnlimitedContractSize: true,
            url: process.env.POLYGON_MUMBAI_URL,
            accounts: [process.env.ACCOUNT_KEY],
          },
    },

    contractSizer: {
        alphaSort: false,
        runOnCompile: true,
        disambiguatePaths: false,
    },

    etherscan: {

        apiKey: `CRKECNKKCXAFW2X9Q2EMTUK8IWXZ3FYUBY`,
    },
};
