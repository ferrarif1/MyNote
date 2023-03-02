// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;
/// @dev Models a uint -> uint mapping where it is possible to iterate over all keys.
library IterableMapping {
    // Iterable mapping from bytes32 to uint;
    struct Map {
        bytes32 [] keys;
        mapping(bytes32 => string) values;
        mapping(bytes32 => uint) indexOf;
        mapping(bytes32 => bool) inserted;
    }

    function get(Map storage map, bytes32  key) public view returns (string memory) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (bytes32) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, bytes32  key, string memory val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, bytes32 key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        bytes32  lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}