//SPDX-License-Identifier: XKX-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
/** 
 * @title Lottery
 * @dev Ether lotery that transfer contract amount to winner
*/  
contract Lottery is ERC20  {
    
    // 购买彩票的玩家名单
    address payable[] public players;
    // 合约管理员
    address public admin;
    uint256 public tokensPerEth = 10;
    /**
     * @dev 让部署该合约的人为管理员
     */ 
    constructor() ERC20("MSHK ERC20 Token", "MSHK") {
        // 获取部署合约的人
        admin = msg.sender;
        // 自动在部署合约中添加管理员
        // players.push(payable(admin));
        // 向合约创建者发送 1000 个有18位小数的代币
        _mint(msg.sender, 10000 * 10 ** 18); // 总量 10000个
    }


    modifier onlyOwner() {
        require(admin == msg.sender, "You are not the owner");
        _;
    }
    //to call the enter function we add them to players
    function enter() public payable{
        //each player is compelled to add a certain ETH to join
        // require(msg.value > 0.1 ether, "msg.value < 0.1 ether");
        // uint256 amounts = msg.value;
        players.push(payable(msg.sender));
        _transfer(admin, msg.sender, 10 * 10 ** 18);
        // emit Transfer(admin, msg.sender, 10 * 10 ** 18);
    
    }

    function getMyToken() public view returns(uint) {
       return balanceOf(msg.sender);

    }

    /**
     * @dev requires the deposit of 0.1 ether and if met pushes on address on list
     */ 
    receive() external payable {
        //请求的合约值为 0.1 eth
        require(msg.value == 0.1 ether , "Must send 0.1 ether amount");
        
        // 确保管理员不能参与彩票购买
        require(msg.sender != admin);
        
        // 将进行交易的帐户推向玩家数组，作为应付的地址
        players.push(payable(msg.sender));
    }
    
    /**
     * @dev 获得合同余额
     * @return contract balance
    */ 
    function getBalance() public view onlyOwner returns(uint){
        // returns the contract balance 返回合同余额
        return address(this).balance;
    }
    /**
     * @dev 生成随机int *警告 *  - >不安全用于公共使用，检测到漏洞
     * @return random uint
     */ 
    function random() internal view returns(uint){
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    
    /** 
     * @dev 从彩票中挑选赢家，并授予冠军合同的余额
     */ 
    function pickWinner() public onlyOwner {
       
        // 确保我们在彩票中有足够的玩家：基础为2个  
        require(players.length >= 3 , "Not enough players in the lottery");
        // 选择随机号码的获胜者
        address payable winner;
        winner = players[random() % players.length];
        // 数值
        // 其中收取10%的手续费
        uint256 winnerAmount = (getMyToken() * 90 / getBalance()) / 100;
        require(winnerAmount > 0.0 ether, "Failed to winner amount is zero");
        // 将金额转给赢家
        (bool sent,) = winner.call{value: winnerAmount}("");
        require(sent, "Failed to send user balance back to the owner");
        // 挑选某人后，重置彩票数组
        resetLottery();  
    }

    /**
     * @dev 重置彩票数组
     */ 
    function resetLottery() internal {
        // 重置彩票人员
        players = new address payable[](0);
        // 进行转账支付给平台管理人
        (bool ad,) = admin.call{value: getBalance()}("");
        require(ad, "Failed to send user balance back to the admin fee");
    }

}