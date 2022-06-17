# Create Address

## Create an Address <a id="create-an-address_1"></a>

The first thing you’ll need to do anything on the Binance Chain is an account. Each account has a public key and a private key. It is created by a user of the blockchain. It also includes account number and sequence number for replay protection.

Because the private key must be kept secret, you can generate the private key with the following command:

* JavaScript Example

 JavaScript

```text
// generate key entropy
const privateKey = crypto.generatePrivateKey();
// get an address
const address = crypto.getAddressFromPrivateKey(privateKey);

const BnbApiClient = require("@binance-chain/javascript-sdk");
const axios = require("axios");
const bnbClient = new BnbApiClient(api);
const httpClient = axios.create({ baseURL: api });
bnbClient.chooseNetwork("mainnet"); // or this can be "testnet"
bnbClient.setPrivateKey(privKey);
bnbClient.initChain();

const address = bnbClient.getClientKeyAddress();

console.log("address: ", address);
```

 GoLang

```text
//-----   Init KeyManager  -------------
km, _ := NewKeyManager()
//-----   Init sdk  -------------
client, err := sdk.NewDexClient("dex.binance.org", types.TestNetwork, keyManager)  // api string can be "https://testnet-dex.binance.org" for testnet
accn,_:=client.GetAccount(client.GetKeyManager().GetAddr().String())
//-----   Print Address
fmt.Println(accn)
```

 Python

```text
from binance_chain.wallet import Wallet
from binance_chain.environment import BinanceEnvironment

testnet_env = BinanceEnvironment.get_testnet_env(, env=testnet_env)
wallet = Wallet.create_random_wallet(env=env)
print(wallet.address)
```

