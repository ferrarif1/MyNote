// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

contract XunWenGe is ERC1155, AccessControl, ERC1155Burnable, ERC2771Context {
    bytes32 public constant TRANSFER = keccak256("TRANSFER");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private _imageUri =
        "https://whex.oss-cn-hangzhou.aliyuncs.com/metadata/";

    mapping(address => mapping(uint256 => bool)) balanceMap;
    mapping(address => uint256[]) tokensMap;

    struct BalanceInfo {
        address from;
        uint256 tokenId;
        uint256 amount;
        string url;
    }

    enum TxEnum {
        None,
        BatchOfAddress,
        BatchMatch
    }

    // 通过该方法记录交易信息
    event TransferLog(
        address,
        address[],
        uint256[],
        uint256[],
        TxEnum,
        bytes data
    );

    event MintLog(address[], uint256[], uint256[], TxEnum, bytes);

    constructor(address trustedForwarder)
        ERC1155(getUrl())
        ERC2771Context(trustedForwarder)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TRANSFER, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function uri(uint256 _tokenid)
        public
        view
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(_imageUri, Strings.toString(_tokenid), ".json")
            );
    }

    function setTransfer(address transferAddress)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _grantRole(TRANSFER, transferAddress);
    }

    function setURI(string memory newuri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _imageUri = newuri;
        _setURI(getUrl());
    }

    function getUrl() public view returns (string memory) {
        return string(abi.encodePacked(_imageUri, "{id}.json"));
    }

    /// @notice 进行接口继承
    /// @notice The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * _paramCheck
     * @notice 进行合约参数检查
     */
    function _paramCheck(
        address[] memory accounts,
        uint256[] memory ids,
        uint256[] memory amounts,
        TxEnum enumType
    ) public pure {
        require(accounts.length > 0, "param error: accounts is null");
        require(ids.length > 0, "param error: ids is null");
        require(amounts.length > 0, "param error: amounts is null");
        require(ids.length == amounts.length, "param error: arry is error");
        if (enumType != TxEnum.BatchOfAddress) return;
        require(ids.length == accounts.length, "param error: arry is error");
    }

    /**
     * exchangeMint
     * @notice 执行铸造：批量、单个
     */
    function exchangeMint(
        address[] memory tos, // 铸造的接收地址
        uint256[] memory ids, // ids NFT 的序号
        uint256[] memory amounts, // 每个序号的NFT 转账的数量
        TxEnum txType, // 自定义的数据类型 需要转16进制
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        emit MintLog(tos, ids, amounts, txType, data);
        // 进行参数校验
        _paramCheck(tos, ids, amounts, txType);

        // 判断是单个mint还是批量
        // 单个mint
        if (txType == TxEnum.None) {
            _mint(tos[0], ids[0], amounts[0], "");
        }

        // 批量mint
        if (txType == TxEnum.BatchOfAddress) {
            _mintBatch(tos[0], ids, amounts, "");
        }

        // 批量mint
        if (txType == TxEnum.BatchMatch) {
            for (uint256 i = 0; i < tos.length; i++) {
                _mint(tos[i], ids[i], amounts[i], "");
            }
        }
        updateBalance(tos, ids);
    }

    /**
     * exchangeTransfer
     * @notice 执行交易: 回购、分发、转账
     * @param  from - 发送地址
     * @param  tos - 接收地址
     * @param  ids -  NFT 的序号
     * @param  amounts - 每个序号的NFT 转账的数量
     * @param  data - 自定义的数据类型 需要转16进制
     * @param  txType - 类型 0 是给to转账1个序号的nft 类型, 1 是给to转多个序号的 NFT
     * @dev 回购、分发、转账的业务之前是分成多个 本质上就是调用 _safeTransferFrom 函数
     */
    function exchangeTransfer(
        address from, // 发送地址
        address[] memory tos, // 接收地址
        uint256[] memory ids, // ids NFT 的序号
        uint256[] memory amounts, // 每个序号的NFT 转账的数量
        TxEnum txType, // 类型 0 是给to转账1个序号的nft 类型, 1 是给to转多个序号的NFT
        bytes memory data // 自定义的数据类型 需要转16进制
    ) public onlyRole(TRANSFER) {
        // 进行参数校验
        _paramCheck(tos, ids, amounts, txType);
        // 记录执行
        emit TransferLog(from, tos, ids, amounts, txType, data);

        // 判断是单个转账还是批量
        // 单笔转账
        if (txType == TxEnum.None) {
            _safeTransferFrom(from, tos[0], ids[0], amounts[0], data);
        }
        // 批量转账
        if (txType == TxEnum.BatchOfAddress) {
            _safeBatchTransferFrom(from, tos[0], ids, amounts, data);
        }
        // 批量转账 a->b,a->c,a->d
        // 转账 tokenId: [1,2,3], 数量: [10,20,50]
        // a->b (1:10),
        // a->c (2:20),
        // a->d (3:50)
        if (txType == TxEnum.BatchMatch) {
            for (uint256 i = 0; i < tos.length; i++) {
                _safeTransferFrom(from, tos[i], ids[i], amounts[i], data);
            }
        }
        updateBalance(tos, ids);
    }

    /**
     * exchangeBurn
     * @notice 执行销毁
     */
    function exchangeBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts,
        TxEnum txType
    ) public onlyRole(TRANSFER) {
        // 进行参数校验
        address[] memory accounts = new address[](1);
        accounts[0] = from;
        _paramCheck(accounts, ids, amounts, txType);
        // 判断是单个销毁还是批量
        // 单个销毁
        if (txType == TxEnum.None) {
            _burn(from, ids[0], amounts[0]);
            return;
        }
        // 批量销毁
        if (txType == TxEnum.BatchOfAddress) {
            _burnBatch(from, ids, amounts);
            return;
        }
    }

    function updateBalance(address[] memory accounts, uint256[] memory ids)
        private
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            if (balanceMap[accounts[i]][ids[i]]) {
                continue;
            }
            balanceMap[accounts[i]][ids[i]] = true;
            tokensMap[accounts[i]].push(ids[i]);
        }
    }

    function getAccountBalance(address from)
        public
        view
        returns (BalanceInfo[] memory)
    {
        uint256[] memory tokens = tokensMap[from];
        BalanceInfo[] memory balanceInfo = new BalanceInfo[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 amount = balanceOf(from, tokens[i]);
            string memory url = uri(tokens[i]);
            balanceInfo[i] = BalanceInfo(from, tokens[i], amount, url);
        }
        return balanceInfo;
    }

    function _msgSender()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (address)
    {
        return ERC2771Context._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }
}
