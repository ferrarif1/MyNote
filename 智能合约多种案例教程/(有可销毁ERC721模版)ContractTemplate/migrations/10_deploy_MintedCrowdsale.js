//增发式众筹合约必须在可增发代币基础上构建
const ERC20WithMintable = artifacts.require("ERC20WithMintable");
const MintedCrowdsaleContract = artifacts.require("MintedCrowdsaleContract");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(ERC20WithMintable,
    "My Golden Coin", //代币名称
    "MGC",            //代币缩写
    18,               //精度    
    1000000000        //初始发行量
  ).then((ERC20WithMintableInstance) => {
    return deployer.deploy(MintedCrowdsaleContract,   
      100,                        //兑换比例
      accounts[0],                //接收ETH受益人地址
      ERC20WithMintable.address   //代币地址
    ).then(() => {
      ERC20WithMintableInstance.addMinter(MintedCrowdsaleContract.address);
      ERC20WithMintableInstance.renounceMinter();
    });
  })
};
