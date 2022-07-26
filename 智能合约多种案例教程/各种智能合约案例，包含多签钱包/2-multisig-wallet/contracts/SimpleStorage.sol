// SPDX-License-Identifier: ISC
pragma solidity 0.8.4;

/// @notice This contract is only here to test the functionalities developped in MultiSignatureWallet.
contract SimpleStorage {

    /// @notice Simple storage variable to hold some data.
    uint256 public data;

    /// @notice Caller of the set function.
    address public caller;

    /// @notice A deposit of Ether has been made to the contract.
    event Deposit(address indexed sender, uint256 value);

    /// @notice Allow the contract to receive Ether if calldata is empty.
    receive() external payable {
        emitEventIfFundsReceived();
    }

    /// @notice Same as receive() but called if calldata is invalid.
    fallback() external payable {
        emitEventIfFundsReceived();
    }

    /// @notice Set data storage variable to new value and caller to
    /// msg.sender. The function is payable in case it needs to receive Ether.
    function set(uint256 _data) external payable {
        caller = msg.sender;
        data = _data;
        emitEventIfFundsReceived();
    }

    /// @notice Emit an event if funds were received.
    function emitEventIfFundsReceived() private {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }
}
