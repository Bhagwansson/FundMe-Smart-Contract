// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DepolyFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public view{
        assertEq(fundMe.MINIMUM_USD(), 3e18);
    }

    function testOwnerIsMsgSender() public view {
        // assertEq(fundMe.i_contractOwner(), msg.sender);//this wont work because msg.sender is not deploying this contract but this test is creating an instance of this contract of the FundMe contract
        assertEq(fundMe.i_contractOwner(), msg.sender);
    }
}
