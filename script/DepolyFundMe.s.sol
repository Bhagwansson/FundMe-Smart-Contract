// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import{Script} from "forge-std/Script.sol";
import{FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
contract DeployFundMe is Script{
    function run() external returns(FundMe){

        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);// this line takes the address of AggregatorV3Interface and passes it to constructor of the main contract FundMe.
        vm.stopBroadcast();
        return fundMe;
    }
}