const ForgottenAdventurers = artifacts.require("ForgottenAdventurers");

contract("ForgottenAdventurers", async accounts => {
  // Make sure that the initial counter for NFT's minted is set to 0
  it("Should return 0 NFT's minted after contract deployment", async () => {
    const instance = await ForgottenAdventurers.deployed();
    const startingNumMinted = await instance.getTotalNFTsMintedSoFar()
    assert.equal(startingNumMinted, 0, "Incorrect non-zero value for tokenCounter");
  });
  
  // Make sure only 2007 in total are available to mint
  it("Should have a total of 2007 NFT's available to mint", async () => {
    const instance = await ForgottenAdventurers.deployed();
    const startingNumMinted = await instance.getMaxAvailable()
    assert.equal(startingNumMinted, 2007, "Incorrect value for maxAvailable");
  });

  /// Make sure the right mint price has been set
  it("Should have a mint price of 0.03 ETH", async () => {
    const instance = await ForgottenAdventurers.deployed();
    const mintPrice = await instance.getMintPrice()
    assert.equal(mintPrice, 30000000000000000, "Incorrect mint price");
  });

  // Make sure the mint function can't be called until the contract has some LINK
  it("Should fail since no LINK has been manually sent for the Chainlink VRF call", async () => {
    const instance = await ForgottenAdventurers.deployed();
    try {
      await instance.create({value: 30000000000000000});
    } catch(e) {
      assert.exists(e, "Send LINK manually via a faucet");
    }
  });

  // Make sure the second part of our two-part creation process can't be called before the first is complete
  it("Shouldn't allow finishMint on a tokenId before the Chainlink VRF responds", async () => {
    const instance = await ForgottenAdventurers.deployed();
    try {
      await instance.finishMint(0);
    } catch(e) {
      assert.exists(e, "finishMint should only be called after a requestId is received");
    }
  });

});