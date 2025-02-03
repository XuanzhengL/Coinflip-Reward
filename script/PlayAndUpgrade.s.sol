// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/Coinflip.sol";
import "../src/DauphineToken.sol";
import "../src/UUPSProxy.sol";

contract PlayAndUpgrade is Script {
    function run() external {
        vm.startBroadcast(); 

     
        address proxyAddress = 0xYourProxyAddressHere;        
        address tokenAddress = 0xYourDauphineTokenAddress;    
        address newImplementationV2 = 0xYourCoinflipV2Address; 

       
        Coinflip coinflip = Coinflip(proxyAddress);         
        DauphineToken dauphineToken = DauphineToken(tokenAddress);

      
        address user = msg.sender;
        address friend = address(0xBEEF);                   

        
        uint8[10] memory winningGuesses = [1,1,1,1,1,1,1,1,1,1];  
        bool resultV1 = coinflip.UserInput(winningGuesses);
        console.log("V1 Game Result:", resultV1);
        console.log("User DAU Balance after V1 win:", dauphineToken.balanceOf(user) / 1e18);

      
        coinflip.upgradeTo(newImplementationV2); 
        console.log("Upgraded to V2 successfully");

        
        bool resultV2 = coinflip.UserInput(winningGuesses);
        console.log("V2 Game Result:", resultV2);
        console.log("User DAU Balance after V2 win:", dauphineToken.balanceOf(user) / 1e18);

       
        dauphineToken.transfer(friend, 2 * 1e18);  
        console.log("User DAU Balance after transfer:", dauphineToken.balanceOf(user) / 1e18);
        console.log("Friend DAU Balance:", dauphineToken.balanceOf(friend) / 1e18);

        vm.stopBroadcast(); 
    }
}
