#coding='utf-8'
#在linux系统使用，编码采用 UTF-8 BOM; 同时前面要用 #coding='utf-8'
'''
======安装PYTHON3 ===============
sudo apt-get update
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:jonathonf/python-3.6

sudo apt-get update
sudo apt-get install -y python3.6

cd /usr/bin
rm python3
ln -s python3.6m python3
rm python
ln -s python3.6m python

sudo apt-get install -y python3-pip

sudo pip3 install --upgrade pip
pip3 install web3

========= 安装solc solidity是以太坊智能合约的开发语言 ============================
sudo add-apt-repository ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install solc

========== 安装 Node.js 12.13.0 http://nodejs.cn/download/ =======================

查看linux 操作系统为多少位: uname -m
 i686 (or 有时候会是i386) 说明操作系统是32位的， x86_64 是64位的。
-------------------------------------------------------------------------

cd /
mkdir software
cd software
wget https://cdn.npm.taobao.org/dist/node/v12.13.0/node-v12.13.0-linux-x64.tar.xz

tar -xvf node-v12.13.0-linux-x64.tar.xz  
mv node-v12.13.0-linux-x64 nodejs 

ln -s /software/nodejs/bin/npm /usr/local/bin/
ln -s /software/nodejs/bin/node /usr/local/bin/
cd ~
node -v
npm -v
==========
sudo npm i npm to update  更新npm
sudo npm cache verify     验证缓存数据的有效性和完整性，清理垃圾数据

-------- 安装 cnpm ， 国外的服务器不用安装 -----------
sudo npm install -g cnpm --registry=https://registry.npm.taobao.org
有的要做个软链接
ln -s /software/nodejs/lib/node_modules/cnpm/bin/cnpm /usr/local/bin/

=========== 安装WEB3 ===================
mkdir ~/web3_test
cd ~/web3_test
npm init
sudo npm install web3 --save-dev 
#--save-dev 安装模块到项目node_modules目录下。会将模块依赖写入devDependencies 节点。

npm list web3 查看WEB3版本

========== 将合约编译，并生成 ABI 文件=====
solc --abi xxx.sol
'''
import web3                 #pip3 install web3
from web3 import Web3
import json,os,sys,time
import re,requests
# 以太坊ERC20代币合约案例 https://www.cnblogs.com/jameszou/p/10131443.html
# Python与以太坊交互实战 https://blog.csdn.net/g8433373/article/details/82432766?utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromMachineLearnPai2%7Edefault-12.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromMachineLearnPai2%7Edefault-12.control
# Python使用Web3.py进行ERC20代币开发 http://blog.hubwiz.com/2018/11/30/ethereum-python-web3py-erc20/
# web3py的ETH(以太坊)真正实现批量转账 http://www.babyitellyou.com/details?id=603debf24da5fa6fd85cc1ed
#  爬取etherscan上的ERC20代币详情 https://blog.csdn.net/qq_43412005/article/details/107845980
# XDAI链 RPC操作 通过JSON-RPC： https://eth.wiki/json-rpc/API
# 写智能合约的WEB http://remix.ethereum.org/
# 详解如何把ERC20代币迁移到新合约 https://zhuanlan.zhihu.com/p/143295244

# 自写批量转ETH和代币的合约：https://github.com/anysou/solidity-multisend/blob/master/multisend.sol
# 在goerli测试网上部署合约地址为：0x9a4EB0928C7c9C36F7687eaE19C44C20009B3E1e；ABI文档名为：multisend.json
# 
'''
BZZ (Ethereum main chain): 0x19062190b1925b5b6689d7073fdfc8c2976ef8cb
BZZ (Bridged BZZ on xDAI): 0xdBF3Ea6F5beE45c02255B2c26a16F300502F68da

当前 网络版本
curl -s -i http://xdai.anybee:8545 -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' | grep 'jsonrpc'
当前币库地址
curl -s -i http://xdai.anybee:8545 -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_coinbase","params":[],"id":2}' | grep 'jsonrpc'
当前 eth_gasPrice
curl -s -i http://xdai.anybee:8545 -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":2}' | grep 'jsonrpc'
查询余额 eth_getBalance
curl -s -i http://xdai.anybee:8545 -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0x95e65a0687da52441ad487a8021de89ef51dca28","latest"],"id":2}' | grep 'jsonrpc' | sed 's/"//g' 

#==== 错误分析 ==========
#1） #{'code': -32000, 'message': 'only replay-protected (EIP-155) transactions allowed over RPC'} 需要指定chainId
# HTTPProvider: HTTP  104.233.213.35=goerli 要用RPC http

#== 注意：goerli链的chainId=5，xdai链的chainId=100 （通过小狐狸可以查到）
#== xdai是xdai链上的一个ERC20代币；

#通过私钥创建一个账号
my_acct=w3.eth.account.privateKeyToAccount('xxxxxxx')
dir(my_acct)
'''

#==== 公用变量 =========

#ABI接口文档：ERC20-ABI.json 来自 https://gist.github.com/veox/8800debbf56e24718f9f483e1e40c35c
ERC20_ABI_file = "ERC20-ABI.json"

#=== 让linux 正确显示中文 
def d_c(msg):
    return msg.encode("utf-8").decode("latin1")
    
#ERC20合约对象
class ERC20():
    '''
contract ERC20 {
 //**********9个函数*******
 //1.代币的名字，如："黑马币"
 function name() constant public returns (string name);
 //2.代币的简称，例如：HMB
 function symbol() public constant returns (string symbol);
 //3.代币的最小分割量 token使用的小数点后几位。比如如果设置为3，就是支持0.001表示
 function decimals() public constant returns (uint8 decimals);
 //4.token的总量
 function totalSupply() public  constant returns (uint totalSupply);
    
 //5.余额 返回某个地址(账户)的账户余额
 function balanceOf(address _owner) public constant returns (uint balance);

 /*6.转账 交易代币 从消息发送者账户中往_to账户转数量为_value的token，
     从代币合约的调用者地址上转移 _value的数量token到的地址 _to
     【注意：并且必须触发Transfer事件】*/
 function transfer(address _to, uint _value) public returns (bool success);

 /*7.两个地址转账
    从账户_from中往账户_to转数量为_value的token，与approve方法配合使用
    从地址 _from发送数量为 _value的token到地址 _to
    【注意：并且必须触发Transfer事件】
    transferFrom方法用于允许合约代理某人转移token。条件是from账户必须经过了approve。*/
 function transferFrom(address _from, address _to, uint _value) public returns (bool success);

 //8.批准_spender能从合约调用账户中转出数量为_value的token
 function approve(address _spender, uint _value) public returns (bool success);
 //9.获取_spender可以从账户_owner中转出token的剩余数量
 function allowance(address _owner, address _spender) public constant returns (uint remaining);

 //**********2个事件*******
 //1.发生转账时必须要触发的事件,transfer 和 transferFrom 成功执行时必须触发的事件
 event Transfer(address indexed _from, address indexed _to, uint _value);
 //2.当函数 approve(address _spender, uint256 _value)成功执行时必须触发的事件
 event Approval(address indexed _owner, address indexed _spender, uint _value);
}
    '''
    contract = None
    address = d_c("代币合约地址")
    name = d_c("代币名称")
    symbol = d_c("代币符号")
    decimals = d_c("代币小数点位数，代币的最小单位")
    totalSupply = d_c("发行代币总量")
    
    #=== 获取指定代币的 余额
    def Get_ERC20_Balance(add):
        if ERC20.contract:
            return ERC20.contract.functions.balanceOf(add).call()
        else:
            return d_c("ERC20代币合约对象没创建")

#==== 补0齐64位 === (没用上)
def addPreZero(msg):
    msg_len = len(msg)
    re_msg = ''
    for i in range(msg_len,64):
        re_msg = re_msg + '0'
    return re_msg+msg


#==== 读取文件为list ==
def Read_List_file(filename,check_again=True):
    try:
        f = open(filename,'r',encoding='utf-8') 
        file_context = f.read() # 独立一个string,采用了ut
        f.close()
        #print(file_context)
        f_list = file_context.splitlines()  #splitlines() 按照行('\r', '\r\n', \n')分隔，返回一个包含各行作为元素的列表
        #print(f_list)        
        if(check_again):
            from collections import Counter #引入Counter
            c_again = dict(Counter(f_list))                    
            #print([key for key,value in c_again.items()if value > 1])       #只展示重复元素
            #print('显示重复元素和重复次数：')
            print({key:value for key,value in c_again.items()if value > 1}) #展现重复元素和重复次数
            # 剔除重复
            list_len = len(f_list)
            f_list = sorted(set(f_list),key=f_list.index)
            if(list_len>len(f_list)):
                Save_ALL_FILE(f_list,filename,True)
        return f_list
    except IOError:
        print(d_c('读取不到文件：')+filename)
        sys.exit(0)


#=== 获取指定地址的 XDAI 余额 == (可不用)
def Get_main_Balance(add,Web3,rpc_url='http://xdai.anybee:8545'):
    if(not Web3.isAddress(add)):
        return add+d_c(" 不是有效地址，无法查询XDAI余额")
        
    cmd = 'curl -s -i '+rpc_url+ ' -H "Content-Type: application/json" -X POST --data '
    cmd +='\'{"jsonrpc":"2.0","method":"eth_getBalance","params":["'+add+'","latest"],"id":1}\' | grep \'jsonrpc\''
    #print(cmd)
    result = json.loads(os.popen(cmd).read())
    #print(result)
    balance = result.get('result','')
    if (balance==''):
        balance = str(result.get('error',''))
    else:
        balance = Web3.toInt(hexstr=balance)     #hex 转 INT
        balance = Web3.fromWei(balance,'ether') #转为ether个数(也就是xdai个数)
    return balance


#=== 获取指定ERC20代币信息
def Get_ERC20(contract_add,w3,ERC20_ABI_file):
    if(not Web3.isAddress(contract_add)):
        return contract_add + d_c("不是有效代币合约地址！\n")
        
    if not os.path.isfile(ERC20_ABI_file):
        print(d_c("ABI文件不存在：")+ERC20_ABI_file)
        return False
        
    with open(ERC20_ABI_file, 'r') as abi_definition:
        ABI = json.load(abi_definition)
    # 获取合约对象
    contract = w3.eth.contract(address=contract_add,abi=ABI)
    ERC20.contract = contract
    ERC20.address = contract.address
    ERC20.name = contract.functions.name().call()
    ERC20.symbol = contract.functions.symbol().call()
    ERC20.decimals = contract.functions.decimals().call()
    ERC20.totalSupply = contract.functions.totalSupply().call()/(10 ** ERC20.decimals)
    # 输出该合约可以调用的所有函数
    contract.all_functions() 
    
    
#=== 获取合约对象，并显示所有方法
def Get_contract(contract_add,w3,ABI_file):
    if(not Web3.isAddress(contract_add)):
        print(contract_add + d_c("不是有效代币合约地址！\n"))
        return False
        
    if not os.path.isfile(ABI_file):
        print(d_c("ABI文件不存在：")+ABI_file)
        return False
        
    with open(ABI_file, 'r') as abi_definition:
        ABI = json.load(abi_definition)
    # 获取合约对象
    contract = w3.eth.contract(address=contract_add,abi=ABI)
    #contract = w3.eth.contract(abi=xxxx, bytecode=xxx)
    # 显示对象所有信息
    dir(contract)
    # 输出该合约可以调用的所有函数
    contract.all_functions() 
    return contract


#=== 创建连接、获取转出地址 主币 和 ERC20 代币余额
def Get_w3_balance(rpc_url,from_Address,bzz_contract_address,ERC20_ABI_file):
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    if(w3.isConnected()):
    
        # 获取转出地址的余额 
        if(Web3.isAddress(from_Address)):            
            main_Balance = w3.eth.get_balance(from_Address) 
            print(d_c("转出地址主币的余额"),main_Balance,'\n')
        else:
            print(d_c("转出地址不正确：")+from_Address,'\n')
            sys.exit(0)
            
        # 获取BZZ所有信息, 判断是否为合约地址
        if(Web3.isChecksumAddress(bzz_contract_address)):
            Get_ERC20(bzz_contract_address,w3,ERC20_ABI_file)
            print(d_c("ERC20代币信息\n"),ERC20.address,ERC20.name,ERC20.symbol,ERC20.decimals,ERC20.totalSupply,'\n')
            erc20_Balance = ERC20.Get_ERC20_Balance(from_Address)
            print(d_c("转出地址ERC20代币的余额"),erc20_Balance,'\n')
        else:
            print(d_c("退出！ERC20代币合约地址不正确：")+bzz_contract_address)
            sys.exit(0)
    else:
        print(d_c("web3 RPC连接失败！退出！"))
        sys.exit(0)
        
    return w3,main_Balance,erc20_Balance


#==== 获取gas费价格：人工设置、是否用人工设置
def Get_gasPrice(w3,set_gas=0,mode=True):
    gasPrice = w3.eth.gasPrice 
    print(d_c('默认的gas价格='),gasPrice)
    if(mode and set_gas!=0):
        gasPrice = Web3.toWei(set_gas,'gwei')
        print(d_c('设置的gas价格='),gasPrice)
    return gasPrice


#=== 获取转账的数量（整数）
def Get_value(ToAmount,send_main,ERC20):
    if send_main :
        value = Web3.toWei(ToAmount,'ether')
    else:
        value = int(ToAmount*10**ERC20.decimals)
    print(d_c('\n转账wei='),value)
    return value


if __name__== "__main__":
    
    #============== 运行 配置参数 ==================
    chain = "xdai"
    chain = "goerli"
    
    if (chain == "xdai") :
        rpc_url = 'http://xdai.anybee:8545'  #对应网络的RPC
        chainId = 100   #网络ID xdai=100  goerli=5
        #转出地址
        from_Address = Web3.toChecksumAddress('0x36952604eD7130f030f17186ee0f30eA3d4A1cf1')
        #私钥
        private_key = 'xxxxxxxxxxxxxxxxxx'
        #代币地址
        bzz_contract_address = Web3.toChecksumAddress('0xdBF3Ea6F5beE45c02255B2c26a16F300502F68da')
    elif (chain == "goerli") :
        rpc_url = "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161" #"http://104.233.213.35:8545" 
        chainId=5
        from_Address = Web3.toChecksumAddress('0xaA04BA59FE991252E79Bd31790Ab468b846303f4')
        private_key = 'xxxxxxxxxxxxxxxxxx'
        bzz_contract_address = Web3.toChecksumAddress('0x2ac3c1d3e24b45c6c310534bc2dd84b5ed576335')
    else:
        print(d_c('\n选择的区块链网络不存在，退出！'))
        sys.exit(0)

    # 转主币的文件，# 转ERC20代币的文件
    send_main_FILE = 'send_main.txt'    
    send_erc20_FILE = 'send_erc20.txt'    
    # 转币前是否对收币地址进行检查
    to_add_bal_check = False
    
    # 设置转账的gas费价格（可通过小狐狸钱包转币测试获得）
    set_gas = 2
    # 当前是转主币、还是代币
    send_main = False
    
    #================================================
    
    #转出地址的 主币余额、ERC20代币余额
    w3,main_Balance,erc20_Balance = None,0,0
    send_add_list = []
    send_ok_list = []
    send_ng_list = []
    send_ov_list = []
    old_nonce = 0
    
    #==== 确定RPC连接、BZZ代币合约、转出地址 余额 ==
    w3,main_Balance,erc20_Balance = Get_w3_balance(rpc_url,from_Address,bzz_contract_address,ERC20_ABI_file)
       
    #===获取当前的 用于交易的gas价格
    gasPrice = Get_gasPrice(w3,set_gas)

    #=============== 读取文件开始批量转 ==================
    if send_main :
        send_file = send_main_FILE
        print(d_c('\n开始批量转网络主币...'))
    else:
        send_file = send_erc20_FILE
        print(d_c('\n开始批量转网络ERC20代币...'))
        
    if not os.path.isfile(send_file):
        print(d_c("\n批量转币的文件不存在：")+send_file)
        sys.exit(0)
    else:
        send_add_list = Read_List_file(send_file)
        #print(send_add_list)
    
    atid = 0
    for send_add in send_add_list:
        atid += 1
        print(atid)
        send_add = send_add.split(',')
        if (Web3.isAddress(send_add[0])):
            to_Address = Web3.toChecksumAddress(send_add[0])
            ToAmount = float(send_add[1])
        else:
            print(d_c("\n收币地址不正确：")+send_add[0])
            sys.exit(0)

        #获取输入转账金额、整数
        value = Get_value(ToAmount,send_main,ERC20)           

        #== 确定要转的币数量是否够
        if (send_main and main_Balance<=value) or (not send_main and erc20_Balance<value):
            if send_main:
                print(d_c("\n 转出主币的数量不够！")+str(main_Balance)+" <= "+str(value))
            else:
                print(d_c("\n 转出代币的数量不够！")+str(erc20_Balance)+" < "+str(value))
            send_ng_list.append(send_add)
            continue
        
        #=== 确定接收地址是否已经转币
        if to_add_bal_check :
            if send_main:
                to_Bal = w3.eth.get_balance(to_Address)
                if to_Bal>0 :
                    print(d_c("\n "+to_Address+" 地址已有币 = ")+str(to_Bal))
                    send_ov_list.append(send_add)
                    continue
            else:
                to_Bal = ERC20.Get_ERC20_Balance(to_Address)
                if to_Bal>0 :
                    print(d_c("\n "+to_Address+" 地址已有币 = ")+str(to_Bal))
                    send_ov_list.append(send_add)
                    continue
                    
       #===获取转出地址的交易nonce #以太坊所有的交易都是基于account的，不同于基于utxo的比特币，因此需要对每次交易都按顺序记录，nonce值就是这个顺序，主要用来防止重放攻击。
        #每发起一笔交易，nonce就会加一        #发起转账或者创建合约的时候，通过web3从以太坊网络查询当前的nonce（ethGetTransactionCount）值，使用此值作为当前交易的nonce值，发送到以太坊网络即可
        #交易队列只保存最多64个从同一个账户发出的交易        #如果发起一笔交易，但是因为gwei比较低或者网络比较忙的时候，该交易还没矿工挖出，可以通过使用相同的nonce和较高的gas费用，从而“覆盖”前一笔交易；
        nonce = w3.eth.getTransactionCount(from_Address)
        while(old_nonce==nonce):
            time.sleep(2)
            nonce = w3.eth.getTransactionCount(from_Address)
        old_nonce = nonce
        print("nonce =",nonce)
        
        if send_main :            
            #估算转账所需要的gas费用，为交易提供的最大gas。
            #gas = w3.eth.estimate_gas({'from':from_Address,'to': to_Address,'value': value})
            gas = 21000 #转账的gas都是最大21000
            print(d_c("预计转账gas数量="),gas)
            data = ""
            
        else: #// data的组成，由：0x + 要调用的合约方法的function signature a9059cbb + 要传递的方法参数，每个参数都为64位(对transfer来说，第一个是接收人的地址去掉0x，第二个是代币数量的16进制表示，去掉前面0x，然后补齐为64位)
            data = ERC20.contract.encodeABI("transfer",args=[to_Address,value])
            #print(data)
            #gas = w3.eth.estimate_gas({'from':from_Address,'to': ERC20.address,'value': 0,'data':data})
            gas = 90000 #调用合约使用gas最大量是 90000
            print(d_c("\n预计转账gas数量="),gas)
            to_Address = ERC20.address # 注意：toAddress改为合约地址
            value = 0  # 转账数量已写入data，主币转数量为0

        #=== 完成转账信息组合
        transaction = {'from':from_Address,'to':to_Address,'nonce':nonce,'gasPrice':gasPrice,'gas':gas,'value': value,'data':data,'chainId': chainId}
        print("")
        print(transaction)
        print("")

        #===对交易信息签名
        try:
            signed_txn = w3.eth.account.sign_transaction(transaction,private_key)
            #print(signed_txn)                
        except Exception as e:
            print(d_c("\n 转币前签名发生错！"),e)
            send_ng_list.append(send_add)
            continue

        #===发送已签名和序列化的交易; #转换Hex格式交易哈希
        try:
            txn_hash = Web3.toHex(w3.eth.send_raw_transaction(signed_txn.rawTransaction))
            print(d_c("\n 转币成功！交易哈希值= "),txn_hash)            
        except Exception as e:
            print(d_c("\n 提交转币发生错！"),e)
            send_ng_list.append(send_add)
            continue
        
        #===查看交易哈希的结果
        txn_receipt = None
        count = 0
        while txn_receipt is None and (count < 60):
            try:
                txn_receipt = w3.eth.getTransactionReceipt(txn_hash)
            except:
                txn_receipt = None
            time.sleep(5)
        if txn_receipt is None:
            print(d_c("\n 交易哈希无结果，超时错误！"))
            send_ng_list.append(send_add)
            continue
        else:
            send_ok_list.append(send_add)
        print(d_c("交易成功！"),txn_receipt)
        print("")

    
    print(d_c("\n===== 所有转币已完成！======"))
    print(d_c("\n 总数量："),len(send_add_list))
    print(d_c("\n 成功数量："),len(send_ok_list))
    print(d_c("\n 失败数量："),len(send_ng_list))
    if len(send_ng_list)>0:
        print(send_ng_list)
    if to_add_bal_check :
        print(d_c("\n 已有币数量："),len(send_ov_list))
        if len(send_ov_list)>0:
            print(send_ov_list)


