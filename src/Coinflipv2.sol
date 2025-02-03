// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./DauphineToken.sol"; //Import the DauphineToken contract 


error SeedTooShort();


contract CoinflipV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    string public seed;
    DauphineToken public dauphineToken;//Define the DauphineToken contract

    function initialize(address newOwner) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(newOwner);

        seed = "It is a good practice to rotate seeds often in gambling";
        dauphineToken = DauphineToken(tokenAddress);//Initialize the DauphineToken contract
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function UserInput(uint8[10] calldata Guesses) external view returns(bool){
        uint8[10] memory generatedFlips = getFlips();
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != generatedFlips[i]) {
                return false;
            }
        }
        RewardUser(msg.sender); //Reward the user with Dauphine tokens
        return true;
    }


    function seedRotation(string memory NewSeed, uint rotations) public onlyOwner {
        bytes memory b = bytes(NewSeed);
        uint seedlength = b.length;
        if (seedlength < 10) {
            revert SeedTooShort();
        }

        rotations = rotations % seedlength;
        bytes memory rotated = new bytes(seedlength);
        for (uint i = 0; i < seedlength; i++) {
            rotated[i] = b[(i + rotations) % seedlength];
        }
        seed = string(rotated);
    }

    function getFlips() public view returns(uint8[10] memory){
        bytes memory stringInBytes = bytes(seed);
        uint seedlength = stringInBytes.length;
        uint8[10] memory results;
        uint interval = seedlength / 10;

        for (uint i = 0; i < 10; i++) {
            uint randomNum = uint(
                keccak256(
                    abi.encode(stringInBytes[i * interval], block.timestamp)
                )
            );
            if (randomNum % 2 == 0) {
                results[i] = 1;
            } else {
                results[i] = 0;
            }
        }
        return results;
    }
    function RewardUser(address winner) internal {
        dauphineToken.mint(winner, 5 * 1e18); //Mint 5 Dauphine tokens to the winner
    }
}
