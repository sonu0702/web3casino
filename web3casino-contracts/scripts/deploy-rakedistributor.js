const hre = require("hardhat");

async function sleep(ms) {
    return new Promise((resolve) => {
        setTimeout(() => resolve(), ms);
    })
}
async function main() {
    // const [deployer] = await ethers.getSigners();
  
    // console.log("Deploying contracts with the account:", deployer.address);

    // const RakeDistributor = await ethers.getContractFactory("RakeDistributor");
    // const contract = await RakeDistributor.deploy(deployer.address);
    // console.log("RakeDistributor contract deploy");
    // console.log("Before Deploying contracts with the account:", contract.address , contract.target);



    await sleep(45 * 1000);
    await hre.run("verify:verify", {
        address:'0xF663fb7b3e7B8fd36A04683D19D851C52273D9A8',
        constructorArguments:['0x0A6dc8B39461374b388634745593f1c70CCb57a2'],
    });
    // console.log("done")
}
//0xF663fb7b3e7B8fd36A04683D19D851C52273D9A8
//https://sepolia.etherscan.io/address/0xF663fb7b3e7B8fd36A04683D19D851C52273D9A8#code


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

//npx hardhat run scripts/deploy.js --network <network-name>
//npx hardhat run scripts/deploy.js