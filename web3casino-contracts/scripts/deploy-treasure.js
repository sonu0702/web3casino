const hre = require("hardhat");

async function sleep(ms) {
    return new Promise((resolve) => {
        setTimeout(() => resolve(), ms);
    })
}
async function main() {
    // const [deployer] = await ethers.getSigners();
  
    // console.log("Deploying contracts with the account:", deployer.address);

    // const Treasurer = await ethers.getContractFactory("Treasury");
    // const initialValue = ethers.parseEther("0.5");
    // const contract = await Treasurer.deploy({ value: initialValue })
    // console.log("Treasury contract deploy");
    // console.log("Before Deploying contracts with the account:", contract.address , contract.target);



    // await sleep(45 * 1000);
    await hre.run("verify:verify", {
        address:'0x39De86E115122FD2f5D7162148621B9FbB03512a',
        constructorArguments:[],
    });
    // console.log("done")
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
