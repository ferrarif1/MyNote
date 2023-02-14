import 'package:coinstart_wallet_extension/controller/eth_service.dart';
import 'package:coinstart_wallet_extension/controller/networks.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart';
import 'package:neveruseless/neveruseless.dart';
import 'package:ones/ones.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/eth_api.dart';
import 'contract_parser.dart';

class ContractLocator {
  ContractLocator._();

  //chainId - ContractService
  static Map<int, ContractService> instance = <int, ContractService>{};

  static Future<ContractLocator> setup() async {
    for (final chainId in ChainId.values) {
      print("chainId");
      print(chainId);
      instance[chainIdvalues[chainId.index]] = await createInstance(networkConfig[chainId]!);
    }

    print('setup');
    print(instance);
    return ContractLocator._();
  }

  static ContractService getInstance(int chainId) {
    print(instance);
    return instance[chainId]!;
  }


  static Future<ContractService> getCurrentInstance() async {
    var network = await neverLocalStorageRead('network');
    var currentNetwork = networks[network != 'null' ? network.toString().toInt() : 0];
    return instance[chainIdvalues[currentNetwork.chainId.index]]!;
  }

  static Future<ContractService> createInstance(NetworkType networkConfig) async {
    final wsAddress = networkConfig.web3RdpUrl;
    final client = Web3Client(networkConfig.rpcUrls[0], Client(),
        socketConnector: wsAddress != null
            ? () {
                if (kIsWeb) return WebSocketChannel.connect(Uri.parse(wsAddress)).cast<String>();

                return IOWebSocketChannel.connect(wsAddress).cast<String>();
              }
            : null);
    // String contractAddress = '';
    String contractAddress = '0x3B4c8de78c34773f5A1A656691734641f99066A1';
    // final contract = await ContractParser.fromAssets('TargaryenCoin.json', contractAddress);
    final contract = await ContractParser.fromAssets('TargaryenCoin.json', contractAddress);
    // final contract = null;
    return ContractService(client, contract);
  }
}
