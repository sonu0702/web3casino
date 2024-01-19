const hre = require("hardhat");

async function sleep(ms) {
    return new Promise((resolve) => {
        setTimeout(() => resolve(), ms);
    })
}
async function main() {
    // const [deployer] = await ethers.getSigners();
  
    // console.log("Deploying contracts with the account:", deployer.address);

    // const ReferralTracker = await ethers.getContractFactory("ReferralTracker");
    // const contract = await ReferralTracker.deploy(deployer.address);
    // console.log("ReferralTracker contract deploy");
    // console.log("Before Deploying contracts with the account:", contract.address , contract.target);



    // await sleep(45 * 1000);
    await hre.run("verify:verify", {
        address:'0x3e8B8D46513365938BbEB5f8c97dF72Ac02CbCAE',
        constructorArguments:['0x0A6dc8B39461374b388634745593f1c70CCb57a2'],
    });
    console.log("done")
}
//0x3e8B8D46513365938BbEB5f8c97dF72Ac02CbCAE
//https://sepolia.etherscan.io/address/0x3e8B8D46513365938BbEB5f8c97dF72Ac02CbCAE#code


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

//npx hardhat run scripts/deploy.js --network <network-name>
//npx hardhat run scripts/deploy.js