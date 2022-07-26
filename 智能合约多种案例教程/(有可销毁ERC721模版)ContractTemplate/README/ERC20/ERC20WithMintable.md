# 合约模版

## 可增发代币
> 可增发代币是指在发行后,拥有铸造权的账户可以增发代币.也可以增加和撤销账户的铸造权.

[合约文件: ERC20WithMintable.sol](https://github.com/TxCodeGroup/ContractTemplate/blob/master/contracts/ERC20/ERC20WithMintable.sol)

[测试脚本: ERC20WithMintable.js](https://github.com/TxCodeGroup/ContractTemplate/blob/master/test/ERC20/ERC20WithMintable.js)

[布署脚本: 4_deploy_ERC20WithMintable.js](https://github.com/TxCodeGroup/ContractTemplate/blob/master/migrations/4_deploy_ERC20WithMintable.js)

### 在布署合约时定义以下变量
```javascript
string memory name,     //代币名称
string memory symbol,   //代币缩写
uint8 decimals ,        //精度
uint256 totalSupply     //发行总量
```
### 调用方法
```javascript
//返回代币名称
name() public view returns (string memory)
//返回代币缩写
symbol() public view returns (string memory)
//返回代币精度
decimals() public view returns (uint8)
//返回发行总量
totalSupply() external view returns (uint256)
//返回指定地址的余额
balanceOf(address account) external view returns (uint256)
//发送代币,从当前账户发送到指定地址
transfer(address recipient, uint256 amount) external returns (bool)
//查询owner给予spender的配额
allowance(address owner, address spender) external view returns (uint256)
//批准spender代表发送者使用amount数量的代币
approve(address spender, uint256 amount) external returns (bool)
//spender调用这个函数发送sender账户中的amount数量的代币给recipient
transferFrom(address sender, address recipient, uint256 amount) external returns (bool)
//增加给予spender的配额
increaseAllowance(address spender, uint256 addedValue) public returns (bool)
//减少给予spender的配额
decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool)
//特殊方法
//查询指定地址是否拥有铸币权
isMinter(address account) public view returns (bool)   
//给指定地址添加铸币权,只能通过有铸币权的地址添加
addMinter(address account) public onlyMinter          
//撤销当前发送账户的铸币权 
renounceMinter() public               
//铸币                 
mint(address account, uint256 amount) public onlyMinter returns (bool) 
```
