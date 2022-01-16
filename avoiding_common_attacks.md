# Avoiding Common Attacks

## Using Specific Compiler Pragma (SWC-103)
The Forgotten Adventurers smart contract (`ForgottenAdventurers.sol`) will compile with Solidity version `0.8.0` up to, but not including, `0.9.0`

## Proper Use of Require, Assert and Revert (SWC-128)
The contract uses `require` to ensure that no more than the maximum amount of NFT's are minted, the appropriate amount of Ether is sent during minting, and that the part one of the two-part minting process is completed before the second part begins. 

## Weak Sources of Randomness from Chain Attributes (SWC-120)
Using Chainlink VRF as a source of randomness for adventurer trait generation, we can avoid any potential manipulation by bad actors. 