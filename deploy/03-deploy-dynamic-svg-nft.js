const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config");
const { network } = require("hardhat");
require("dotenv");
const { verify } = require("../utils/verify");
const fs = require("fs");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  let ethUsdPriceFeedAddress;
  if (developmentChains.includes(network.name)) {
    // deployments.get is function used to retrieve information about a deployed contract.
    // returns the object containing information about the specified deployed contract
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    // if it's not default address
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }

  log("---------------");
  const lowSVG = fs.readFileSync("./images/dynamicNft/frown.svg", {
    encoding: "utf-8",
  });
  const highSVG = fs.readFileSync("./images/dynamicNft/happy.svg", {
    encoding: "utf-8",
  });

  args = [ethUsdPriceFeedAddress, lowSVG, highSVG];
  const dynamicSvgNft = await deploy("DynamicSvgNft", {
    // who is deploying this
    from: deployer,
    args: args, // its args for the construct
    log: true, // set log to be true, to give the log information in the terminal when we execute yarn hardhat node
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  // Verify the deployment
  if (
    !developmentChains.includes(network.name) &&
    process.env.EtherScan_API_KEY
  ) {
    log("Verifying...");
    await verify(dynamicSvgNft.address, args);
  }
};

module.exports.tags = ["all", "dynamicsvg", "main"];
