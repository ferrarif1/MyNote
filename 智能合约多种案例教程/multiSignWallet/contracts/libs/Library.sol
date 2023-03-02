//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library Library {
    // 冻结结构体
    struct FreezeTx {
        address to;
        uint256 fHeight;
        uint256 amount;
        bool isThaw;
    }
    // vip配置
    struct VipConfig {
        uint256 proportion;
        uint256 spaceHeight;
    }
    struct SignConfig {
        address[] owners; // 多签持有人数组
        mapping(address => bool) isOwner; // 记录一个地址是否为多签
        uint256 ownerCount; // 多签持有人数量
        uint256 threshold; // 多签执行门槛，交易至少有n个多签人签名才能被执行。
        uint256 nonce; // nonce，防止签名重放攻击
    }

}
