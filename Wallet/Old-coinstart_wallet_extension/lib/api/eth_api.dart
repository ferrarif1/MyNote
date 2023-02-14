// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';


/*
Doc:
https://docs.infura.io/infura/networks/ethereum/json-rpc-methods
*/
const InfuraAPIKey = 'a907d61f8a2b4577b0608501d8f1133c'; //100000 times per day
/*
Doc:
https://docs.bscscan.com/
*/
const BscscanAPIKey = '7D3WYRPK7BSUXSG7UNZJVFFKN2DGNM6FN3'; //API calls per second: 5 calls


/*
1.目前用了这个：https://kaikas.cypress.klaytn.net:8651 可能不需要APIkey
Doc：https://docs.klaytn.foundation/dapp/json-rpc
2.其他API Provider：
Doc:
https://refs.klaytnapi.com/ko/wallet/latest
BaseUrl:
//https://node-api.klaytnapi.com/v1/klaytn https://public-node-api.klaytnapi.com/v1/cypress
Example:
provider: () => {
        const options = {
          headers: [
            { name: 'Authorization', value: 'Basic ' + Buffer.from(kasAccessKeyId + ':' + kasSecretAccessKey).toString('base64') },
            { name: 'x-chain-id', value: '8217' }
          ],
          keepAlive: false,
        }
        return new KlaytnHDWalletProvider(klaytnPrivateKey, new Caver.providers.HttpProvider("https://node-api.klaytnapi.com/v1/klaytn", options))
*/
const KlayAccessKeyId = 'KASK0PCPBLK1NV101Q78NHPY';
const KlaySecretAccessKey = 'JamPwiKtQjLxWkqgYxeqStHPgWFg1HbmFMo6dLO7';
const KlayAuthorization = 'Basic S0FTSzBQQ1BCTEsxTlYxMDFRNzhOSFBZOkphbVB3aUt0UWpMeFdrcWdZeGVxU3RIUGdXRmcxSGJtRk1vNmRMTzc=';
/*
Doc: 
https://docs.alchemy.com/reference/eth-gettransactionreceipt-astar
*/
const AstarAPIKey = 'L0fdYpz3jMIn2WVTpldyHAju21PvfPR8';

enum ChainId {
  // ignore: constant_identifier_names
  ETHMAINNET,
  GOERLI,
  BSC,
  BSCTEST,
  POLYGON,
  KLAYTN,
  KLAYTN_BAOBAB,
  AstarMainnet,
}

var chainIdvalues = [1, 5, 56, 97, 1001, 137, 8217, 592];

ChainId currentChainId = ChainId.ETHMAINNET;
int currentChainIdValue = chainIdvalues[currentChainId.index];

class ETHApi {
  //untils
  

   //request balance


   //request txids

   //request txdetail
   
   //request tx
   

  //build transaction 

  //send raw transaction



}


/*
Docs:



klaytnapi: 
*/
class NetworkType {
  final String chainId;
  final String chainName;
  final String symbol;
  final int decimals;
  final String? web3RdpUrl;
  List<String> rpcUrls;
  List<String> blockExplorerUrls;
  NetworkType(
      {required this.chainId,
      required this.chainName,
      required this.symbol,
      required this.decimals,
      this.web3RdpUrl,
      required this.rpcUrls,
      required this.blockExplorerUrls});
}

final networkConfig = {
  ChainId.ETHMAINNET : NetworkType(
      chainId: '0x1',
      chainName: 'Ethereum',
      symbol: 'ETH',
      decimals: 18,
      web3RdpUrl: 'ws://mainnet.infura.io/ws/v3/a907d61f8a2b4577b0608501d8f1133c',
      rpcUrls: ['https://mainnet.infura.io/v3/a907d61f8a2b4577b0608501d8f1133c'],
      blockExplorerUrls: ['https://etherscan.com/']),
  ChainId.GOERLI : NetworkType(
      chainId: '0x5',
      chainName: 'Goerli',
      symbol: 'ETH',
      decimals: 18,
      rpcUrls: ['https://goerli.infura.io/v3/a907d61f8a2b4577b0608501d8f1133c'],
      blockExplorerUrls: ['https://goerli.etherscan.io/']),
  ChainId.BSC : NetworkType(
      chainId: '0x38',
      chainName: 'Binance Smart Chain',
      symbol: 'BNB',
      decimals: 18,
      rpcUrls: ['https://bsc-dataseed.binance.org/7D3WYRPK7BSUXSG7UNZJVFFKN2DGNM6FN3'],
      blockExplorerUrls: ['https://bscscan.com/']),
  ChainId.BSCTEST : NetworkType(
      chainId: '0x61',
      chainName: 'Binance TEST Chain',
      symbol: 'BNB',
      decimals: 18,
      rpcUrls: ['https://data-seed-prebsc-1-s1.binance.org:8545/7D3WYRPK7BSUXSG7UNZJVFFKN2DGNM6FN3'],
      blockExplorerUrls: ['https://testnet.bscscan.com/']),
  ChainId.KLAYTN_BAOBAB : NetworkType(
      chainId: '0x3e9',
      chainName: 'Klaytn Baobab',
      symbol: 'KLAY',
      decimals: 18,
      rpcUrls: ['https://api.baobab.klaytn.net:8651/'],
      blockExplorerUrls: ['https://baobab.scope.klaytn.com/']),
  ChainId.KLAYTN : NetworkType(
      chainId: '0x2019',
      chainName: 'Klaytn Mainnet',
      symbol: 'KLAY',
      decimals: 18,
      rpcUrls: ['https://kaikas.cypress.klaytn.net:8651'], 
      blockExplorerUrls: ['https://scope.klaytn.com/']),
  ChainId.POLYGON : NetworkType(
      chainId: '0x89',
      chainName: 'Polygon',
      symbol: 'MATIC',
      decimals: 18,
      rpcUrls: ['https://polygon-mainnet.infura.io/v3/a907d61f8a2b4577b0608501d8f1133c'],
      blockExplorerUrls: ['https://polygonscan.com/']),
  ChainId.AstarMainnet : NetworkType(
      chainId: '0x250',
      chainName: 'Astar Mainnet',
      symbol: 'ASTR',
      decimals: 18,
      rpcUrls: ['https://astar-mainnet.g.alchemy.com/v2/L0fdYpz3jMIn2WVTpldyHAju21PvfPR8'],
      blockExplorerUrls: ['https://blockscout.com/astar'])
};
