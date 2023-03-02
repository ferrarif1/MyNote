//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library PermLib {
    // 权限结构体
    struct PermConf {
        // 合约管理者
        address admin;
        // 白名单地址
        address whiteAddress;
    }
}