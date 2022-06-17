const assert = require('assert');

const vproxy = artifacts.require('Vproxy');
const v1 = artifacts.require('V1');
const v2 = artifacts.require('V2');

contract('Proxy contract testing', async (accounts) => {
  let vproxyInstance;
  let v1Instance;
  let v2Instance;

  let proxyContractAddress;
  let v1Address;
  let v2Address;

  beforeEach(async () => {
    vproxyInstance = await vproxy.deployed();
    v1Instance = await v1.deployed();
    v2Instance = await v2.deployed();

    proxyContractAddress = await vproxyInstance.getContractAddress();
    v1Address = v1Instance.address;
    v2Address = v2Instance.address;
  })

  it('Address contract in proxy contract should be equa to v1', async () => {
    console.log(1);
    assert.equal(proxyContractAddress, v1Address,'Not equal');
  });

  it("Should be able to get data using Proxy contract", async () => {
    console.log(2);
    const data = await vproxyInstance.getData();
    assert.notEqual(data, null, 'Can not get data');
  })

  it("Should be able to call V1 contract through Proxy contract", async () => {
    console.log(3);
    const vProxyV1Instance = new web3.eth.Contract(v1Instance.abi, proxyContractAddress);
    const res = await vProxyV1Instance.methods.logicCall(9,3).send({from: accounts[0], to: proxyContractAddress});
    const data = res.events.V1LogicCallEvent.returnValues.data;
    //9-3=6
    assert.equal(data, 6, 'Can not call V1 though proxy contract');
  })

  it("Onwer should able to change contract address from V1 to V2", async () => {
    console.log(4);
    await vproxyInstance.updateContractAddress(v2Address);
    const updatedContractAddress = await vproxyInstance.getContractAddress();
    assert.equal(v2Address, updatedContractAddress, 'Falied to update contract address');
  })

  it("Should be able to call V2 contract through Proxy contract", async () => {
    console.log(5);
    const vProxyV2Instance = new web3.eth.Contract(v2Instance.abi, proxyContractAddress);
    const res = await vProxyV2Instance.methods.logicCall(9,3).send({from: accounts[0], to: proxyContractAddress});
    const data = res.events.V2LogicCallEvent.returnValues.data;
    assert.equal(data, 12, 'Can not call V2 though proxy contract');
  })

})