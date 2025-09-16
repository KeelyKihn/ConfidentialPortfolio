const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting deployment of ConfidentialPortfolio contract...");
  
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("📝 Deploying contracts with account:", deployer.address);

  // Get account balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("💰 Account balance:", ethers.formatEther(balance), "ETH");

  // Get the contract factory
  const ConfidentialPortfolio = await ethers.getContractFactory("ConfidentialPortfolio");

  console.log("⏳ Deploying contract...");
  
  // Deploy the contract
  const confidentialPortfolio = await ConfidentialPortfolio.deploy();
  await confidentialPortfolio.waitForDeployment();

  const contractAddress = await confidentialPortfolio.getAddress();
  console.log("✅ ConfidentialPortfolio deployed to:", contractAddress);

  // Verify deployment
  console.log("🔍 Verifying deployment...");
  const code = await ethers.provider.getCode(contractAddress);
  console.log("📋 Contract code length:", code.length);

  // Test basic functionality
  console.log("🧪 Testing basic contract functionality...");
  try {
    // Test portfolioExists function
    const exists = await confidentialPortfolio.portfolioExists(deployer.address);
    console.log("📊 Portfolio exists for deployer:", exists);

    console.log("🎉 Contract deployment and verification completed!");
    
    // Output contract info for frontend
    console.log("\n📋 Contract Information:");
    console.log("Contract Address:", contractAddress);
    console.log("Network: Sepolia Testnet");
    console.log("Deployer:", deployer.address);
    
    // Generate ABI for frontend
    console.log("\n🔧 Contract ABI (for frontend integration):");
    const abi = ConfidentialPortfolio.interface.formatJson();
    console.log(abi);

  } catch (error) {
    console.error("❌ Error testing contract functionality:", error);
  }
}

main()
  .then(() => {
    console.log("\n✅ Deployment script completed successfully!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("\n💥 Deployment failed:", error);
    process.exit(1);
  });