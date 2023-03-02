# 元交易

元交易是一个普通的以太坊交易，它包含另一个交易，即实际交易。实际交易由用户签署，然后发送给运营商（或类似的操作者），用户不需要Gas和区块链交互。而是由运营商支付费用签署交易，提交给区块链。

合约确保在实际交易上有一个有效的签名，然后执行它。

## 实现

通过代理合约去调用代币或者其他合约以达到让代理人出手续费的功能，如contract/MetaTxForwarder.sol:

```js
  (bool success, bytes memory returndata) = req.to.call{ gas: req.gas, value: req.value } (abi.encodePacked(req.data, req.from));  
```

在被调用的合约里需要继承ERC2771Context.sol 合约，如contract/XunWenGe1155.sol:

- 引入ERC2771Context

```js
constructor(address trustedForwarder)
        ERC1155("https://whex.oss-cn-hangzhou.aliyuncs.com/metadata/{id}.json") 
        ERC2771Context(trustedForwarder)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TRANSFER, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }
```

- 重写函数 _msgSender()、_msgData()

重写的原因是为了获取代理合约调用的发送者和数据

```js

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

```

## 校验

代理合约需要确保安全性，采用了EIP712、ECDSA 进行签名认证。

- 引入EIP721

```js
 constructor() EIP712("MinimalForwarder", "0.0.1") {}
```

- 校验格式

```js
 bytes32 private constant _TYPEHASH = keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");

```

- 校验

```js
   function verify(ForwardRequest calldata req, bytes calldata signature) public view returns (bool) {
        address signer = _hashTypedDataV4(keccak256(abi.encode(_TYPEHASH, req.from, req.to, req.value, req.gas, req.nonce, keccak256(req.data)))
        ).recover(signature);
        return _nonces[req.from] == req.nonce && signer == req.from;
    }
```

## 部署合约流程

先部署代理合约 MetaTxForwarder.sol，获得代理合约的地址

将代理合约地址传入 代币合约的部署条件里：

```js
    // trustedForwarder 是 代理合约 的地址
    constructor(address trustedForwarder)
        ERC1155("https://whex.oss-cn-hangzhou.aliyuncs.com/metadata/{id}.json") 
        ERC2771Context(trustedForwarder)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TRANSFER, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }
```


## 合约打包成java

- 新建build目录:

> mkdir build


- 打包 XunWenGe1155.sol

> solcjs -o build/bin --abi --bin contracts/XunWenGe1155.sol
> cd build/bin
> ./web3j-1.4.2/bin/web3j generate solidity -b contracts_XunWenGe1155_sol_XunWenGe.bin -a ./contracts_XunWenGe1155_sol_XunWenGe.abi  -o ./ -p com.contract.proxy

- 打包 MetaTxForwarder.sol

> solcjs -o bin --abi --bin contracts/MetaTxForwarder.sol
> cd bin
> ./web3j-1.4.2/bin/web3j generate solidity -b contracts_MetaTxForwarder_sol_MetaTxForwarder.bin -a ./contracts_MetaTxForwarder_sol_MetaTxForwarder.abi  -o ./ -p com.contract.proxy