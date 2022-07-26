# 合约模版

## 可销毁的ERC721代币
> ERC721代币属于非同质化代币，全功能的ERC721代币包含ERC721的元数据和可枚举功能.
> 可销毁的ERC721代币是指在全功能的ERC721代币基础上增加了销毁的逻辑,账户只能销毁自己持有的代币.

[合约文件: ERC721Burnable.sol](https://github.com/TxCodeGroup/ContractTemplate/blob/master/contracts/ERC721/ERC721Burnable.sol)

[测试脚本: ERC721Burnable.js](https://github.com/TxCodeGroup/ContractTemplate/blob/master/test/ERC721/ERC721Burnable.js)

[布署脚本: 23_deploy_ERC721Burnable.js](https://github.com/TxCodeGroup/ContractTemplate/blob/master/migrations/23_deploy_ERC721Burnable.js)

### 在布署合约时定义以下变量
```javascript
string memory name,     //代币名称
string memory symbol,   //代币缩写
string memory baseURI,   //代币基础链接
```
### 调用方法
```javascript
//返回代币名称
name() public view returns (string memory)
//返回代币缩写
symbol() public view returns (string memory)
//token的基础链接地址
baseURI() external view returns (string memory) 
//添加代币方法，传入所有者地址和Token的数据链接地址
awardItem(address player, string memory tokenURI) public returns (uint256)
//根据tokenid返回数据连接地址
tokenURI(uint256 tokenId) external view returns (string memory)
//返回指定账户拥有的代币数量
balanceOf(address owner) public view returns (uint256)
//根据tokenid返回拥有者
ownerOf(uint256 tokenId) public view returns (address)
//批准代币
approve(address to, uint256 tokenId) public
//获取令牌ID的批准地址；如果未设置地址或tokenID不存在，则返回零；。
getApproved(uint256 tokenId) public view returns (address)
//将拥有者的所有代币批准给指定地址
setApprovalForAll(address to, bool approved) public
//获取操作者是否将代币全部批准给指定地址
isApprovedForAll(address owner, address operator) public view returns (bool)
//发送批准
transferFrom(address from, address to, uint256 tokenId) public
//安全发送批准
safeTransferFrom(address from, address to, uint256 tokenId) public
//获取请求的所有者的令牌列表的给定索引处的令牌ID
tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256)
//获取合约的代币总量
totalSupply() public view returns (uint256)
//通过索引获取代币
tokenByIndex(uint256 index) public view returns (uint256)
//销毁代币方法
burn(uint256 tokenId) public 
```
