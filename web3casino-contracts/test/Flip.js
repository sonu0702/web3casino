const {
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("Flip contract", function () {
    async function deployFlipFixture() {
        const [owner, addr1, addr2] = await ethers.getSigners();

        // const hardhatToken = await ethers.deployContract("Flip");
        const CoinFlip = await ethers.getContractFactory("Flip");
        console.log("CoinFlip factory contract");
        const contract = await CoinFlip.deploy(owner)
        console.log("Flip contract deploy");
        console.log("Before Deploying contracts with the account:", contract.address, contract.target);

        // Fixtures can return anything you consider useful for your tests
        return { contract, owner, addr1, addr2 };
    }
    async function deployTreasuryFixture() {
        const [owner] = await ethers.getSigners();
        const Treasury = await ethers.getContractFactory("Treasury");
        const initialValue = ethers.parseEther("20");
        console.log("treasury factory contract");
        const treasury = await Treasury.deploy({ value: initialValue })
        console.log("treasury contract deploy");
        console.log("Before Deploying contracts with the account:", treasury.address, treasury.target);

        // Fixtures can return anything you consider useful for your tests
        return { treasury, owner };
    }
    async function deployRakeDistributionFixture() {
        const [owner] = await ethers.getSigners();
        const RakeDistributor = await ethers.getContractFactory("RakeDistributor");
        const rakeDistributor = await RakeDistributor.deploy(owner)
        console.log("Before Deploying rakeDistributor with the account:", rakeDistributor.address, rakeDistributor.target);
        // Fixtures can return anything you consider useful for your tests
        return { rakeDistributor, owner };
    }
    async function deployReferralTrackerFixture() {
        const [owner] = await ethers.getSigners();
        const ReferralTracker = await ethers.getContractFactory("ReferralTracker");
        const referralTracker = await ReferralTracker.deploy(owner)
        console.log("Before Deploying referralTracker with the account:", referralTracker.address, referralTracker.target);
        // Fixtures can return anything you consider useful for your tests
        return { referralTracker, owner };
    }
    it("Play game", async function () {
        const betAndRakeAmount = ethers.parseEther("0.105");
        const { contract, owner, addr1 } = await loadFixture(deployFlipFixture);

        //deploy treasury
        const { treasury } = await loadFixture(deployTreasuryFixture)
        console.log("treasury:address", treasury.address, "target", treasury.target);
        const TreasuryBalance = await ethers.provider.getBalance(treasury.target)
        console.log("TreasuryBalance", TreasuryBalance);
        //deploy rake distributor
        const { rakeDistributor } = await loadFixture(deployRakeDistributionFixture);
        console.log("RakeDistributor:address", rakeDistributor.address, "RakeDistributor", rakeDistributor.target);
        //deploy referral tracker
        const { referralTracker } = await loadFixture(deployReferralTrackerFixture);
        console.log("referralTracker:address", referralTracker.address, "referralTracker", referralTracker.target);
        //set treasury
        //setTreasuryAddress
        const setTreasuryValue = await contract.setTreasuryAddress(treasury.target);
        console.log("setTreasury value", setTreasuryValue);
        //set rakeDistributor
        const setRakeDistributorValue = await contract.setReckDistributor(rakeDistributor.target);
        console.log("setRakeDistributo value", setRakeDistributorValue);
        //set referral tracker
        const setReferralTrackerAddressValue = await rakeDistributor.setReferralTrackerAddress(referralTracker.target);
        console.log("setReferralTrackerAddressValue value", setReferralTrackerAddressValue);
        //set operator
        console.log("going to set operator", contract.target);
        const setOperatorValue = await rakeDistributor.setOperator(contract.target,true);
        console.log("setOperatorValue value", setOperatorValue);
        const setOperatorValueReff = await referralTracker.setOperator(rakeDistributor.target,true);
        console.log("setOperatorValueReff value", setOperatorValueReff);
        const value = await contract.playGame([1], '0x0000000000000000000000000000000000000000', 1,
            { value: betAndRakeAmount });
        // const ownerBalance = await hardhatToken.balanceOf(owner.address);
        const TreasuryBalanceAfter = await ethers.provider.getBalance(treasury.target)
        console.log("TreasuryBalanceAfter", TreasuryBalanceAfter);
        expect(value).to.equal(0.1);
    });
});