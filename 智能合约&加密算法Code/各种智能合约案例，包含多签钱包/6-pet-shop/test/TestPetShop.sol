// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/PetShop.sol";

contract TestPetShop {
    /// @dev The address of the adoption contract to be tested.
    PetShop private petShop = PetShop(DeployedAddresses.PetShop());

    /// @dev The id of the pet that will be used for testing
    uint256 private expectedPetId = 8;

    /// @dev The expected owner of the adopted pet is this contract
    address private expectedAdopter = address(this);

    function testUserCanAdoptPet() public {
        petShop.adopt(expectedPetId);
        address adopter = petShop.adopters(expectedPetId);

        Assert.equal(
            adopter,
            expectedAdopter,
            "Owner of the expected pet should be this contract"
        );
    }

    function testGetAdopterAddressByPetIdInArray() public {
        address[16] memory adopters = petShop.getAdopters();

        for (uint256 index = 0; index < adopters.length; index++) {
            if (index == expectedPetId) {
                Assert.equal(
                    adopters[expectedPetId],
                    expectedAdopter,
                    "Owner of the expected pet should be this contract"
                );
            } else {
                Assert.equal(
                    adopters[index],
                    address(0),
                    "This pet should not have been adopted"
                );
            }
        }
    }
}
