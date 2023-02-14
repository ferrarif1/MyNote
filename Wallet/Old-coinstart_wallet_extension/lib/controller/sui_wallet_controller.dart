import 'dart:convert';
import 'dart:math';

import 'package:coinstart_wallet_extension/api/eth_api.dart';
import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/controller/eth_locator.dart';
import 'package:coinstart_wallet_extension/controller/format.dart';
import 'package:coinstart_wallet_extension/controller/json.dart';
import 'package:coinstart_wallet_extension/controller/mnemonic.dart';
import 'package:coinstart_wallet_extension/controller/networks.dart';
import 'package:coinstart_wallet_extension/controller/safe_storage.dart';
import 'package:coinstart_wallet_extension/controller/sui_sdk.dart';
import 'package:coinstart_wallet_extension/main.dart';
import 'package:common_utils/common_utils.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';
import 'package:neveruseless/never/neverLocalStorage.dart';
import 'package:ones/extension/string_ex.dart';
import 'package:web3dart/web3dart.dart';

import '../api/sui_wallet.dart';
/*
包括钱包的创建，私钥导出，交易组装等操作
*/
class SuiWalletController extends GetxController {
  var safeStorage = SafeStorage();
  List<SuiWallet> wallets = [];
  var currentWalletAddress = ''.obs;
  var transactions = [].obs;
  var ownedObjectBatch = [].obs;
  var suiGasDefault = 100;
  int currentWalletIndex = 0;
  var primaryCoinBalance = (0.0).obs;
  var publicAddress = ''.obs;
  var publicAddressFuzzyed = ''.obs;
  var NFTs = [].obs;
  var gasDefault = 0.obs;
  final currentBalance = 0.0.obs;

  final localPwd = "".obs;

  String _pwd = '';
  String _mnemonic = '';
  bool _isWalletInitialized = false;

  set mnemonic(String value) => _mnemonic = value;

  set pwd(String value) => _pwd = value;
  
  SuiWallet? get currentWallet {
    if (hasWallet) {
      if (wallets.length > currentWalletIndex) {
        currentWalletAddress.value = wallets[currentWalletIndex].address.toString();
        return wallets[currentWalletIndex];
      } else {
        currentWalletAddress.value = wallets[0].address.toString();
        return wallets[0];
      }
    }
    return null;
  }

  //index is 0,1,2...
  selectWallet(String key) async {
    neverLocalStorageWrite("NowAddressKey", key);
  }

  initWallet() async {
    // if (!_isWalletInitialized) {
    //   final p = _pwd;
    //   final m = _mnemonic;
    //   _pwd = '';
    //   _mnemonic = '';
    //   await addWallet(m, p);
    // }
    await ContractLocator.setup();
  }
  //aes加密助记词 pwd是用户密码（8位及以上）
  encryptMnemonic(String mnemonic, String pwd) {
    String ss = pwd + pwd + pwd + pwd;//改为key
    final key = Key.fromUtf8(ss.substring(0, 32));
    final iv = IV.fromUtf8(ss.substring(0, 16));

    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(mnemonic, iv: iv);
    // print("en iv = " + iv.toString());
    // print("encrypted = " + encrypted.base64);

    return encrypted.base64;
  }
  //aes解密助记词 pwd是用户密码（8位及以上）
  decryptMnemonic(encmnemonic, String pwd) {
    if (encmnemonic.toString() == "display") {
      encmnemonic = currentWallet?._mnemonic;
    }
    String ss = pwd + pwd + pwd + pwd;
    final key = Key.fromUtf8(ss.substring(0, 32));
    final iv = IV.fromUtf8(ss.substring(0, 16));
    final encrypter = Encrypter(AES(key));

    final decrypted = encrypter.decrypt(Encrypted.from64(encmnemonic), iv: iv);
    return decrypted;
  }
  //导出私钥的接口已经去掉 仅导出助记词
  getPrivateKey(String pwd) {
    return decryptMnemonic(currentWallet?._mnemonic, pwd);
  }
  
  bool get hasWallet {
    return wallets.isNotEmpty;
  }

  get suiBalance => getSuiBalance();
  //获取sui的余额
  getSuiBalance() {
    final balance = currentWalletBalance[coinSuiType] ?? 0;
    // widget.WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   currentBalance.value = balance;
    // });
    return balance;
  }
  //用户登录后将一些参数传往后台
  userlogin(String pwd) async {
    final ipv4 = await Ipify.ipv4();
    var sig = "none sig";
    if (pwd == "") {
      final ipv4 = await Ipify.ipv4();
    } else {
      var bytes = utf8.encode(ipv4); // data being hashed
      sig = await signMsg(bytes, pwd);
    }
    // print(sig);
    await currentWallet?._suiApi?.userLogin(UserData(account: currentWalletAddress.string, memo: ipv4, sign: sig));
  }

  // //decrypt the password input base64 return string
  // Future<String> decryptPassword(String enc) async {
  //   String keystr = await neverLocalStorageRead('secretKey-base64');
  //   String ivstr = await neverLocalStorageRead('secretIv-base64');
  //   Key key = Key.fromBase64(keystr);
  //   IV iv = IV.fromBase64(ivstr);
  //   final decrypter = Encrypter(AES(key));
  //   final decrypted = decrypter.decrypt(Encrypted.from64(enc), iv: iv);
  //   return decrypted;
  // }
/*
Wallet address
*/ 
//获取模糊的钱包地址 中间是省略号
  get currentWalletAddressFuzzyed {
    return addressFuzzy(currentWalletAddress.value);
  }
//获取完整的钱包地址
  get currentWalletAddressStandard {
    return addressStandard(currentWalletAddress.value);
  }
//获取当前钱包余额 根据币种分别获取
  get currentWalletBalance {
    final Map<String, num> acc = {};
    ownedObjectBatch.where((element) => isCoin((element as SuiObject).type)).forEach((element) {
      final coinType = coinTypeArgRegExp.firstMatch(element.type)?[1];

      if (coinType is String) {
        if (acc[coinType] is num) {
          acc[coinType] = acc[coinType]! + (element.fields['balance'] ?? 0);
        } else {
          acc[coinType] = (element.fields['balance'] ?? 0);
        }
      }
    });

    return acc;
  }
//获取当前sui链钱包的NFT 
  List<SuiObject> get currentWalletNFTs {
    final List<SuiObject> nfts = [];
    ownedObjectBatch
        .where((element) => !isCoin((element as SuiObject).type))
        .where((element) => (element as SuiObject).dataType == 'moveObject' && (element).hasPublicTransfer)
        .forEach((element) {
      nfts.add(element);
    });
    return nfts;
  }
//获取发送地址为当前钱包的交易记录
  get transactionsSend {
    return transactions.takeWhile((element) => element.isSender);
  }
//获取接收地址为当前钱包的交易记录
  get transactionsReceive {
    return transactions.takeWhile((element) => !element.isSender);
  }
//更新数据
  updateCallback({primaryCoinBalance, publicAddress, publicAddressFuzzyed, transactions, NFTs, gasDefault}) {
    this.primaryCoinBalance.value = primaryCoinBalance;
    this.publicAddress.value = publicAddress;
    this.publicAddressFuzzyed.value = publicAddressFuzzyed;
    this.transactions.value = transactions;
    this.NFTs.value = NFTs;
    this.gasDefault.value = gasDefault;
  }
//导入/创建钱包后调用addWallet，将助记词加密后存在本地
  addWallet(String mnemonic, String pwd) async {
    var enc = encryptMnemonic(mnemonic, pwd);
    wallets.insert(0, SuiWallet(mnemonic: enc, suiApi:Get.find()));



    var address = await getSuiAddress(await getKeypairFromMnemonics(mnemonic));
    final ethprivatekey = await getETHPrivateKey(mnemonic);
    final ethaddress = await getETHPublicAddress(ethprivatekey);
    var storedata = "$enc*$ethaddress*$address";
    currentWalletIndex = wallets.length - 1;
    String key = address.toString().substring(address.length - 6);
    await safeStorage.write(key, storedata);
    await neverLocalStorageWrite("NowAddressKey", key);
    currentWalletAddress.value = address;
    currentWallet?.address = currentWalletAddress.value;

    print('wallets ------');
    print(wallets);

    userlogin(pwd);
    // if (hasWallet) {
    //   initCurrentWallet(pwd);
    // }
  }
//从助记词获取eth私钥
  Future<String?> getEthPrivatekeyFromCurrentMnemonic(String pwd) async {
    String demnemonic = decryptMnemonic(currentWallet?._mnemonic ?? '', pwd);
    final privatekey = await getETHPrivateKey(demnemonic);
    return privatekey;
  }
//从eth私钥获得地址
  Future<EthereumAddress?> getEthAddressFromPrivatekey(String privatekey) async {
    return await getETHPublicAddress(privatekey);
    ;
  }
//eth私钥从string格式转换为EthPrivateKey
  Future<EthPrivateKey?> getCredentialsFromPrivatekey(String privatekey) async {
    return getCredentials(privatekey);
  }
//加载本地所有钱包（助记词）格式：助记词*ethAddress*suiAddress
  loadStorageWallet({bool clean = false}) async {
    final all = await safeStorage.readAll();
    wallets.clear();
    all.forEach((key, value) {
      if (value.contains('*')) {
        List dataValue = value.split("*");
        var mnemonic = value.split("*").first;
        var ethaddress = dataValue[1];
        var addr = value.split("*").last;
        SuiWallet xx = SuiWallet(mnemonic: mnemonic, suiApi: Get.find());
        xx.address = addr;
        xx.name = key;
        wallets.add(xx);
        xx.ethaddress = ethaddress;
      }
    });
    if (hasWallet) {
      var NowAddressKey = await neverLocalStorageRead("NowAddressKey");
      if (NowAddressKey.toString() != "null") {
        int number = wallets.indexWhere((element) => element.name == NowAddressKey);
        currentWalletAddress.value = wallets[number].address!;
        currentWallet?.address = wallets[number].address!;
        currentWallet?.name = wallets[number].name!;
      } else {
        currentWalletAddress.value = wallets.first.address!;
        currentWallet?.address = wallets.first.address!;
        currentWallet?.name = wallets.first.name!;
      }
      // initCurrentWallet("");
      userlogin("");
    }
  }
//加载本地钱包
  loadStorageWalletSelect({bool clean = false}) async {
    final all = await safeStorage.readAll();
    wallets.clear();
    all.forEach((key, value) {
      if (value.contains('*')) {
        var mnemonic = value.split("*").first;
        var addr = value.split("*").last;
        SuiWallet xx = SuiWallet(mnemonic: mnemonic, suiApi: Get.find());
        xx.address = addr;
        xx.name = key;
        wallets.add(xx);
      }
    });
  }

  // initCurrentWallet(String pwd) async {
  //   if (hasWallet) {
  //     if (pwd != "") {
  //       // String demnemonic =
  //       //     decryptMnemonic(currentWallet?._mnemonic ?? '', pwd);
  //       // currentWalletAddress.value =
  //       //     await getSuiAddress(await getKeypairFromMnemonics(demnemonic));
  //       // currentWallet?.address = currentWalletAddress.value;
  //       // print("currentWalletAddress.value=" + currentWalletAddress.value);
  //     }
  //   }
  // }
//获取当前钱包sui链地址所拥有的所有object
  getOwnedObjectBatch() async {
    if (hasWallet) {
      if (currentWallet == null) {
        var suiapi = Get.find();
        final objectIds = await suiapi.getObjectsOwnedByAddress(currentWalletAddress.string);
        return await suiapi.getObjectBatch(objectIds);
      }
      final objectIds = await currentWallet?._suiApi?.getObjectsOwnedByAddress(currentWalletAddress.string);
      return await currentWallet?._suiApi?.getObjectBatch(objectIds);
    }

    return [];
  }
//获取sui测试币
  getFaucet() async {
    await currentWallet?._suiApi?.getSuiFaucet(currentWalletAddress.string);
  }
//获取多链余额
  getBalance() async {
    var network = await neverLocalStorageRead('network');
    var currentNetwork = networks[network != 'null' ? network.toString().toInt() : 0].name;

    double balance = 0;

    print('get balance');
    print(currentNetwork);

    switch (currentNetwork) {
      case 'SUI':
        ownedObjectBatch.value = await getOwnedObjectBatch();
        balance = NumUtil.getNumByValueDouble(getSuiBalance() / 1000000000, 9)?.toDouble() ?? 0;
        break;
      case 'ETHMAINNET':
        var ethAmount = await ContractLocator.getInstance(chainIdvalues[ChainId.ETHMAINNET.index]).getEthBalance(EthereumAddress.fromHex(wallets.first.ethaddress ?? ''));
        balance = ethAmount.getInWei.toDouble() / BigInt.from(10).pow(18).toDouble();
        break;
      case 'GOERLI':
        var ethAmount = await ContractLocator.getInstance(chainIdvalues[ChainId.GOERLI.index]).getEthBalance(EthereumAddress.fromHex(wallets.first.ethaddress ?? ''));
        balance = ethAmount.getInWei.toDouble() / BigInt.from(10).pow(18).toDouble();
        break;
      case 'BSC':
        var ethAmount = await ContractLocator.getInstance(chainIdvalues[ChainId.BSC.index]).getEthBalance(EthereumAddress.fromHex(wallets.first.ethaddress ?? ''));
        balance = ethAmount.getInWei.toDouble() / BigInt.from(10).pow(18).toDouble();
        break;
      case 'BSCTEST':
        var ethAmount = await ContractLocator.getInstance(chainIdvalues[ChainId.BSCTEST.index]).getEthBalance(EthereumAddress.fromHex(wallets.first.ethaddress ?? ''));
        balance = ethAmount.getInWei.toDouble() / BigInt.from(10).pow(18).toDouble();
        break;
      case 'POLYGON':
        var ethAmount = await ContractLocator.getInstance(chainIdvalues[ChainId.POLYGON.index]).getEthBalance(EthereumAddress.fromHex(wallets.first.ethaddress ?? ''));
        balance = ethAmount.getInWei.toDouble() / BigInt.from(10).pow(18).toDouble();
        break;
      case 'KLAYTN':
        var ethAmount = await ContractLocator.getInstance(chainIdvalues[ChainId.KLAYTN.index]).getEthBalance(EthereumAddress.fromHex(wallets.first.ethaddress ?? ''));
        balance = ethAmount.getInWei.toDouble() / BigInt.from(10).pow(18).toDouble();
        break;
      case 'KLAYTN_BAOBAB':
        var ethAmount = await ContractLocator.getInstance(chainIdvalues[ChainId.KLAYTN_BAOBAB.index]).getEthBalance(EthereumAddress.fromHex(wallets.first.ethaddress ?? ''));
        balance = ethAmount.getInWei.toDouble() / BigInt.from(10).pow(18).toDouble();
        break;
      case 'ASTAR':
        var ethAmount = await ContractLocator.getInstance(chainIdvalues[ChainId.AstarMainnet.index]).getEthBalance(EthereumAddress.fromHex(wallets.first.ethaddress ?? ''));
        balance = ethAmount.getInWei.toDouble() / BigInt.from(10).pow(18).toDouble();
        break;
    }

    print(currentNetwork + "::" + balance.toString());
    currentBalance.value = balance;
  }
   //获取sui NFT
  getNFTs() async {
    ownedObjectBatch.value = await getOwnedObjectBatch();
  }
//获取sui链交易记录
  getTransactionsForAddress() async {
    if (hasWallet) {
      transactions.value = await currentWallet?._suiApi?.getTransactionsForAddress(currentWalletAddress.string) ?? [];
    }
  }
//删除某个钱包
  deleteWallet(String index) async {
    safeStorage.deleteSecureData(index);
    // if (hasWallet) {
    //   safeStorage.deleteAll();
    // }
  }

  //根据手续费大小选择用于支付手续费的Object 返回其Id
  getGasPayObjId(num amount) {
    final coins = ownedObjectBatch.where((element) => isCoin((element as SuiObject).type) && isSuiCoin(element.type)).toList();

    if (coins.isEmpty) {
      // print("coins.isEmpty !!!!!");
      return null;
    }

    final coin = prepareCoinWithEnoughBalance(coins as List<SuiObject>, amount) as SuiObject;
    return getCoinId(coin);
  }

  //transferSuiObject sui的NFT转账
  Future<SuiTansaction?> transferNFT(SuiObject nft, String recipient, String pwd) async {
    final transferSuiObjTransaction = ['0x${suiWallet.currentWalletAddress.value}', getCoinId(nft), null, defaultGasBudgetForMoveCall, recipient];

    final response = await currentWallet?._suiApi?.transferSuiObject(transferSuiObjTransaction);

    final txByte = JSON.resolve(json: response.data, path: 'result.txBytes', defaultValue: '');

    final executeSuiTransaction = await signTx(txByte, pwd);

    return await currentWallet?._suiApi?.suiExecuteTransaction(suiWallet.currentWalletAddress.value, executeSuiTransaction);
  }

  /*
  Params
signer : <SuiAddress> - the transaction signer's Sui address
package_object_id : <ObjectID> - the Move package ID, e.g. `0x2`
module : <string> - the Move module name, e.g. `devnet_nft`
function : <string> - the move function name, e.g. `mint`
type_arguments : <[TypeTag]> - the type arguments of the Move function
arguments : <[SuiJsonValue]> - the arguments to be passed into the Move function, in <a href="https://docs.sui.io/build/sui-json">SuiJson</a> format
gas : <ObjectID> - gas object to be used in this transaction, the gateway will pick one from the signer's possession if not provided
gas_budget : <uint64> - the gas budget, the transaction will fail if the gas cost exceed the budget
*/
//sui链的所有智能合约调用都用这个接口
  Future<SuiTansaction?> suiMoveCall(MoveCallTransaction transaction, String pwd) async {
    //try {
    final response = await currentWallet?._suiApi?.suiMoveCall([
      '0x${suiWallet.currentWalletAddress.value}',
      transaction.packageObjectId,
      transaction.module,
      transaction.function,
      transaction.typeArguments,
      transaction.arguments,
      transaction.gasPayment,
      transaction.gasBudget
    ]);
    // print("response:  "+response.toString());
    final txByte = JSON.resolve(json: response.data, path: 'result.txBytes', defaultValue: '');

    final executeSuiTransaction = await signTx(txByte, pwd);

    return await currentWallet?._suiApi?.suiExecuteTransaction('0x${suiWallet.currentWalletAddress.value}', executeSuiTransaction);
    // } catch (e) {
    //   showError('executeMoveCall Error', e.toString());
    //   return null;
    // }
  }
//sui转账方式1 适用于sui的某种特殊转账情况，前端不直接调用此接口
//前端转账sui时只需调用下面的paySuiObjects接口
  Future<SuiTansaction?> transferSui(String recipient, int amount, String pwd) async {
    try {
      print("start transferSui !!!!!");
      // sui coins
      final coins = ownedObjectBatch.where((element) => isCoin((element as SuiObject).type) && isSuiCoin(element.type)).toList();

      if (coins.isEmpty) {
        // print("coins.isEmpty !!!!!");
        return null;
      }

      final coin = prepareCoinWithEnoughBalance(coins as List<SuiObject>, amount + defaultGasBudgetForMerge) as SuiObject;

      final transferSuiTransaction = ['0x${suiWallet.currentWalletAddress.value}', getCoinId(coin), defaultGasBudgetForTransferSUI, recipient, amount];

      final response = await currentWallet?._suiApi?.suiTransferSui(transferSuiTransaction);
      final txByte = JSON.resolve(json: response.data, path: 'result.txBytes', defaultValue: '');

      final executeSuiTransaction = await signTx(txByte, pwd);

      return await currentWallet?._suiApi?.suiExecuteTransaction(suiWallet.currentWalletAddress.value, executeSuiTransaction);
    } catch (e) {
      // print(e.toString());
      showError('transferSui', e.toString());
      return null;
    }
  }
//将一个sui的object拆分成两部分 分别对应不同金额
  //split
  splitSui(String coinobjectid, String feeobjectid, List<int> splitamounts, String pwd) async {
    try {
      // print("start splitSui !!!!!");

      final transferSuiTransaction = ['0x${suiWallet.currentWalletAddress.value}', coinobjectid, splitamounts, feeobjectid, defaultGasBudgetForSplit];

      final response = await currentWallet?._suiApi?.splitSui(transferSuiTransaction);
      final txByte = JSON.resolve(json: response.data, path: 'result.txBytes', defaultValue: '');

      final executeSuiTransaction = await signTx(txByte, pwd);

      await currentWallet?._suiApi?.suiExecuteTransaction(suiWallet.currentWalletAddress.value, executeSuiTransaction);
    } catch (e) {
      showError('splitSui', e.toString());
      // return null;
    }
  }

  /* Sui 签名交易
  tx_bytes : <Base64> - transaction data bytes, as base-64 encoded string
  sig_scheme : <SignatureScheme> - Flag of the signature scheme that is used.
  signature : <Base64> - transaction signature, as base-64 encoded string
  pub_key : <Base64> - signer's public key, as base-64 encoded string
  request_type : <ExecuteTransactionRequestType> - The request type
  */
  signTx(txByte, String pwd) async {
    // print("pwd ="+pwd);
    String demnemonic = decryptMnemonic(currentWallet?._mnemonic ?? '', pwd);
    // print(demnemonic.toString());
    final keypair = await getKeypairFromMnemonics(demnemonic);
    final algorithm = Ed25519();
    keypair.extractPrivateKeyBytes();
    final signature = base64.encode((await algorithm.sign(base64.decode(txByte), keyPair: keypair)).bytes);
    final publicKey = base64.encode((await keypair.extractPublicKey()).bytes);
    return [txByte, "ED25519", signature, publicKey, "WaitForLocalExecution"];
  }
  //用sui的私钥签名消息
  signMsg(msg, pwd) async {
    String demnemonic = decryptMnemonic(currentWallet?._mnemonic ?? '', pwd);
    final keypair = await getKeypairFromMnemonics(demnemonic);
    final algorithm = Ed25519();
    keypair.extractPrivateKeyBytes();
    final signature = base64.encode((await algorithm.sign(msg, keyPair: keypair)).bytes);
    return signature;
  }

  //pay sui with multi pbjects sui的转账接口，前端转账直接调用这个接口即可 不必管其他sui的拆分等接口
  /*
Note: !!! Gas coin should not in input coins of Pay transaction !!!!!!

Params
signer : <SuiAddress> - the transaction signer's Sui address
input_coins : <[ObjectID]> - the Sui coins to be used in this transaction
recipients : <[SuiAddress]> - the recipients' addresses, the length of this vector must be the same as amounts.
amounts : <[]> - the amounts to be transferred to recipients, following the same order
gas : <ObjectID> - gas object to be used in this transaction, the gateway will pick one from the signer's possession if not provided
gas_budget : <uint64> - the gas budget, the transaction will fail if the gas cost exceed the budget
  */
  Future<SuiTansaction?> paySuiObjects(String recipient, int amount, String pwd) async {
    // try {
    final coins = ownedObjectBatch.where((element) => isCoin((element as SuiObject).type) && isSuiCoin(element.type)).toList();
    if (coins.isEmpty) {
      print("coins.isEmpty !!!!!");
      return null;
    }

    num totalbalances = 0;
    for (var ccc in coins) {
      totalbalances += (ccc).fields['balance'];
    }
    if (totalbalances - defaultGasBudgetForTransferSUI - amount < 0) {
      print("Not enough balance");
      return null;
    }
    final coinsToSend = prepareCoinsWithEnoughTotalBalance(coins as List<SuiObject>, amount + defaultGasBudgetForMerge) as List<SuiObject>;
    List<String> idOfCoins = []; //param 1
    for (SuiObject sss in coinsToSend) {
      print("coinid = ${getCoinId(sss)}");
      idOfCoins.add(getCoinId(sss));
    }
    if (coinsToSend.length == coins.length) {
      //No object to pay fee
      if (coinsToSend.length == 1) {
        return await transferSui(recipient, amount, pwd);
      } else {
        int leftamount = coinsToSend[0].fields['balance'] - defaultGasBudgetForTransferSUI * idOfCoins.length;
        int leftfee = defaultGasBudgetForTransferSUI * idOfCoins.length;
        if (leftamount <= 0) {
          print("balances not enough 1");
          return null;
        }
        if (coinsToSend[1].fields['balance'] < defaultGasBudgetForTransferSUI) {
          print("balances not enough 2");
          return null;
        }
        await splitSui(getCoinId(coinsToSend[0]), getCoinId(coinsToSend[1]), [leftamount, leftfee], pwd);
        await suiWallet.getBalance();
        return paySuiObjects(recipient, amount, pwd);
      }
      //return null;
    } else {
      //1*
      String feecoinId = "no";
      for (SuiObject sx in coins) {
        print("current sx = " + getCoinId(sx));
        if (idOfCoins.contains(getCoinId(sx)) == false && (sx).fields['balance'] > defaultGasBudgetForTransferSUI) {
          // print("idOfCoins contains " + getCoinId(sx));
          feecoinId = getCoinId(sx);
          //  break;
        }
      }
      if (feecoinId == "no") {
        print("No object to pay fee! 2");
        return null;
      }

      List<String> recip = [];
      recip.add(recipient);
      List<int> amou = [];
      amou.add(amount);

      final transferSuiTransaction = [
        '0x${suiWallet.currentWalletAddress.value}',
        idOfCoins,
        recip,
        amou,
        feecoinId,
        defaultGasBudgetForTransferSUI * idOfCoins.length,
      ];

      final response = await currentWallet?._suiApi?.paySuiCoins(transferSuiTransaction);

      final txByte = JSON.resolve(json: response.data, path: 'result.txBytes', defaultValue: '');

      print("txByte = $txByte");

      final executeSuiTransaction = await signTx(txByte, pwd);

      return await currentWallet?._suiApi?.suiExecuteTransaction(suiWallet.currentWalletAddress.value, executeSuiTransaction);
    }
  }
//根据sui的转账金额估算费用
  int suiEstimateFee(int amount) {
    final coins = ownedObjectBatch.where((element) => isCoin((element as SuiObject).type) && isSuiCoin(element.type)).toList();
    if (coins.isEmpty) {
      // print("suiEstimateFee 1 "+defaultGasBudgetForTransferSUI.toString());
      return defaultGasBudgetForTransferSUI;
    }
    num totalbalances = 0;
    for (var ccc in coins) {
      totalbalances += (ccc).fields['balance'];
    }
    final coinsToSend = prepareCoinsWithEnoughTotalBalance(coins as List<SuiObject>, amount + defaultGasBudgetForMerge) as List<SuiObject>;
    if (coinsToSend.isEmpty) {
      //print("suiEstimateFee 3 "+defaultGasBudgetForTransferSUI.toString());
      return defaultGasBudgetForTransferSUI;
    }
    if (coinsToSend.length == coins.length) {
      if (coinsToSend.length == 1) {
        //print("suiEstimateFee 4 "+(defaultGasBudgetForTransferSUI + defaultGasBudgetForSplit).toString());
        return defaultGasBudgetForTransferSUI + defaultGasBudgetForSplit;
      } else {
        //print("suiEstimateFee 5 "+(defaultGasBudgetForSplit + defaultGasBudgetForTransferSUI * coins.length).toString());
        return defaultGasBudgetForSplit + defaultGasBudgetForTransferSUI * coins.length;
      }
    } else {
      //print("suiEstimateFee 6 "+(defaultGasBudgetForSplit +defaultGasBudgetForTransferSUI * coins.length).toString());
      return defaultGasBudgetForSplit + defaultGasBudgetForTransferSUI * coinsToSend.length;
    }
  }

  //get txs
  //获取当前sui钱包的所有交易id
  getTxDigestForCurrentwallet() async {
    transactions.value = await currentWallet?._suiApi?.getTransactionsForAddress(suiWallet.currentWalletAddress.value) ?? [];
  }

  /*
password backup
1. Future<String> encryptPassword(String pwd) 注册时调用 随机生成密钥(key,iv)并加密用户的密码，将加密值enc调用后台接口返回给后台
2. Future<String> decryptPassword(String enc) 找回密码时调用 后台将密码的加密值enc通过邮件发送给用户, 取本地存储的密钥(key,iv)解密出密码，显示给用户
3. Future<String> getEncId() 取本地存储的encId（encId是enc的前4位），找回密码时调用，将其传给后台，后台先找到邮箱账号对应的所有enc，再比对encId，返回对应的enc值
*/
  //encrypt the password return base64
  Future<String> encryptPassword(String pwd) async {
    final key = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);
    neverLocalStorageWrite('secretKey-base64', key.base64);
    neverLocalStorageWrite('secretIv-base64', iv.base64);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(pwd, iv: iv);
    neverLocalStorageWrite('encId', encrypted.base64.substring(0, 4));
    return encrypted.base64;
  }

  //decrypt the password input base64 return string
  Future<String> decryptPassword(String enc) async {
    String keystr = await neverLocalStorageRead('secretKey-base64');
    String ivstr = await neverLocalStorageRead('secretIv-base64');
    Key key = Key.fromBase64(keystr);
    IV iv = IV.fromBase64(ivstr);
    final decrypter = Encrypter(AES(key));
    final decrypted = decrypter.decrypt(Encrypted.from64(enc), iv: iv);
    return decrypted;
  }

  Future<String> getEncId() async {
    String encId = await neverLocalStorageRead('encId');
    return encId;
  }
}

class SuiWallet {
  String? _mnemonic;
  SuiApi? _suiApi;
  String? address;
  String? name;
  String? ethaddress;

  SuiWallet({required String mnemonic, required SuiApi suiApi}) {
    _mnemonic = mnemonic;
    _suiApi = suiApi;
  }

  executeMoveCall(transaction) {
    //ToDo
  }
}
