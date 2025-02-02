// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// -------------------- OpenZeppelin Upgradeable Imports -------------------- //
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// --------------------------------------------------------------------------- //
error SeedTooShort();

/// @title Coinflip (UUPS Upgradeable) - V2
/// @notice Upgraded version of Coinflip where seedRotation() now rotates the string
contract CoinflipV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {

    string public seed;

    /// @dev For demonstration, we keep the same initialize() as V1.
    ///      In production, you'd typically use reinitializer(2).
    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();

        // Same default seed as V1, but it won't actually re-run if already initialized
        seed = "It is a good practice to rotate seeds often in gambling";
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    /// @notice Checks user input against contract generated flips
    function userInput(uint8[10] calldata Guesses) external view returns(bool){
        uint8[10] memory generatedFlips = getFlips();
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != generatedFlips[i]) {
                return false;
            }
        }
        return true;
    }

    /// @notice This upgraded version takes in an extra `rotations` parameter
    ///         and performs a circular rotation of the new seed string.
    /// @param NewSeed The new seed to set
    /// @param rotations Number of times to rotate the string (circular)
    function seedRotation(string memory NewSeed, uint rotations) public onlyOwner {
        bytes memory b = bytes(NewSeed);
        uint seedlength = b.length;

        if (seedlength < 10) {
            revert SeedTooShort();
        }

        // Now apply 'rotations' to the seed in a circular manner
        rotations = rotations % seedlength;
        bytes memory rotated = new bytes(seedlength);

        // Example: "abcde" rotate once -> "bcdea"
        for (uint i = 0; i < seedlength; i++) {
            rotated[i] = b[(i + rotations) % seedlength];
        }

        seed = string(rotated);
    }

    /// @notice The same getFlips logic from V1
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
