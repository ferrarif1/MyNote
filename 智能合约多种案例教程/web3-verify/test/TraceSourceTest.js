//创建web3对象
var Web3 = require('web3');
var provider = new Web3.providers.HttpProvider("http://127.0.0.1:7545");
var web3 = new Web3(provider);
const keccak256 = require('keccak256');

//签名人的私钥
var account = "0x2cf8Eb3B0DbdA2104c556Fe70b6de3953A55d14f";
var privateKey = "a34b3571633428696859962adf0ca17345714de93c8f2cb2f5a8ab35e8d22d98";
var json = require("../build/contracts/TraceSource.json");

var traceSourceContract = new web3.eth.Contract(json['abi'], "0x3DDb4EF0cee1167E900c52A83fa149E8e3DfABdD");

contract('TraceSource', (accounts) => {

    it('Test TraceSource Tx', async () => {
        var res = await forwarderContract.methods.StoreSource("12345")
        console.log(res);
    });
})