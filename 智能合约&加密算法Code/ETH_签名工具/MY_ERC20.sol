//指定编译器版本，版本标识符 ^表示大于等于当前版本，小于下一个主版本号
pragma solidity ^0.4.15;

/**
 简明的ERC20合约，9个函数、2个事件
contract ERC20 {
   function name() constant public returns (string name);
   function symbol() public constant returns (string symbol);
   function decimals() public constant returns (uint8 decimals);
   function totalSupply() constant returns (uint theTotalSupply);
   function balanceOf(address _owner) constant returns (uint balance);
   function transfer(address _to, uint _value) returns (bool success);
   function transferFrom(address _from, address _to, uint _value) returns (bool success);
   function approve(address _spender, uint _value) returns (bool success);
   function allowance(address _owner, address _spender) constant returns (uint remaining);
   event Transfer(address indexed _from, address indexed _to, uint _value);
   event Approval(address indexed _owner, address indexed _spender, uint _value);
 } 
 写智能合约的WEB http://remix.ethereum.org/
 Solidity 合约和面向对象语言非常相似。每个合约均能包含状态变量State Variables, 函数Functions, 函数修饰符Function Modifiers, 
 事件Events, 结构体类型Struct Types 和 枚举类型Enum Types。除此以外，还有比较特殊的合约叫做库libraries和接口interfaces
 http://liyuechun.com/123.html
 
 library
library常用于提供可复用方法，可以随合约[作为合约的一部分]发布，不过最终它是单独部署[到链上]的，有自己的地址。外部可以使用delegatecall方法调用库函数。
我们使用library关键字来创建一个library，这和创建contract十分类似。但不像contract，在library中我们不能定义任何storage类型的变量。因为library只是意味着代码的重用而不是进行state的状态管理。

internal的库函数对所有合约可见。
using for：指令using A for B;用来附着库A里定义的函数到任意类型B，函数的第一个参数应是B的实例。可以使用using A for *，将库函数赋予任意类型。库函数可以重载的，你可以定义好几个同名函数，但是第一个参数的类型不同，调用的时候自动的根据调用类型选择某一种方法。

address indexed
The indexed parameters for logged events will allow you to search for these events using the indexed parameters as filters.
The indexed keyword is only relevant to logged events.

几个预定义字段
address.balance：地址余额，指该地址相关的以太币数额。
msg.sender：交易发起人。
this：合约地址。
msg.value：发起这笔交易支付的以太币数额，和payable搭配使用。
似乎还有msg.sig、msg.data、msg.gas。

payable
修饰函数，表示在调用函数时，可以给这个合约充以太币（合约也是一种账户，也有自己的地址）。合约本身持有以太币，可使得用户基于此合约进行跨币交易更方便。

constant、view、pure
constant修饰常量或函数，修饰函数时表示该函数不修改合约状态，即不产生需广播的交易，也就不会消耗gas，一般用于读状态或状态无关操作。0.4.17开始，改为view和pure修饰函数，前者表示读状态，后者表示状态无关。

存储区
storage：状态变量，将存储在链上；
memory：临时变量

interface：搭配传入的不同address，实现多态。
event，应用层(web3)可通过watch监听，应该是用轮询实现。
modifier，简单的aop，编译时会将代码替换合并。

基于以太坊发行的ERC20代币合约代码大集合 ： https://github.com/2liang/ERC20ContractCodeLibrary
*/
 
// 接口，好像用来实现允许一个地址（合约）以我（创建交易者）的名义可最多花费的代币数
interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}
 
contract MyERCToken {

	// ERC20代币名称
	string public name = "My Token is AnyToken"; 
	
	// ERC20代币符号
	string public symbol = "AT";
	
	// 创建映射表来记录账户余额
	mapping(address => uint256) balances;
	
	// decimals 可以有的小数点个数，最小的代币单位。18 是建议的默认值
	uint8 public decimals = 2;
	
	//通证供给量是固定的，但也可以将其设定为可修改的
	uint256 public totalSupply = 1000000;
	
	// 用mapping保存每个地址对应的余额
	mapping (address => uint256) public balanceOf;
	 
	// 创建映射表记录通证持有者、被授权者以及授权数量
	mapping (address => mapping (address => uint256)) public allowance;

	//1.发生转账时必须要触发的事件,transfer 和 transferFrom 成功执行时必须触发的事件
	event Transfer(address indexed _from, address indexed _to, uint _value);
	
	//2.当函数 approve(address _spender, uint256 _value)成功执行时必须触发的事件
	event Approval(address indexed _owner, address indexed _spender, uint _value);

	// 合约拥有者、合约主人 (非ERC20标准)
	address public owner;
	
	// 合约待定主人 (非ERC20标准)
	address public pendingOwner;
	
	
    // 构造函数: 代币名称、代币符号、代币小数点个数、代币总量、合约待定主人地址,
    constructor(string _name,string _symbol,uint8 _decimals,uint256 _totalSupply,address _pendingOwner) public payable{
        if (bytes(_name).length != 0) {
			name = _name;
		}
		if (bytes(_symbol).length != 0) {
			symbol = _symbol;
		}
		if (_decimals > 0 && _decimals<19) {
			decimals = _decimals;
		}
		if (_totalSupply >0) {
			totalSupply = _totalSupply * 10 ** uint256(decimals);  // 供应的份额，份额跟最小的代币单位有关，份额 = 币数 * 10 ** decimals。
		}
		balanceOf[msg.sender] = totalSupply;  // 创建者拥有所有的代币
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

    /**
     * 查询 _owner 授权 _spender 的额度
	 * ERC20标准
     */
	//function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		//return allowed[_owner][_spender];
	//}

    /**
     * 代币交易转移的内部实现
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // 确保目标地址不为0x0，因为0x0地址代表销毁
        require(_to != address(0x0), "The dest address is 0x0!");
        // 检查发送者余额
        require(balanceOf[_from] >= _value, "Insufficient balance of sending address!");
        // 确保转移为正数个
        require(balanceOf[_to] + _value > balanceOf[_to], "The sending quota is negative!");

        // 以下用来检查交易，
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value); //事件

        // 用assert来检查代码逻辑。
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     *  代币交易转移
     *  从自己（创建交易者）账号发送`_value`个代币到 `_to`账号
     * ERC20标准
     * @param _to 接收者地址
     * @param _value 转移数额
     */
    function transfer(address _to, uint256 _value) public returns (bool success){
        _transfer(msg.sender, _to, _value);
		return true;
    }
	
    /**
     * 账号之间代币交易转移 (需要配合approve的授权)
     * ERC20标准
     * @param _from  发送者地址（提供授权方）
     * @param _to    接收者地址
     * @param _value 转移数额
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Insufficient transfer authorization!");  //检测授权额度 allowance
		require(balanceOf[_from] >= _value, "Insufficient balance of sending address!"); //检测发送者余额
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

	/**
     * 设置某个地址（合约）可以创建交易者名义花费的代币数。
     * 允许发送者`_spender` 花费不多于 `_value` 个代币
     * ERC20标准
     * @param _spender 授权给的地址
     * @param _value   授权最大使用量
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value); // 事件
        return true;
    }

    /**
     * 设置允许一个地址（合约）以我（创建交易者）的名义可最多花费的代币数。
     * 这里的approveAndCall方法，就调用了接口。把自己的代币授权给某个合约接口。并且调用合约的后续处理方法。执行通知。
     *-非ERC20标准
     * @param _spender 被授权的地址（合约）
     * @param _value 最大可花费代币数
     * @param _extraData 发送给合约的附加数据
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            // 通知合约
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
	
	
    /**
     * 销毁用户账户中指定个代币
     *-非ERC20标准
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        return true;
    }
	
     /**
     * 销毁我（创建交易者）账户中指定个代币
     *-非ERC20标准
     */
    function burn(uint256 _value) public onlyOwner returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        return true;
    }
	

    // 销毁本合约，调用之后，合约仍然存在于区块链之上，但是函数无法被调用，调用会抛出异常。
    function destroy() public onlyOwner {
        selfdestruct(msg.sender); //销毁当前合约，并把它所有资金发送到给定的地址
    }
}
