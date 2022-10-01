// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.4;

contract Timelock{
    
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);
    
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);
    
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);
    
    event NewAdmin(address indexed newAdmin);

    address public admin; 
    uint public constant GRACE_PERIOD = 7 days;
    uint public delay; 
    mapping (bytes32 => bool) public queuedTransactions; 
    
    // onlyOwner modifier
    modifier onlyOwner() {
        require(msg.sender == admin, "Timelock: Caller not admin");
        _;
    }

    // onlyTimelock modifier
    modifier onlyTimelock() {
        require(msg.sender == address(this), "Timelock: Caller not Timelock");
        _;
    }


    constructor(uint delay_) {
        delay = delay_;
        admin  msg.sender;
    }

    function changeAdmin(address newAdmin) public onlyTimelock {
        admin = newAdmin;

        emit NewAdmin(newAdmin);
    }

    /**
     * @dev 
     * @param target:
     * @param value:
     * @param signature: Function signaturE
     * @param data: call dat
     * @param executeTime: 
     *
     *
     */
    function queueTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner returns (bytes32) {
        
        require(executeTime >= getBlockTimestamp() + delay, "Timelock::queueTransaction: Estimated execution block must satisfy delay.");
        
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
    
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, executeTime);
        return txHash;
    }

    
    function cancelTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner{
        
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
    
        require(queuedTransactions[txHash], "Timelock::cancelTransaction: Transaction hasn't been queued.");
    
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, executeTime);
    }

   
    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public payable onlyOwner returns (bytes memory) {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");
        
        require(getBlockTimestamp() >= executeTime, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");
        
       require(getBlockTimestamp() <= executeTime + GRACE_PERIOD, "Timelock::executeTransaction: Transaction is stale.");
        
        queuedTransactions[txHash] = false;

        //call data
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }
        //call
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, executeTime);

        return returnData;
    }


    function getBlockTimestamp() public view returns (uint) {
        return block.timestamp;
    }

    
    function getTxHash(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint executeTime
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(target, value, signature, data, executeTime));
    }
}