const { expect } = require("chai");


  describe("Token contract", function () {
    let gameContract;
    
    let owner;
    let addr1;
    let addr2;
   
    beforeEach (async function(){
      [owner, addr1, addr2] = await ethers.getSigners();
      const gameContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
      gameContract = await gameContractFactory.deploy(                     
      ["Leo", "Aang", "Pikachu"],       
      ["https://ipfs.pixura.io/ipfs/QmXHsqT5QiB74irRG6yHmfgBRnuD911MikhX23CcnDdfJz/thecollectorandtheartist.png", 
      "https://i.imgur.com/xVu4vFL.png", 
      "https://i.imgur.com/u7T87A6.png"],
      [100, 200, 300],                    
     [100, 50, 25]                       
     );
      await gameContract.deployed();
    });
 
    it("construction of nft contract is correct", async function () {
      
      expect(await gameContract.length()).to.equal(3);
      var hp = await gameContract.gethp(0);
      expect(hp).to.equal(0);
      expect(1).to.equal(0);


      expect(await gameContract.balanceOf(owner.address)).to.equal(0);
      await gameContract.mintCharacterNFT(0);
      expect(await gameContract.balanceOf(owner.address)).to.equal(1);

      });


    it("swapping game token is correct", async function () {
      await gameContract.transfer(addr1.address, 50);
      const addr1Balance = await gameContract.tokenbalance(addr1.address);
      expect(addr1Balance).to.equal(50);
      await gameContract.connect(addr1).transfer(addr2.address, 50);
      const addr2Balance = await gameContract.tokenbalance(addr2.address);
      expect(addr2Balance).to.equal(50);
    });

    it("Should fail if sender doesnt have enough tokens", async function () {
      const initialOwnerBalance = await gameContract.balanceOf(owner.address);
      await expect(
        gameContract.connect(addr1).transfer(owner.address, 1)
      ).to.be.revertedWith("Not enough tokens");
      expect(await gameContract.balanceOf(owner.address)).to.equal(
        initialOwnerBalance
      );
    });
     
  });


