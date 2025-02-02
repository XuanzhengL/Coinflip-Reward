// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// -------------------- OpenZeppelin Upgradeable Imports -------------------- //
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// --------------------------------------------------------------------------- //
error SeedTooShort();

/// @title Coinflip (UUPS Upgradeable) - V1
/// @notice Coinflip game from Part A, upgraded to use UUPS proxy model
contract Coinflip is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    
    /// @notice The seed string used for pseudo-random generation
    string public seed;

    /// @dev Instead of a constructor, we use initialize().
    ///      This is called once when the proxy is set up.
    function initialize() public initializer {
        __Ownable_init();        // Initialize OwnableUpgradeable
        __UUPSUpgradeable_init(); // Initialize UUPSUpgradeable

        // Set the initial seed (from Part A)
        seed = "It is a good practice to rotate seeds often in gambling";
    }

    /// @dev Required by UUPS model: Only owner can authorize an upgrade.
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    /// @notice Checks user input (10 guesses) against contract-generated flips
    /// @param Guesses is an array of 10 elements (1=heads, 0=tails)
    /// @return true if all guesses match the generated flips, otherwise false
    function userInput(uint8[10] calldata Guesses) external view returns(bool){
        // Get the contract generated flips
        uint8[10] memory generatedFlips = getFlips();

        // Compare each element; if any mismatch, return false immediately
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != generatedFlips[i]) {
                return false;
            }
        }
        return true;
    }

    /// @notice Allows the owner to change the seed to a new one, must be >=10 chars
    /// @param NewSeed The new seed string
    function seedRotation(string memory NewSeed) public onlyOwner {
        bytes memory b = bytes(NewSeed);
        uint seedlength = b.length;
        if (seedlength < 10) {
            revert SeedTooShort();
        }
        seed = NewSeed;
    }

    /// @notice Generates 10 random flips (0 or 1) by hashing characters of the seed
    /// @return a fixed 10-element array of type uint8 with only 1 or 0
    function getFlips() public view returns(uint8[10] memory){
        bytes memory stringInBytes = bytes(seed);
        uint seedlength = stringInBytes.length;
        uint8[10] memory results;
        uint interval = seedlength / 10;

        for (uint i = 0; i < 10; i++) {
            // Pseudo-random: hash a character & block.timestamp
            uint randomNum = uint(
                keccak256(
                    abi.encode(stringInBytes[i * interval], block.timestamp)
                )
            );

            // Even -> 1, Odd -> 0 (just for example)
            if (randomNum % 2 == 0) {
                results[i] = 1;
            } else {
                results[i] = 0;
            }
        }
        return results;
    }
}
