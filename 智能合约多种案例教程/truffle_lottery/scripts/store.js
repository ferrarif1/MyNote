const HelloBlockchain = artifacts.require('HelloBlockchain');
const Lottery = artifacts.require('Lottery');

module.exports = async (callback) => {
  try {
    const helloBlockchain = await HelloBlockchain.deployed();
    const reciept = await helloBlockchain.SendRequest("Hello World");
    console.log(reciept);
    const lottery = await Lottery.deployed();
    const balance = await lottery.getBalance();
    console.log(balance);

  } catch(err) {
    console.log('Oops: ', err.message);
  }
  callback();
};
