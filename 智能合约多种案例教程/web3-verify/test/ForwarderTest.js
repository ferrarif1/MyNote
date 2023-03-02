//创建web3对象
var Web3 = require('web3');
var sigUtil = require("eth-sig-util")
var provider = new Web3.providers.HttpProvider("http://119.23.219.232:9944");
var web3 = new Web3(provider);

var json = require("../build/contracts/MetaTxForwarder.json");
var forwarderContractAddr = '0x645F483704B557625893f18c4ceb8ECdCdF7094F';
var nftContractAddr = '0x3DDb4EF0cee1167E900c52A83fa149E8e3DfABdD';

var account = "0x2cf8Eb3B0DbdA2104c556Fe70b6de3953A55d14f";
var account_to = "0x9115268ce8616fC266C1c7eEaE43025Ef86Abf19";
//签名人的私钥
var privateKey = "a34b3571633428696859962adf0ca17345714de93c8f2cb2f5a8ab35e8d22d98";
var privateKeyHex = Buffer.from(privateKey, 'hex')

var forwarderContract = new web3.eth.Contract(json['abi'], forwarderContractAddr);

contract('MetaTx', (accounts) => {
    
    it('test MetaTxForwarder web3', async () => {
        //获取链ID
        const safeMintABI = [
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "from",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "to",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256[]",
                        "name": "ids",
                        "type": "uint256[]"
                    },
                    {
                        "internalType": "uint256[]",
                        "name": "amounts",
                        "type": "uint256[]"
                    },
                    {
                        "internalType": "bytes",
                        "name": "data",
                        "type": "bytes"
                    }
                ],
                "name": "safeBatchTransferFrom",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "from",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "to",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "id",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    },
                    {
                        "internalType": "bytes",
                        "name": "data",
                        "type": "bytes"
                    }
                ],
                "name": "safeTransferFrom",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
        ]

        var nftContract = new web3.eth.Contract(safeMintABI, nftContractAddr)
        console.log("1");
        const callData = nftContract.methods.safeTransferFrom("0x2cf8Eb3B0DbdA2104c556Fe70b6de3953A55d14f","0x9115268ce8616fC266C1c7eEaE43025Ef86Abf19",1,1,'0x').encodeABI()
        console.log("2");
        const gas = await nftContract.methods.safeTransferFrom("0x2cf8Eb3B0DbdA2104c556Fe70b6de3953A55d14f","0x9115268ce8616fC266C1c7eEaE43025Ef86Abf19",1,1,'0x').estimateGas({ from: "0x2cf8Eb3B0DbdA2104c556Fe70b6de3953A55d14f" })
        console.log("3");
     
        const req = {
            from: "0x2cf8Eb3B0DbdA2104c556Fe70b6de3953A55d14f",
            to: nftContractAddr,
            value: '0',
            gas: gas,
            nonce: await forwarderContract.methods.getNonce("0x2cf8Eb3B0DbdA2104c556Fe70b6de3953A55d14f").call(),
            data: callData,
        }
        console.log("4");
        //V4签名
        const typedData = {
            types: {
                EIP712Domain: [{
                    name: 'name',
                    type: 'string'
                },
                {
                    name: 'version',
                    type: 'string'
                },
                {
                    name: 'chainId',
                    type: 'uint256'
                },
                {
                    name: 'verifyingContract',
                    type: 'address'
                },
                ],
                // Refer to PrimaryType
                ForwardRequest: [{
                    name: 'from',
                    type: 'address'
                },
                {
                    name: 'to',
                    type: 'address'
                },
                {
                    name: 'value',
                    type: 'uint256'
                },
                {
                    name: 'gas',
                    type: 'uint256'
                },
                {
                    name: 'nonce',
                    type: 'uint256'
                },
                {
                    name: 'data',
                    type: 'bytes'
                },
                ],
            },
            domain: {
                // Defining the chain aka Rinkeby testnet or Ethereum Main Net
                chainId: 9090,
                // Give a user friendly name to the specific contract you are signing for.
                name: 'MinimalForwarder',
                // If name isn't enough add verifying contract to make sure you are establishing contracts with the proper entity
                verifyingContract: forwarderContractAddr,
                // Just let's you know the latest version. Definitely make sure the field name is correct.
                version: '0.0.1',
            },
            primaryType: 'ForwardRequest',
            message: req,
        }
        console.log("5");
        //V4签名
        var signature = sigUtil.signTypedData_v4(privateKeyHex, { data: typedData })
        console.log("signature:", signature)

        //V4验签
        const recovered = sigUtil.recoverTypedSignature_v4({
            data: typedData,
            sig: signature,
        });
        console.log("recovered：", recovered)

        //合约V4验
        await forwarderContract.methods.verify(typedData.message,  signature).call({ from: account }, function (error, result) {
            if (error) {
                console.log(error);
            }
            console.log("verify：", result);
        });
    });
})