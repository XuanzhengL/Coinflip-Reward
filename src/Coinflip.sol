// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

error SeedTooShort();

contract Coinflip is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    string public seed;

    function initialize(address newOwner) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(newOwner);

        seed = "It is a good practice to rotate seeds often in gambling";
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
        return true;
    }

    function seedRotation(string memory NewSeed) public onlyOwner {
        bytes memory b = bytes(NewSeed);
        uint seedlength = b.length;
        if (seedlength < 10) {
            revert SeedTooShort();
        }
        seed = NewSeed;
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
}
