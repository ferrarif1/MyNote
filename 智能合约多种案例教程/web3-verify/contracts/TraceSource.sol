// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract TraceSource {
    // 合约管理员
    address private admin;
    mapping(bytes32 => string) private map;
    mapping(bytes32 => bool) private mapInserted;

    mapping(address => bool) private whiteMap;

    uint256 private nonce = 0;
    // 事件
    event StoreLog(bytes32, string);

    constructor() {
        // 获取部署合约的人
        admin = msg.sender;
    }

    modifier onlyOwner() {
        require(admin == msg.sender, "You are permission denied");
        _;
    }

    modifier onlyWhite() {
        require(
            whiteMap[msg.sender] || admin == msg.sender,
            "You are permission denied"
        );
        _;
    }

    function SetWhite(address account) public onlyOwner returns (bool) {
        whiteMap[account] = true;
        return whiteMap[account];
    }

    function StoreSource(string memory dataJson)
        public
        onlyWhite
    {
        bytes32  hash_ = keccak256(abi.encodePacked(nonce, dataJson));
        map[hash_] = dataJson;
        mapInserted[hash_] = true;
        emit StoreLog(hash_, dataJson);
        nonce++;
    }

    function FindSource(bytes32 hashId) public view returns (string memory) {
        if (!mapInserted[hashId]) {
            return "";
        }
        return map[hashId];
    }
}