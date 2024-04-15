// get funds from users
// withdraw funds
//set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <=0.9.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol"; //here PriceConverter is a library
import {console} from "forge-std/console.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256; //"using PriceConverter for uint256" allows the uint256 data type to access additional conversion functionality provided by the PriceConverter library.

    address public immutable i_contractOwner; // immutable variables are named with "i_" in the beginning to denote that they  are immutable

    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) { //the input parameter 'priceFeed' is the address of AggregatorV3Interface that comes from the DeployFundMe contract.
        i_contractOwner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed); // the input parameter(address of AggregatorV3Interface) is assigned to s_priceFeed
    }

    uint256 public constant MINIMUM_USD = 3e18; //constant variables have a different naming convention typically you'll want to do them all caps

    mapping(address => uint256) private s_addressToAmountFunded;

    address[] private s_funders;

    function fund() public payable {
            console.log("Converted price of amount funded",msg.value.getConversionRate(s_priceFeed));
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Not enough fund"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    

    function withdraw() public onlyOwner {
        //onlyOwner modifier first checks if the msg.sender is the owner or not
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++ //loop through all the funders in funders[] array
        ) {
            address funder = s_funders[funderIndex]; // gets the address of the current funder
            s_addressToAmountFunded[funder] = 0; // resets the  funded by the current funder to zero
        }
        s_funders = new address[](0); // resets the funders array to an empty array starting from zeroth index

        // Call a function on the sender's address and send the entire balance of this contract as Ether.
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); // Store the success status of the call operation.
        require(callSuccess, "Call Failed"); // Check if the call operation was successful, and revert the transaction if it failed.
    }

    modifier onlyOwner() {
        // require(msg.sender == i_contractOwner, "You must be the owner to withdraw"); //this consumes alot of gas
        if (msg.sender != i_contractOwner) {
            revert FundMe__NotOwner();
        } // this is slightly more gas efficient than 'require'

        _; /*_; takes the code execution where the modifier is called. if in this modifier _; was called before require()
          then the code in withdraw() would have executed first. */
    }

    receive() external payable {
        // This receive function is automatically triggered when the contract receives Ether along with a transaction that doesn't specify a function to call.
        // It serves as a fallback to handle incoming Ether payments sent directly to the contract's address.
        // The function is marked as external to allow external accounts to send Ether to the contract.
        // The payable modifier indicates that the function can receive Ether.
        fund(); // Call the fund() function to process the incoming Ether payment.
    }

    fallback() external payable {
        // This fallback function is automatically triggered when the contract receives a message or transaction with data that doesn't match any function signature.
        // It serves as a catch-all function to handle unexpected calls or messages to the contract.
        // The function is marked as external to allow external accounts to send Ether along with data to the contract.
        // The payable modifier indicates that the function can receive Ether.
        fund(); // Call the fund() function to process the incoming Ether payment.
    }


    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }


    // (Getters)
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
         

    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

}

/*
         The method below 'transfer' and 'send' can be used to send eth to another account but 'call' is used.
         To know why see the difference between 'transfer', 'send' and 'call'

        // // Transfer the entire balance of this contract to the sender's address.
        // payable(msg.sender).transfer(address(this).balance);

        // // Send the entire balance of this contract to the sender's address, and store the success status.
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");// Check if the send operation was successful, and revert the transaction if it failed.
         */

/*

The converter code below is moved to library PriceConverter.sol

// function getPrice() public view returns(uint256) {
//    //Address : 0x694AA1769357215DE4FAC081bf1f309aDC325306
//    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
//    (,int256 answer,,,) =  priceFeed.latestRoundData();
//    return uint256(answer * 1e10);

// }

// function getConversionRate(uint256 ethAmount) public view returns(uint256){
//    uint256 ethPrice = getPrice();
//    uint256 ethAmountInUsd = (ethPrice* ethAmount) / 1e18;
//    return ethAmountInUsd;
// }
// VlDKQXcZ.9aVvkWAHUxCMfdFBbCOrH9WoAIVyhonP
*/
