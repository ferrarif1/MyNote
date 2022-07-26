// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

/// @notice This contract allows anyone to adopt a pet. A pet can only be adopted once and there are only 16 different
/// pets. The purpose of this simple contract is to provide a simple dapp exemple for which a web interface can be
/// written.
contract PetShop {
    /*
     * State variables
     */

    /// @notice Contract owner. Has the ability to reset the state of the contract.
    address private owner;

    /// @notice Array of adopters. The index corresponds to the pet id.
    address[16] public adopters;

    /*
     * Events
     */

    /// @notice A pet with the specified id has been adopted by its new owner.
    event PetAdopted(uint256 petId, address owner);

    /// @notice The shop was reset, all adopters have been erased.
    event PetShopReset();

    /*
     * Function modifiers
     */

    /// @notice To adopt a pet, its id must be valid. There are only 16 pets to be adopted.
    error PetDoesNotExist();
    modifier petExists(uint256 petId) {
        if (petId >= 16) {
            revert PetDoesNotExist();
        }
        _;
    }

    /// @notice An already adopted pet cannot be readopted.
    error PetAlreadyAdopted();
    modifier petNotAdopted(uint256 petId) {
        if (adopters[petId] != address(0)) {
            revert PetAlreadyAdopted();
        }
        _;
    }

    /*
     * Functions
     */

    /// @notice Sets the sender as the contract owner.
    constructor() {
        owner = msg.sender;
    }

    /// @notice Allows the sender to adopt a pet.
    function adopt(uint256 petId)
        external
        petExists(petId)
        petNotAdopted(petId)
    {
        adopters[petId] = msg.sender;
        emit PetAdopted(petId, msg.sender);
    }

    /// @notice Returns the whole list of adopters.
    function getAdopters() external view returns (address[16] memory) {
        return adopters;
    }

    /// @dev Clears the adopters array. Avoids the need to deploy a new contract instance.
    function reset() external {
        if (msg.sender == owner) {
            delete adopters;
            emit PetShopReset();
        }
    }
}
