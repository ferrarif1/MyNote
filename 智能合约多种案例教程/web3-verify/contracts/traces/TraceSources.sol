// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./IterableMapping.sol";

contract TraceSources {

    mapping(string => IterableMapping.Map) private map;

    IterableMapping.Map private kindMap;
    
    struct Response {
        string kindName;
        string hashId;
        string dataJson;
    }

    function StoreSource(
        string memory kindName,
        string memory hashId,
        string memory dataJson
    ) public returns (bool) {
        require(!map[kindName].inserted[hashId], "hashId is not empty");
        kindMap.set(kindName, kindName);
        map[kindName].set(hashId, dataJson);
        return true;
    }

    function FindSource(string memory kindName, string memory hashId)
        public
        view
        returns (string memory)
    {
        if (!map[kindName].inserted[hashId]) {
            return "";
        }
        return map[kindName].get(hashId);
    }
    
    // 根据类型和交易hash来进行模糊查询
    function QuerySource(string memory query)
        public
        view
        returns (Response[] memory)
    {
        Response[] memory res = new Response[](kindMap.size());
        uint256 s = 0;
        if (!kindMap.inserted[query]) {
            for (uint256 i = 0; i < kindMap.size(); i++) {
                // 获取查询的值
                if (map[kindMap.getKeyAtIndex(i)].inserted[query]) {
                    string memory name = kindMap.getKeyAtIndex(i);
                    res[s++] = Response(name, query, map[name].get(query));
                }
            }
        } else {
            res = new Response[](map[query].size());
            for (uint256 i = 0; i < map[query].size(); i++) {
                string memory key = map[query].getKeyAtIndex(i);
                // 获取查询的值
                res[s++] = Response(query, key, map[key].get(query));
            }
        }
        // 过滤数组
        Response[] memory filterRes = new Response[](s);
        for (uint256 index = 0; index < s; index++) {
            filterRes[index] = res[index];
        }
        return filterRes;
    }
}
