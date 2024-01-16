async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    const token = await ethers.deployContract("Token");
  
    console.log("Token address:", await token.getAddress());
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });

//npx hardhat run scripts/deploy.js --network <network-name>
//npx hardhat run scripts/deploy.js
//0x60B56f42860Dbe4e61A2E443F6f2F9De7fC40bAe