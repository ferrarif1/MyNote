var Web3 = require('web3');
var provider = new Web3.providers.HttpProvider("http://119.23.219.232:9933");
var web3 = new Web3(provider);
const InputDataDecoder = require('ethereum-input-data-decoder');
var json = require("../build/contracts/XunWenGe.json");
const decoder = new InputDataDecoder(json['abi']);

async function SignAndSendTx(tx, privateKey) {
    const signPromise = web3.eth.accounts.signTransaction(tx, privateKey);
    const res = await signPromise.then((signedTx) => {
        return web3.eth.sendSignedTransaction(
            signedTx.rawTransaction,
            function (err, hash) {
                if (!err) {
                     hashs = hash;
                    console.log("transaction hash is: ", hash)
                } else {
                    console.log("transaction wrong :", err)
                }
            }
        )
    }).catch((err) => {
        console.log(" Promise failed:", err)
    })

    return res.transactionHash;
}

async function getTxByHash(hash,index) {
    const res = await web3.eth.getTransaction(hash);
    console.log("从交易地址获取数据",res);
    const result = decoder.decodeData(res["input"]);
    
    // console.log("decoder res ===> ",resres_str_1ult);
    //从交易地址获取数据
    let inputData = result["inputs"][0][index];
    const res_str_1 = decoder.decodeData(inputData);
    console.log(res_str_1);
    
    let res_str = Buffer.from(inputData.toString().replace('0x',''),'hex').toString();
    // let res_json = JSON.parse(res_str);
    // console.log(res_json);

    // console.log("res_str",res_str);
    const receipt = await web3.eth.getTransactionReceipt(hash);
    // console.log("getTransactionReceipt",receipt);
    return res_str
}

// hex转json字符串,16进制ASCII
var hextoString = function (hex) {
    console.log("hex",hex);
    var arr = hex.split("")
    var out = ""
    console.log("arr",arr);
    for (var i = 0; i < arr.length / 2; i++) {
        console.log("arr[i * 2]",arr[i * 2]);
        console.log("arr[i * 2 + 1]",arr[i * 2 + 1]);
        var tmp = "0x" + arr[i * 2] + arr[i * 2 + 1]
        var charValue = String.fromCharCode(tmp);
        out += charValue
    }
    return out
};

// 16进制转字符串
function hex2str(hex) {
    var trimedStr = hex.trim();
    var rawStr = trimedStr.substr(0, 2).toLowerCase() === "0x" ? trimedStr.substr(2) : trimedStr;
    var len = rawStr.length;
    if (len % 2 !== 0) {
        alert("Illegal Format ASCII Code!");
        return "";
    }
    var curCharCode;
    var resultStr = [];
    for (var i = 0; i < len; i = i + 2) {
        curCharCode = parseInt(rawStr.substr(i, 2), 16);
        resultStr.push(String.fromCharCode(curCharCode));
    }
    return resultStr.join("");
}

// json字符串转hex
var stringtoHex = function (str) {
    var val = "";
    for (var i = 0; i < str.length; i++) {
        if (val == "")
            val = str.charCodeAt(i).toString(16);
        else
            val += str.charCodeAt(i).toString(16);
    }
    val += "0a"
    return val
}



module.exports = {
    SignAndSendTx,
    hextoString,
    stringtoHex,
    hex2str,
    getTxByHash
};
  