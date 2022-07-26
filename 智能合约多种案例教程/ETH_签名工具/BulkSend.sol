//指定编译器版本，版本标识符
pragma solidity 0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error 带有安全检查的数学运算，一旦出错就会恢复
 * library常用于提供可复用方法，可以随合约[作为合约的一部分]发布，不过最终它是单独部署[到链上]的，有自己的地址。外部可以使用delegatecall方法调用库函数。
 * 我们使用library关键字来创建一个library，这和创建contract十分类似。但不像contract，在library中我们不能定义任何storage类型的变量。
 * 因为library只是意味着代码的重用而不是进行state的状态管理。
 */
 
library SafeMath {

  /**
  *@dev  两个数字相乘，溢出时恢复。
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  /**
  *@dev  两个数的整数除法截断商，除法归零。
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold 这一点在任何情况下都是成立的
    return c;
  }

  /**
  *@dev  减去两个数字，在溢出时还原（即，如果减数大于分钟数）
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  /**
  *@dev  两个数字相加，溢出时还原。
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  /**
  *@dev  将两个数相除并返回余数（无符号整数模），被零除时恢复。
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


/**
* 代币合约
*/
contract Token {
    uint8 public decimals;  //代币小数点位位数
    function balanceOf(address _owner) public view returns (uint256);     //查看_owner账户的余额，返回余额
    function transfer(address _to, uint256 _value) public returns (bool); //转账
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool); //授权转账
    function approve(address _spender, uint256 _value) public returns (bool);  //允许_spender地址来操作_value大小的余额
    function allowance(address _owner, address _spender) public constant returns (uint256);  //用来查询_owner允许_spender使用多少个代币
}

/**
* BulkSend 批量发送
*/
contract BulkSend {
    using SafeMath for uint256;   // 确保数据安全性
    address public owner;         // 合约主人
    address public pendingOwner;  // 待定主人
    uint public ethSendFee = 10000000000000000 ;   // 默认转ETH的手续费：0.01 eth in wei
    uint16 public arrayLimit = 150;  //批量转账最多数量
    

    // 构造函数 记录下合约的主人,
    constructor(address _pendingOwner) public payable{
        owner = msg.sender;
        pendingOwner = _pendingOwner;
    }
    
    // 调用者不是‘主人’，就会抛出异常（唯有合约的主人（也就是部署者）才能调用它）
    modifier onlyOwner() {
      require(msg.sender == owner, "Only the contract owner can call this function");
      _;
    }


    // 待定主人变为主人，并推荐另一个待定主人
    function claimOwner(address _newPendingOwner) public {
        require(msg.sender == pendingOwner);
        owner = pendingOwner;
        pendingOwner = _newPendingOwner;
    }

    // 设置批量转 ETH 的手续 (合约的主人才能调用它)
    function setEthFee(uint _ethSendFee) public onlyOwner returns(bool success){
        ethSendFee = _ethSendFee;
        return true;
    }

    // deposit 寄存放置 完成向合约地址里转ETH
    function deposit() payable public returns (address){
        return msg.sender;
    }
    
    // 获取地址 ETH 余额
    function getbalance(address addr) public constant returns (uint value){
        return addr.balance;
    }

    // 获取地址 ETH 余额
    function getTokebalance(address addr,Token tokenAddr) public constant returns (uint value){
        return tokenAddr.balanceOf(addr);
    }
    
    // 从合约地址转 ETH 给指定地址
    function withdrawEther(address addr, uint amount) public onlyOwner returns(bool success){
        addr.transfer(amount * 1 wei);
        return true;
    }
    // 从合约地址转 代币 给指定地址
    function withdrawToken(Token tokenAddr, address _to, uint _amount) public onlyOwner returns(bool success){
        tokenAddr.transfer(_to, _amount );
        return true;
    }

    // 将合约地址里的币 或 代币 提取到 创建合约主人
    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }
        Token erc20token = Token(_token);
        uint256 balance = erc20token.balanceOf(this);
        erc20token.transfer(owner, balance);
    }

    // 转 ETH 给指定地址
    function SendEther(address addr, uint amount) public payable returns(bool success){
        addr.transfer(amount * 1 wei);
        return true;
    }
    
    // 转 代币 给指定地址 注意：使用前先要调用Token合约里的approve，授权给本BulkSend的合约地址
    function SendToken(Token tokenAddr, address _to, uint _amount) public payable returns(bool success){
        require(_amount <= tokenAddr.allowance(msg.sender, address(this)), "Insufficient authorization limit");
        tokenAddr.transferFrom(msg.sender, _to, _amount);
        return true;
    }


    // 批量发送ETH：地址数组、金额数组
    function bulkSendEth(address[] addresses, uint256[] amounts) public payable returns(bool success){
        uint total = 0;  //转账总额
        require(addresses.length == amounts.length && addresses.length >= 1);
        require(addresses.length <= arrayLimit);
        for(uint8 i = 0; i < amounts.length; i++){
            total = total.add(amounts[i]);
        }
        
        // 确保ethreum足以完成事务
        uint requiredAmount = total.add(ethSendFee * 1 wei); 
        require(msg.value >= (requiredAmount * 1 wei), "The amount transferred in is not enough");
        
        // 转到每个地址
        for (uint8 j = 0; j < addresses.length; j++) {
            addresses[j].transfer(amounts[j] * 1 wei);
        }
        
        // 把扣掉手续费的余额发回给调用者
        if(msg.value * 1 wei > requiredAmount * 1 wei){
            uint change = msg.value.sub(requiredAmount);  //获取剩下的
            msg.sender.transfer(change * 1 wei);          //剩下的退回给发送者
        }
        return true;
    }
    
    
    // 批量发送代币    注意：使用前先要调用Token合约里的approve，授权给本BulkSend的合约地址
    function bulkSendToken(Token tokenAddr, address[] addresses, uint256[] amounts) public payable returns(bool success){
        uint total = 0;
        require(addresses.length == amounts.length && addresses.length >= 1);
        require(addresses.length <= arrayLimit);
        for(uint8 i = 0; i < amounts.length; i++){
            total = total.add(amounts[i]);
        }

        require(msg.value * 1 wei >= (ethSendFee * 1 wei), "The amount transferred in is not enough");        
        // 检查转币方给的授权额度、及转币方的自身币量
        require(total <= tokenAddr.allowance(msg.sender, this), "Insufficient authorization limit");
        require(total <= tokenAddr.balanceOf(msg.sender), "There are not enough tokens available");
        
        // transfer token to addresses
        for (uint8 j = 0; j < addresses.length; j++) {
            tokenAddr.transferFrom(msg.sender, addresses[j], amounts[j]);
        }
        // transfer change back to the sender
        if(msg.value * 1 wei > (ethSendFee * 1 wei)){
            uint change = (msg.value).sub(ethSendFee);
            msg.sender.transfer(change * 1 wei);
        }
        return true;
        
    }
	
	

    // 销毁当前合约，调用之后，合约仍然存在于区块链之上，但是函数无法被调用，调用会抛出异常。
    function destroy() public onlyOwner {
        selfdestruct(msg.sender); //销毁当前合约，将合约余额转到主人。注意：只转ETH
    }
}
