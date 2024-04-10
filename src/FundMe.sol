// get funds from users
// withdraw funds
//set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <=0.9.0;

// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol"; //here PriceConverter is a library

error NotOwner();

contract FundMe {
    using PriceConverter for uint256; //"using PriceConverter for uint256" allows the uint256 data type to access additional conversion functionality provided by the PriceConverter library.

    address public immutable i_contractOwner; // immutable variables are named with "i_" in the beginning to denote that they  are immutable

    constructor() {
        i_contractOwner = msg.sender;
    }

    uint256 public constant MINIMUM_USD = 3e18; //constant variables have a different naming convention typically you'll want to do them all caps

    mapping(address => uint256) public addressToAmountFunded;

    address[] public funders;

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Not enough fund"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] =
            addressToAmountFunded[msg.sender] +
            msg.value.getConversionRate();
    }

    function withdraw() public onlyOwner {
        //onlyOwner modifier first checks if the msg.sender is the owner or not
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++ //loop through all the funders in funders[] array
        ) {
            address funder = funders[funderIndex]; // gets the address of the current funder
            addressToAmountFunded[funder] = 0; // resets the  funded by the current funder to zero
        }
        funders = new address[](0); // resets the funders array to an empty array starting from zeroth index

        // Call a function on the sender's address and send the entire balance of this contract as Ether.
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); // Store the success status of the call operation.
        require(callSuccess, "Call Failed"); // Check if the call operation was successful, and revert the transaction if it failed.
    }

    modifier onlyOwner() {
        // require(msg.sender == i_contractOwner, "You must be the owner to withdraw"); //this consumes alot of gas
        if (msg.sender != i_contractOwner) {
            revert NotOwner();
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
