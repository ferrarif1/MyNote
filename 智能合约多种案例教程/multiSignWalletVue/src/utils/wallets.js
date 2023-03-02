import web3 from "web3";
import { ethers } from 'ethers';
import { ABI } from './abi/abi';

// const currentProvider = new web3.providers.HttpProvider('http://localhost:8545');
// const provider = new ethers.providers.Web3Provider(currentProvider);

let provider;
let etherScanProvider;
// 地址来自上面部署的合约
let contractAddress = "0xF7137Bb94A6a00659355d5eB7a67baD32a218C9e"
let walletAddress = "";

// TODO 连接浏览器钱包
export async function ConnectWallet() {
      // 判断小狐狸MetaMask是否安装
      if (window.ethereum) {
        provider = new ethers.providers.Web3Provider(window.ethereum);
        etherScanProvider = new ethers.providers.EtherscanProvider();
        // 启动小狐狸连接页面
        await window.ethereum.enable().then((res) => {
          // 获取连接的钱包的用户地址，默认取第一个地址
          walletAddress = res[0]
          console.log("当前钱包res：" + res);
        });
      } else {
            alert("请安装MetaMask钱包")
      }
}

// TODO 获取用户地址
export async function getWalletAddress() {
  // 防止钱包切换了地址
  await ConnectWallet()
  console.log("当前钱包walletAddress：", walletAddress);
  return walletAddress
}

// TODO 获取钱包的ETH金额
export async function getEthAmount(address) {
      console.log("获取ETH，金额地址：",address)
      // we use the code below to convert the balance from wei to eth
      let balance = await provider.getBalance(address);
      balance = ethers.utils.formatEther(balance);
      return balance
}
// TODO 查询区块高度
export async function getBlockNumber() {
      let height = 0
      await provider.getBlockNumber().then((res) => {
            height = res;
      });
      console.log(height);
      return height;
}

// TODO 根据区块的hash或者高度进行查询
export async function getBlock(h) {

      let blockInfo
      try{
        if (h.length < 60)
          h = parseInt(h);
        await provider.getBlock(h).then((block) => {
          blockInfo = block;
        });
        console.log(blockInfo);
      }catch (e) {
        alert(e)
      }
      return blockInfo;
}

// TODO 统计地址账户交易的次数
export async function getTransactionCount(address) {

      let count=0
        await provider.getTransactionCount(address).then((transactionCount) => {
        count =  transactionCount
        console.log("发送交易总数: " + transactionCount);
      });
      await scanAccount();
      console.log(count);
      return count;
}

// TODO 扫描账号交易数据
export async function scanAccount() {
  walletAddress = await getWalletAddress()
  console.log("扫描地址" ,walletAddress);
  let txList = []
  // Getting the transaction history of an address
  await etherScanProvider.getHistory(walletAddress).then(function(history) {
    console.log("交易历史，history",history);
    history.forEach((tx)=>{
      txList.push(tx)
      console.log("交易历史，tx",tx);
    })
  });
  console.log(txList);
  // console.log(res);
  return txList;
}

// TODO 根据交易HASH获取该笔交易的详情
export async function getTransactionInfo(hash) {

      let transaction
      await provider.getTransaction(hash).then((TransactionResponse) => {
        transaction =  TransactionResponse
        console.log("交易: " + transaction);
      });

      console.log(transaction);
      return transaction;
}
// TODO 签名交易数据
export async function signMessage(msg) {
      // 由于前端传进来的是字符串，需要将字符hex进行编码
      let binaryData = ethers.utils.arrayify(msg);
      let signHex = []
      // 进行签名
      await provider.getSigner().signMessage(binaryData).then((hex) => {
        signHex.push(hex)
        console.log("签名后的hex: " + signHex);
      });
      console.log(signHex);
      return signHex[0];
}


// TODO 合约操作-连接合约
export async function getContract() {
  // 使用Provider 连接合约，将只有对合约的可读权限
  try {
    let contract = new ethers.Contract(contractAddress, ABI, provider.getSigner());
    console.log(contract)
  } catch (e) {
    alert(e.toString())
  }
}

// TODO 合约操作-编码交易数据
export async function encodeTransactionData(to, value, data, _nonce, tx_type, chainId) {
  try {
    let contract = new ethers.Contract(contractAddress, ABI, provider.getSigner());
    let hex = await contract.encodeTransactionData(to, value, data, _nonce, tx_type, chainId)
    return hex
  } catch (e) {
    alert(e.toString())
    return ""
  }
}

// TODO 合约操作-检查编码签名是否可以执行
export async function checkSignatures(dataHash, signatures) {
  let contract = new ethers.Contract(contractAddress, ABI, provider.getSigner());
  try {
    await contract.checkSignatures(dataHash, signatures)
    return true
  } catch (e) {
    alert(e.toString())
    return false
  }
}

// TODO 合约操作-执行交易数据
export async function execTransaction(to, value, data, tx_type, signatures) {

  try {
    let contract = new ethers.Contract(contractAddress, ABI, provider.getSigner())
    let res = await contract.execTransaction(to, value, data, tx_type, signatures)
    console.log(res)
    return true
  } catch (e) {
    alert(e.toString())
    return false
  }
}

// TODO 合约操作-ETH转账给合约
// 会员注册
export async function registeredMember(_to,amount,eth) {
  // 使用Provider 连接合约，将只有对合约的可读权限
  try {
    await ConnectWallet()
    walletAddress = await getWalletAddress()
    let contract = new ethers.Contract(contractAddress, ABI, provider.getSigner());
    const options = {value: ethers.utils.parseEther(eth)}
    const reciept = await contract.registeredMember(_to, amount,options);
    console.log(reciept)
    return reciept
  } catch (e) {
    if (e.data !==undefined){
      alert(e.data.message)
    }else {
      alert(e)
    }
    return undefined;
  }
}

// TODO 合约操作-会员的注册配置
// 注册配置
export async function setVipConf(s,h) {
  // 使用Provider 连接合约，将只有对合约的可读权限
  try {
    await ConnectWallet()
    walletAddress = await getWalletAddress()
    console.log("用户地址",walletAddress)
    let contract = new ethers.Contract(contractAddress, ABI, provider.getSigner());
    await contract.setVipConf(s,h);
    return true
  } catch (e) {
    if (e.data !==undefined){
      alert(e.data.message)
    }else {
      alert(e)
    }
    return false
  }
}

// TODO 合约操作-会员的Token解冻
// 会员的Token解冻
export async function thawAmount() {
  // 使用Provider 连接合约，将只有对合约的可读权限
  try {
    await ConnectWallet()
    walletAddress = await getWalletAddress()
    let contract = new ethers.Contract(contractAddress, ABI, provider.getSigner());
    await contract.thawAmount();
    return true
  } catch (e) {
    if (e.data !==undefined){
      alert(e.data.message)
    }else {
      alert(e)
    }
    return false
  }
}
