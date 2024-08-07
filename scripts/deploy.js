const hre = require("hardhat");

async function main() {
  // Get the Points smart contract
  const GameToken = await hre.ethers.getContractFactory("GameToken");

  // Deploy it
  const gameToken = await GameToken.deploy();
  await gameToken.deployed();

  // Display the contract address
  console.log(`Degen token deployed to ${gameToken.address}`);
}

// Hardhat recommends this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
