// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Forwarder} from "../src/Forwarder.sol";
import {RelayerHub} from "../src/RelayerHub.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        console.log("Deploying BaseRelayer contracts...");

        // Deploy Forwarder
        Forwarder forwarder = new Forwarder();
        console.log("Forwarder deployed at:", address(forwarder));

        // Deploy RelayerHub
        RelayerHub hub = new RelayerHub();
        console.log("RelayerHub deployed at:", address(hub));

        vm.stopBroadcast();
    }
}

