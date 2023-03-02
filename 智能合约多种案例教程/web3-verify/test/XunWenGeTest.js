//创建web3对象
var Web3 = require('web3');
var sigUtil = require("eth-sig-util")
var provider = new Web3.providers.HttpProvider("http://127.0.0.1:7545");
var web3 = new Web3(provider);
var {  SignAndSendTx,getTxByHash} = require("./utils")
var json = require("../build/contracts/XunWenGe.json");
var contractAddr = '0x1C95dbA8D229E3D8DAcB65fF137A0D9f38871120';
const keccak256 = require('keccak256');
var account = "0x2cf8Eb3B0DbdA2104c556Fe70b6de3953A55d14f";
var account_to = "0x9115268ce8616fC266C1c7eEaE43025Ef86Abf19";
//签名人的私钥
var privateKey = "a34b3571633428696859962adf0ca17345714de93c8f2cb2f5a8ab35e8d22d98";
var privateKeyHex = Buffer.from(privateKey, 'hex')

// const xunWenGeContract = new web3.eth.Contract(json['abi'], contractAddr);

contract('XunWenGe ', (accounts) => {

    it('Test Mint', async () => {
        // let inputData = "0x7b22626f6f6c65616e223a747275652c22737472696e67223a22737472696e67222c226c697374223a5b312c322c335d2c22696e74223a327d";
        // let res_str = Buffer.from(inputData.toString().replace('0x',''),'hex').toString();
        // let res_json = JSON.parse(res_str);
        // console.log(res_json);
        // await getTxByHash("0x60e5598fa9bb718b8a914796e5e200325fd2567c2049bf14e5480e72f06b62f6",3);
        const descriptionHash = web3.utils.keccak256("TRANSFER");
        const hash = '0x' + keccak256("TRANSFER").toString('hex')
        console.log(hash);
    
    })

    // it('Test Mint', async () => {
    //     const nonce = await web3.eth.getTransactionCount(account, "latest")
    //     let datahex = Buffer.from("100").toString('hex');
    //     datahex = '0x'+datahex;
    //     //the transaction
    //     const tx = {
    //         from: account,
    //         to: contractAddr,
    //         nonce: nonce,
    //         gas: 500000,
    //         data: xunWenGeContract.methods.exchangeMint(["0x9115268ce8616fC266C1c7eEaE43025Ef86Abf19", [0], [10], "0", 0]).encodeABI(),
    //     }
        
    //     // 签名转账
    //     this.hash = await SignAndSendTx(tx, privateKey);

    //     await xunWenGeContract.methods.balanceOf(account, 0).call({ from: accounts[0] }, function (error, result) {
    //         if (error) {
    //             console.log(error);
    //         }
    //         console.log("balanceof:", result);
    //     });
    //     await getTxByHash(this.hash,3);

    // });

    // it('Test distribute Tx', async () => {
    //     const nonce = await web3.eth.getTransactionCount(account, "latest")
    //     let log = {
    //         time:(new Date).getTime(),
    //         type:"error",
    //         msg:"数据库连接失败"
    //     };
    //     let str = JSON.stringify(log);
    //     let datahex = Buffer.from(str).toString('hex');
    //     datahex = '0x'+datahex;
    //     console.log(datahex);

    //     //the transaction
    //     const tx = {
    //         from: account,
    //         to: contractAddr,
    //         nonce: nonce,
    //         gas: 500000,
    //         data: xunWenGeContract.methods.exchangeTransfer(
    //             [
    //                 account, // address from
    //                 account_to, // address to
    //                 [0],    // uint256[] ids     
    //                 [10],   // uint256[] amounts 
    //                 datahex, // bytes data 自定义的数据类型 需要转16进制
    //                 0 // TxEnum txType 类型 0 是给to转账1个序号的nft 类型, 1 是给to转多个序号的NFT 
    
    //             ]
    //         ).encodeABI(),
    //     };
    //     // 签名转账
    //     this.hash = await SignAndSendTx(tx, privateKey);
    //     // 查询余额
    //     // account - 账号地址
    //     // tokenId
    //     await xunWenGeContract.methods.balanceOf(account_to, 0).call({ from: accounts[0] }, function (error, result) {
    //         if (error) {
    //             console.log(error);
    //         }
    //         console.log("balanceof:", result);
    //     });
    //     // 查询交易记录详情
    //     await getTxByHash(this.hash,4);
    // });
})