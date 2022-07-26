
var Wallet = require('ethereumjs-wallet')
const fs = require('fs');

for(var i = 0; i <= 50; i++){
    const EthWallet = Wallet.default.generate(false);

    const addressALL = EthWallet.getAddressString();
    const addr = addressALL + "\n";
    console.log("address: " + EthWallet.getAddressString());

    const privateKeyALL = EthWallet.getPrivateKeyString();
    const pKey = privateKeyALL + "\n";
    console.log("privateKey: " + EthWallet.getPrivateKeyString());

    fs.appendFile('address.txt', addr, (err) => {
        if (err) throw err;
        console.log('追加address');
    });

    fs.appendFile('privateKeyALL.txt', pKey, (err) => {
        if (err) throw err;
        console.log('追加privateKey');
    });
}

