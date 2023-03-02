const ethSigUtil = require('eth-sig-util');
const Wallet = require('ethereumjs-wallet').default;
const { EIP712Domain } = require('./helpers/eip712');

const { expectRevert, constants } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const { getChainId } = require('./helpers/chainid');

const { ABIJson } = require('./ABIS.js');
const { web3 } = require('hardhat');


const MinimalForwarder = artifacts.require('MetaTxForwarder');
const NFT = artifacts.require('NFT');
// 1155合约
const XunWenGe1155 = artifacts.require('XunWenGe');


const name = 'MinimalForwarder';
const version = '0.0.1';


contract('Forwarder', function (accounts) {
  beforeEach(async function () {
    this.forwarder = await MinimalForwarder.new();
    this.nft = await NFT.new("Zero NFT", "ZN", this.forwarder.address);
    this.xunWenGe = await XunWenGe1155.new(this.forwarder.address);
 
    this.domain = {
      name,
      version,
      chainId: await getChainId(),
      verifyingContract: this.forwarder.address,
    };
    this.types = {
      EIP712Domain,
      ForwardRequest: [
        { name: 'from', type: 'address' },
        { name: 'to', type: 'address' },
        { name: 'value', type: 'uint256' },
        { name: 'gas', type: 'uint256' },
        { name: 'nonce', type: 'uint256' },
        { name: 'data', type: 'bytes' },
      ],
    };
  });

  context('with message', function () {
    beforeEach(async function () {

      this.safeMintABI = [
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

      //签名人的私钥
      this.privateKey = "a34b3571633428696859962adf0ca17345714de93c8f2cb2f5a8ab35e8d22d98";
      this.privateKeyHex = Buffer.from(this.privateKey, 'hex')
      this.from = "0x2cf8Eb3B0DbdA2104c556Fe70b6de3953A55d14f";

      this.wallet = Wallet.generate();
      this.sender = web3.utils.toChecksumAddress(this.wallet.getAddressString());
      
    
      // 铸造
      await this.xunWenGe.exchangeMint([this.from],[0],[10000],0,"0x")
      console.log("余额：",await this.xunWenGe.balanceOf(this.from,0));

      // 构建代理合约转账abi 
      this.xunWenGeContract = new web3.eth.Contract(ABIJson, this.xunWenGe.address)
      this.transferAbi = this.xunWenGeContract.methods.safeTransferFrom(this.from,"0xD24894E29b7365Fd2fc5B30166fE63b7A1320735","0","100","0x").encodeABI()
      console.log("transferAbi", this.transferAbi);

      this.req = {
        from: this.from,
        to: this.xunWenGe.address,
        value: '0',
        gas: '200000',
        nonce: Number(await this.forwarder.getNonce(this.from)),
        data: this.transferAbi,
      };

      this.sign = () =>
        ethSigUtil.signTypedMessage(this.privateKeyHex, {
          data: {
            types: this.types,
            domain: this.domain,
            primaryType: 'ForwardRequest',
            message: this.req,
          },
        });
    });

    context('verify', function () {

      context('valid signature', function () {
        beforeEach(async function () {
          console.log("请求数据: ", this.req);
          expect(await this.forwarder.getNonce(this.req.from)).to.be.bignumber.equal(web3.utils.toBN(this.req.nonce));
        });

        it('success', async function () {
          console.log("签名结果", this.sign());
          const v = await this.forwarder.verify(this.req, this.sign())
          console.log("请求数据: ", this.req.from);
          console.log("测试 success 校验结果: ", v ? "签名通过" : "签名无法通过");
          expect(v).to.be.equal(true);
        });

        afterEach(async function () { });
      });

    //   context('invalid signature', function () {
    //     it('tampered from', async function () {
    //       expect(await this.forwarder.verify({ ...this.req, from: accounts[0] }, this.sign())).to.be.equal(false);
    //     });
    //     it('tampered to', async function () {
    //       expect(await this.forwarder.verify({ ...this.req, to: accounts[0] }, this.sign())).to.be.equal(false);
    //     });
    //     it('tampered value', async function () {
    //       expect(await this.forwarder.verify({ ...this.req, value: web3.utils.toWei('1') }, this.sign())).to.be.equal(
    //         false,
    //       );
    //     });
    //     it('tampered nonce', async function () {
    //       expect(await this.forwarder.verify({ ...this.req, nonce: this.req.nonce + 1 }, this.sign())).to.be.equal(
    //         false,
    //       );
    //     });
    //     it('tampered data', async function () {
    //       expect(await this.forwarder.verify({ ...this.req, data: '0x1742' }, this.sign())).to.be.equal(false);
    //     });
    //     it('tampered signature', async function () {
    //       const tamperedsign = web3.utils.hexToBytes(this.sign());
    //       tamperedsign[42] ^= 0xff;
    //       expect(await this.forwarder.verify(this.req, web3.utils.bytesToHex(tamperedsign))).to.be.equal(false);
    //     });
    //   });

    // });
    
   
    // context('execute', function () {
    //   context('valid signature', function () {
    //     beforeEach(async function () {
    //       expect(await this.forwarder.getNonce(this.req.from)).to.be.bignumber.equal(web3.utils.toBN(this.req.nonce));
    //     });

    //     it('success', async function () {
    //       // expect to not revert
    //       await this.forwarder.execute(this.req, this.sign())
    //     });

    //     afterEach(async function () {
    //       console.log(this.req.from, "余额: " + (await this.xunWenGe.balanceOf(this.req.from)).toString());
    //       console.log("转账后 0x9115268ce8616fC266C1c7eEaE43025Ef86Abf19 余额: ", (await this.xunWenGe.balanceOf("0x9115268ce8616fC266C1c7eEaE43025Ef86Abf19")).toString());
    //       expect(await this.forwarder.getNonce(this.req.from)).to.be.bignumber.equal(
    //         web3.utils.toBN(this.req.nonce + 1),
    //       );
    //     });

    //   });

    //   context('invalid signature', function () {
    //     it('tampered from', async function () {
    //       await expectRevert(
    //         this.forwarder.execute({ ...this.req, from: accounts[0] }, this.sign()),
    //         'MinimalForwarder: signature does not match request',
    //       );
    //     });
    //     it('tampered to', async function () {
    //       await expectRevert(
    //         this.forwarder.execute({ ...this.req, to: accounts[0] }, this.sign()),
    //         'MinimalForwarder: signature does not match request',
    //       );
    //     });
    //     it('tampered value', async function () {
    //       await expectRevert(
    //         this.forwarder.execute({ ...this.req, value: web3.utils.toWei('1') }, this.sign()),
    //         'MinimalForwarder: signature does not match request',
    //       );
    //     });
    //     it('tampered nonce', async function () {
    //       await expectRevert(
    //         this.forwarder.execute({ ...this.req, nonce: this.req.nonce + 1 }, this.sign()),
    //         'MinimalForwarder: signature does not match request',
    //       );
    //     });
    //     it('tampered data', async function () {
    //       await expectRevert(
    //         this.forwarder.execute({ ...this.req, data: '0x1742' }, this.sign()),
    //         'MinimalForwarder: signature does not match request',
    //       );
    //     });
    //     it('tampered signature', async function () {
    //       const tamperedsign = web3.utils.hexToBytes(this.sign());
    //       tamperedsign[42] ^= 0xff;
    //       await expectRevert(
    //         this.forwarder.execute(this.req, web3.utils.bytesToHex(tamperedsign)),
    //         'MinimalForwarder: signature does not match request',
    //       );
    //     });
    //   });

    });
  })
});
