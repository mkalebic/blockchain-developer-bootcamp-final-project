# Design Pattern Decisions

## Oracles
I used Chainlink VRF to ensure that adventurer descriptions are provably-fair and verifiably-random. To do this, I inherited from `VRFConsumerBase` and defined two required functions:
- `requestRandomness`, which makes the initial request for randomness.
- `fulfillRandomness`, which is the function that receives and does something with verified randomness.

## Access Control Design Patterns
`Ownable` allowed me to implement ownership in my contract. This allows for a `withdraw` function to collect profits from minting, where only the owner of the contract can call the function. 