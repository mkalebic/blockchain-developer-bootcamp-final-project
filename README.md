# Forgotten Adventurers
This project was built out of nostalgia for the early years of World of Warcraft. Seeing how empty Azeroth is these days, I'm reminded of all the adventurers that logged off for the last time years ago. The randomly generated descriptions in this contract evoke a sense of reflection on the lore behind each Forgotten Adventurer.

The contract has been deployed on Rinkeby at `0x8292DD58cE1A9d43730a76989b53474319f92a72` and a front-end is hosted on [Replit](https://forgotten-adventurers.mattkalebic.repl.co/). 

# Requirements 
Since we're using [Chainlink VRF](https://docs.chain.link/docs/chainlink-vrf/) as a a provably-fair and verifiable source of randomness, deploying on a local blockchain (i.e. Ganache) is unfortunately not an option. Instead, we'll deploy directly to Rinkeby and run our tests from there. 

For development, I used:
- `Truffle v5.4.28 (core: 5.4.28)`
- `Solidity - 0.8.11 (solc-js)`
- `Node v14.18.2`
- `Web3.js v1.5.3`

To deploy your own version on Rinkeby:
- Clone this repository
- Create a `.env` file within the main directory and add the following:
    - `MNEMONIC` = "THE MNEMONIC PHRASE OF YOUR DEVELOPMENT WALLET"
    - `INFURA_KEY` = "YOUR PROJECT KEY FROM INFURA"
    - `ETHERSCAN_KEY` "API KEY FROM YOUR ETHERSCAN ACCOUNT"
- `npm install`
- If making any changes, `truffle compile`
- `truffle migrate --network rinkeby` to deploy on the network
- `truffle test --network rinkeby` to run tests from `TestForgottenAdventurers.js` on the deployed contract
* Most importantly, fund it with some LINK! You can use the [Rinkeby faucet](https://faucets.chain.link/rinkeby) to manually send 10 LINK and 0.1 ETH to your contract address. Each call to the VRF costs 1 LINK on Rinkeby. 

Note, the below values have to be configured correctly for VRF requests to work. This has already been defined for Rinkeby in `2_deploy_contracts.js`, but you you can find the respective values for other networks in the [VRF Contracts](https://docs.chain.link/docs/vrf-contracts/) page.
- `LINK Token` - LINK token address on the corresponding network (Ethereum, Polygon, BSC, etc)
- `VRF Coordinator` - address of the Chainlink VRF Coordinator
- `Key Hash` - public key against which randomness is generated
- `Fee` - fee required to fulfill a VRF request

# Directory Structure
- Contracts are in `/contracts`
- Migration files are in `/migrations`
- Tests are in `/test`

# Ethereum Address for Bootcamp NFT
0x314B619c12B975bD8587317242C33FF08F943f31

# Screencast
https://www.youtube.com/watch?v=xTw1NoBWTOk 