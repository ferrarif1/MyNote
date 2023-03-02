// SPDX-License-Identifier: MIT
// author: @0xAA_Science from wtf.academy
pragma solidity ^0.8.6;
import "./ZeroToken.sol";
import "./libs/PermLib.sol";
import "./libs/Library.sol";

contract signUtil {

    event ExecutionSuccess(bytes32 txHash); // 交易成功事件
    event ExecutionFailure(bytes32 txHash); // 交易失败事件
    
    /// 将单个签名从打包的签名分离出来
    /// @param signatures 打包的多签
    /// @param pos 要读取的多签index.
    function signatureSplit(bytes memory signatures, uint256 pos)
        internal
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        // 签名的格式：{bytes32 r}{bytes32 s}{uint8 v}
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }

    /// @dev 编码交易数据
    /// @param to 目标合约地址
    /// @param value msg.value，支付的以太坊
    /// @param data calldata
    /// @param _nonce 交易的nonce.
    /// @param tx_type 交易的类型.0-erc20代币，1-eth
    /// @param chainid 链id
    /// @return 交易哈希bytes.
    function encodeTransactionData(
        address to,
        uint256 value,
        bytes memory data,
        uint256 _nonce,
        uint256 tx_type,
        uint256 chainid
    ) public pure returns (bytes32) {
        bytes32 safeTxHash = keccak256(abi.encode(to, value, keccak256(data), tx_type, _nonce, chainid));
        return safeTxHash;
    }

    /**
     * @dev 检查签名和交易数据是否对应。如果是无效签名，交易会revert
     * @param dataHash 交易数据哈希
     * @param signatures 几个多签签名打包在一起
     */
    function checkSignOwers(bytes32 dataHash, bytes memory signatures)
        public
        pure
        returns (address[] memory signOwers)
    {
        // 读取多签执行门槛
        uint256 _threshold = signatures.length / 130;
        // 检查签名长度足够长
        require(_threshold > 0, "signatures is too low");
        // 通过一个循环，检查收集的签名是否有效
        // 大概思路：
        // 1. 用ecdsa先验证签名是否有效
        // 2. 利用 currentOwner > lastOwner 确定签名来自不同多签（多签地址递增）
        // 3. 利用 isOwner[currentOwner] 确定签名者为多签持有人
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for (i = 0; i < _threshold; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            // 利用ecrecover检查签名是否有效
            currentOwner = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19Ethereum Signed Message:\n32",
                        dataHash
                    )
                ),
                v,
                r,
                s
            );
            require(
                currentOwner > address(0),
                "currentOwner > lastOwner WTF5007"
            );
            signOwers[i] = currentOwner;
        }
    }
}

/// 基于签名的多签钱包，由gnosis safe合约简化而来，教学使用。
contract MultiSigWallet is signUtil {
    using Library for *;
    using PermLib for *;

    Library.FreezeTx[] public heightTx;
    Library.VipConfig private vipConfig;
    PermLib.PermConf private permConf;
    Library.SignConfig public signConfig;
    uint256 endIndex;
    uint256 public chainId;
    // Token地址，设置为私有变量
    ZeroToken private zeroToken;
    event tLog(uint256, string);
    event buyTokenVipLog(address, uint256);
    // 构造函数，初始化owners, isOwner, ownerCount, threshold
    constructor(
        address tokenAddress,
        address[] memory _owners,
        uint256 _threshold
    ) {
        permConf.admin = msg.sender;
        chainId = block.chainid;
        zeroToken = ZeroToken(tokenAddress);
        _setupOwners(_owners, _threshold);
    }

    // 权限设置
    // 仅供管理员访问
    modifier onlyOwner() {
        require(permConf.admin == msg.sender, "You are not the owner");
        _;
    }

    // 多签用户
    modifier onlyOwnerList() {
        require(signConfig.isOwner[msg.sender] || permConf.admin == msg.sender,"You are not the owner");
        _;
    }

    // 允许存币
    receive() external payable {}

    // to call the enter function we add them to players
    // 当有eth转入时触发
    function enter() public payable {}

    function setVipConf(uint256 proportion,uint256 spaceHeight) public onlyOwner {
        vipConfig.proportion = proportion;
        vipConfig.spaceHeight = spaceHeight;
    }
    /// @dev 初始化owners, isOwner, ownerCount,threshold
    /// @param _owners: 多签持有人数组
    /// @param _threshold: 多签执行门槛，至少有几个多签人签署了交易
    function _setupOwners(address[] memory _owners, uint256 _threshold)
        internal
    {
        // threshold没被初始化过
        require(signConfig.threshold == 0, "threshold is not init");
        // 多签执行门槛 小于 多签人数
        require(_threshold <= _owners.length, "threshold is too low");
        // 多签执行门槛至少为1
        require(_threshold >= 1, "min threshold is 1");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            // 多签人不能为0地址\本合约地址\不能重复
            require(owner != address(0) && owner != address(this) &&!signConfig.isOwner[owner],"_owners fail");
            signConfig.owners.push(owner);
            signConfig.isOwner[owner] = true;
        }
        signConfig.ownerCount = _owners.length;
        signConfig.threshold = _threshold;
    }

    /// @dev 在收集足够的多签签名后，执行交易
    /// @param to 目标合约地址
    /// @param value msg.value，转账金额
    /// @param tx_type 交易的类型.0-erc20代币，1-eth
    /// @param data calldata
    /// @param signatures 打包的签名，对应的多签地址由小到达，方便检查。 ({bytes32 r}{bytes32 s}{uint8 v}) (第一个多签的签名, 第二个多签的签名 ... )
    function execTransaction(
        address to,
        uint256 value,
        bytes memory data,
        uint256 tx_type,
        bytes memory signatures
    ) public payable virtual onlyOwnerList returns (bool success) {
        // 编码交易数据，计算哈希
        bytes32 txHash = encodeTransactionData(
            to,
            value,
            data,
            signConfig.nonce,
            tx_type,
            block.chainid
        );
        signConfig.nonce++; // 增加nonce
        checkSignatures(txHash, signatures); // 检查签名
        if (tx_type == 1) {
            // 利用call执行交易，并获取交易结果
            (success, ) = payable(to).call{value: value}("");
            require(success,"Failed to send user balance back to the contract");
        } else {
            zeroToken.allowAdminSendToken(to, value);
            success = true;
        }
        require(success, "call transaction fail");
        if (success) emit ExecutionSuccess(txHash);
        else emit ExecutionFailure(txHash);
    }

    /**
     * @dev 检查签名和交易数据是否对应。如果是无效签名，交易会revert
     * @param dataHash 交易数据哈希
     * @param signatures 几个多签签名打包在一起
     */
    function checkSignatures(bytes32 dataHash, bytes memory signatures)
        public
        view
    {
        // 读取多签执行门槛
        uint256 _threshold = signConfig.threshold;
        require(_threshold > 0, "threshold is not init");
        // 检查签名长度足够长
        require(signatures.length >= _threshold * 65, "signatures is too low");
        // 通过一个循环，检查收集的签名是否有效
        // 大概思路：
        // 1. 用ecdsa先验证签名是否有效
        // 2. 利用 currentOwner > lastOwner 确定签名来自不同多签（多签地址递增）
        // 3. 利用 isOwner[currentOwner] 确定签名者为多签持有人
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for (i = 0; i < _threshold; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            // 利用ecrecover检查签名是否有效
            currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",dataHash)),v,r,s);
            require(currentOwner > address(0),"currentOwner is address(0)");
            require(signConfig.isOwner[currentOwner],"isOwner[currentOwner] sign is not allow");
        }
    }
     // 注册会员、冻结金额
    function registeredMember(address _to, uint256 amount)
        public
        payable
        returns (bool res)
    {
        require(msg.value > 0, "Ether value sent is not correct");
        uint256 fAmount = 0;
        res = false;

        if (vipConfig.proportion > 0 && vipConfig.proportion < 1) {
            fAmount = (amount * vipConfig.proportion) / 100;
        }
        uint256 sendAmount = amount - fAmount;
        // 转账前先判断资金是否充足
        require(zeroToken.getBalance(address(this)) > sendAmount,"sender is Insufficient amount");
        bool success = zeroToken.transfer(_to, sendAmount);
        // 转账错误，抛出错误,revert进行回滚
        if (!success) revert("thaw amount transfer faill");
        if (fAmount > 0) {
            // 记录冻结信息
            heightTx.push(
                Library.FreezeTx({
                    to: _to,
                    fHeight:  block.number + vipConfig.spaceHeight + 1,
                    amount: fAmount,
                    isThaw: false
                })
            );
        }
        res = true;
        // 交易信息记录在链上
        emit buyTokenVipLog(_to, amount);
    }

    // 解冻金额
    function thawAmount() public returns(bool success) {
        // 先清理数组
        uint256 lastIndex = endIndex;
        for (uint256 i = lastIndex; i < heightTx.length; i++) {
            // 判断是否符合条件
            // 是否比最新高度低 && 还没进行处理
            if (heightTx[i].fHeight <= block.number &&!heightTx[i].isThaw) {
                // 转账前先判断资金是否充足
                if(zeroToken.getBalance(address(this)) < heightTx[i].amount)
                    revert("transfer Insufficient amount");
                heightTx[i].isThaw = true;
                lastIndex = i;  
                // 将尾款转给指定地址
                success = zeroToken.transfer(heightTx[i].to,heightTx[i].amount);
                // 转账错误，抛出错误进行回滚
                if (!success) revert("thaw amount transfer faill");   
            }
        }
        endIndex = lastIndex+1;
    }
}