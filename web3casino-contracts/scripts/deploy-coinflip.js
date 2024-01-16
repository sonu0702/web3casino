const hre = require("hardhat");

async function sleep(ms) {
    return new Promise((resolve) => {
        setTimeout(() => resolve(), ms);
    })
}
async function main() {
    // const [deployer] = await ethers.getSigners();
  
    // console.log("Deploying contracts with the account:", deployer.address);
  
    // const initialAmount = ethers.parseEther("0.001");
    // const subscription_id = '8091'
    // const CoinFlip = await ethers.getContractFactory("CoinFlip");
    // console.log("CoinFlip factory contract");
    // const contract = await CoinFlip.deploy(subscription_id,{value : initialAmount})
    // console.log("CoinFlip contract deploy");
    // console.log("Before Deploying contracts with the account:", contract.address , contract.target);

    // await contract.deployed()
    // const [deployer] = await ethers.getSigners();

    // console.log("Deploying contracts with the account:", contract.address);

    // const token = await ethers.deployContract("CoinFlip");

    // console.log("Token address:", await token.getAddress());

    // await sleep(45 * 1000);
    //0xD8A53B5198002a6D3316f95bDC48dD7f80ab38A9
    await hre.run("verify:verify", {
        address:'0xD8A53B5198002a6D3316f95bDC48dD7f80ab38A9',
        constructorArguments:['8091'],
    });
    console.log("done")
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


//track this - https://sepolia.etherscan.io/tx/0x3f83d5d877040dc8917ee796bd031e6614e555daaf888c0e4a55fcab740f1ffd
