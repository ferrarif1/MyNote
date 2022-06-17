// SPDX-License-Identifier: ISC
pragma solidity 0.8.4;

/// @notice This contract allows for senders to notarize documents. A hash of the document is computed and then stored
/// in the contract's state. Note that the content of the document is sent within the transaction to notarize it,
/// therefore it is public and it size will impact the cost of the transaction.
contract ProofOfExistence {

    /// @notice Error thrown if a sender tries to notarize an already notarized
    /// document.
    error DocumentAlreadyNotarized();

    /// @notice Event emitted when a document has been successfully notarized.
    event DocumentNotarized(bytes32 indexed proof);

    /// @notice Indicates if a proof has been stored in the contract's state.
    mapping(bytes32 => bool) private proofs;

    /// @notice Notarize the given document, i.e. compute the document's proof
    /// (Keccak-256 hash) and store the proof in the contract's state.
    function notarize(string calldata document) external {
        bytes32 proof = proofFor(document);
        if (proofs[proof]) {
            revert DocumentAlreadyNotarized();
        }

        proofs[proof] = true;
        emit DocumentNotarized(proof);
    }

    /// @notice Check if the given document has already been notarized, i.e. if
    /// its proof already exists in the contract's state.
    function wasNotarized(string calldata document)
        external
        view
        returns (bool)
    {
        return proofs[proofFor(document)];
    }

    /// @notice Helper function to compute proof of a given document.
    function proofFor(string calldata document) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(document));
    }
}
