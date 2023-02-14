import 'dart:convert';

import 'package:coinstart_wallet_extension/api/api_service.dart';
import 'package:coinstart_wallet_extension/api/sui_request.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/controller/format.dart';
import 'package:coinstart_wallet_extension/controller/json.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:neveruseless/never/neverLocalStorage.dart';
import 'package:ones/extension/string_ex.dart';

import '../controller/apiurls.dart';

class SuiApi extends GetxController{

  final String _bkApi = 'http://54.153.73.0:8081/coincloud/v1'; //test: http://54.153.73.0:8081/coincloud/v1/ pro: https://api.coinstart.io/
  // String devurl = 'https://fullnode.devnet.sui.io/';
  // String stagingurl = 'https://fullnode.staging.sui.io/';
  // String testneturl = 'https://fullnode.testnet.sui.io/';
  SuiApi(){
    configBaseUrl();
  }
  String _faucetHost = "staging";
  ApiService _apiServiceCurrent = ApiService('https://fullnode.devnet.sui.io/');
  configBaseUrl() async {
    List<String> facuetArray = ['devnet','staging','testnet'];
    var valueApiIndex = await neverLocalStorageRead('apiurl');
    if (valueApiIndex != 'null') {
      int index = valueApiIndex.toString().toInt();
      var apiInfo = apiUrls[index];
      _apiServiceCurrent = ApiService(apiInfo.url);
      _faucetHost =  facuetArray[index];
    }
  }
  //用户创建/导入钱包后调用，将ip sui钱包的地址等信息记录在后台
  userLogin(UserData data) async {
    //final userdata = 'account=' + data.account.toString()+'&memo='+data.memo.toString()+'&sign='+data.sign.toString();
    final userdata2 = <String, String>{'account': data.account.toString(), 'memo': data.memo.toString(), 'sign': data.sign.toString()};
    Uri url = Uri.https('api.coinstart.io', '/coincloud/v1/user/log/login'); //54.153.73.0:8081   api.coinstart.io
    http.post(url, headers: {'Access-Control-Allow-Origin': 'access-control-allow-origin'}, body: userdata2).then((response) {
      //headers : {'Access-Control-Allow-Origin':'access-control-allow-origin', 'Access-Control-Request-Method':'POST'},
      //print(response.toString());
    });
  }

  //找回密码（需要邮箱验证码
  Future<http.Response> retrievePassword(String email,  String encId) async {
    final data = <String, String>{'email': email, 'encid': encId};
    Uri url = Uri.https('api.coinstart.io', '/coincloud/v1/account/password/retrieve');
    return await http.post(url, headers: {'Access-Control-Allow-Origin': 'access-control-allow-origin'}, body: data);
  }

  //设置enc（需要邮箱验证码
  Future<http.Response> setEncPassword(String email, String code, String enc) async {
    final data = <String, String>{'email': email, 'code': code, 'enc': enc};
    Uri url = Uri.https('api.coinstart.io', '/coincloud/v1/account/password/set');
    return await http.post(url, headers: {'Access-Control-Allow-Origin': 'access-control-allow-origin'}, body: data);
  }

  //发送邮箱验证码
  Future<http.Response> sendVerifyCode(String email) async {
    final data = <String, String>{'email': email};
    Uri url = Uri.https('api.coinstart.io', '/coincloud/v1/account/send/code');
    return await http.post(url, headers: {'Access-Control-Allow-Origin': 'access-control-allow-origin'}, body: data);
  }

  //校验邮箱验证码
  Future<http.Response> verifyCode(String email, String code) async {
    final data = <String, String>{'email': email, 'code': code};
    Uri url = Uri.https('api.coinstart.io', '/coincloud/v1/account/password/checkcode');
    return await http.post(url, headers: {'Access-Control-Allow-Origin': 'access-control-allow-origin'}, body: data);
  }
  //领sui的测试币 连续调用3次后会被禁 间隔1h后才能成功
  getSuiFaucet(String address) {
    // Uri url = Uri.https('faucet.devnet.sui.io', '/gas');

    // Uri url = Uri.https('faucet.staging.sui.io', '/gas');
    Uri url = Uri.https('faucet.$_faucetHost.sui.io', '/gas'); //改1*****
    final data = {
      "FixedAmountRequest": {"recipient": address}
    };
    // print("getSuiFaucet"+address.toString());

    http
        .post(url,
            headers: {
              'authority': 'faucet.staging.sui.io', //改2****
              'Content-Type': 'application/json',
              "origin": "https://sui.bluemove.net",
              "referer": "https://sui.bluemove.net/",
            },
            body: jsonEncode(data))
        .then((response) {
      // print(response.toString());
    });
  }
  //获取sui的地址对应的所有对象，查询sui余额、代币余额、NFT都用它
  Future<List<String>> getObjectsOwnedByAddress(String address) async {
    List<String> objectIds = [];
    final response = await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_getObjectsOwnedByAddress', params: [address]));
    final result = JSON.resolve(json: response.data, path: 'result', defaultValue: []);
    for (var element in result) {
      if (element['objectId'] is String) {
        objectIds.add(element['objectId']);
      }
    }
    return objectIds;
  }
  //根据objectId 批量获取object
  Future<List<SuiObject>> getObjectBatch(List<String?>? objectIds) async {
    try {
      List<SuiObject> ownedSuiObject = [];
      final response = await _apiServiceCurrent.post('/', objectIds?.map((String? objectId) => SuiRequest(method: 'sui_getObject', params: [objectId ?? ''])).toList());
      if (response.data is! List && response.data['error'] is Map) {
        return [];
      }
      response.data.forEach((json) {
        final type = JSON.resolve(json: json, path: 'result.details.data.type', defaultValue: '');
        final dataType = JSON.resolve(json: json, path: 'result.details.data.dataType', defaultValue: '');
        final hasPublicTransfer = JSON.resolve(json: json, path: 'result.details.data.has_public_transfer', defaultValue: false);
        final fields = JSON.resolve(json: json, path: 'result.details.data.fields', defaultValue: {});

        ownedSuiObject.add(SuiObject(type: type, dataType: dataType, hasPublicTransfer: hasPublicTransfer, fields: fields));
      });
      return ownedSuiObject;
    } on DioError catch (e) {
      showError('Network Error', (e.response ?? e.message).toString());
      return [];
    } on Error catch (e) {
      showError('getObjectBatch Error', e.toString());
      return [];
    }
  }

  // 将获取的sui的交易记录详情由json解析为对象
  // flat
  // how to performance
  SuiTansaction transformTransaction(json, address) {
    final transactionDigest = JSON.resolve(json: json, path: 'result.certificate.transactionDigest', defaultValue: '');
    final from = JSON.resolve(json: json, path: 'result.certificate.data.sender', defaultValue: '');
    final gasSummary = JSON.resolve(json: json, path: 'result.effects.gasUsed', defaultValue: {});

    final error = JSON.resolve(json: json, path: 'result.effects.status.error', defaultValue: '');
    final status = JSON.resolve(json: json, path: 'result.effects.status.status', defaultValue: '');

    final timestampMs = JSON.resolve(json: json, path: 'result.timestamp_ms', defaultValue: 0);
    final txGas = (gasSummary['computationCost'] ?? 0) + (gasSummary['storageCost'] ?? 0) - (gasSummary['storageRebate'] ?? 0);

    final txn = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0', defaultValue: {});

    var txKind = '';
    var amount = 0;
    var recipient = '';
    if (txn.keys.first is String) {
      txKind = txn.keys.first;
      // print("txKind = "+txKind);
      if (txKind == "Pay") {
        List amounts = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0.Pay.amounts', defaultValue: []);

        List recipients = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0.Pay.recipients', defaultValue: []);
        amount = amounts.first;
        recipient = recipients.first;
        // print("txKind = "+txKind+ " amount = "+ amount.toString() +" recipient "+recipient);
      } else if (txKind == "PaySui") {
        List amounts = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0.PaySui.amounts', defaultValue: []);
        int totalamount = 0;
        for (int objamount in amounts) {
          totalamount += objamount;
        }
        List recipients = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0.PaySui.recipients', defaultValue: []);
        recipient = recipients.first;
        amount = totalamount;
      } else {
        amount = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0.$txKind.amount', defaultValue: 0);

        recipient = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0.$txKind.recipient', defaultValue: '');
        // print("txKind = "+txKind+ " amount = "+ amount.toString() +" recipient "+recipient);
      }
    }
    // print("SuiTansaction : "+ transactionDigest.toString() + " "+ status.toString() + " "+ from.toString() + " "+  amount.toString());
    return SuiTansaction(
      // seq: seq[digests.indexOf(transactionDigest)],
      txId: transactionDigest,
      status: status,
      txGas: txGas,
      kind: txKind,
      from: from,
      error: error,
      timestampMs: timestampMs,
      isSender: addressStandard(from) == addressStandard(address),
      amount: amount,
      recipient: recipient,
    );
  }
  //与上面的一样 将获取的sui的交易记录详情由json解析为对象
  SuiTansaction transformTransactionRes(json, address) {
    final transactionDigest = JSON.resolve(json: json, path: 'result.EffectsCert.certificate.transactionDigest', defaultValue: '');
    final from = JSON.resolve(json: json, path: 'result.EffectsCert.certificate.data.sender', defaultValue: '');
    final gasSummary = JSON.resolve(json: json, path: 'result.EffectsCert.effects.gasUsed', defaultValue: {});

    final error = JSON.resolve(json: json, path: 'result.EffectsCert.effects.status.error', defaultValue: '');
    final status = JSON.resolve(json: json, path: 'result.EffectsCert.effects.effects.status.status', defaultValue: '');

    const timestampMs = 0;
    final txGas = (gasSummary['computationCost'] ?? 0) + (gasSummary['storageCost'] ?? 0) - (gasSummary['storageRebate'] ?? 0);
    final txn = JSON.resolve(json: json, path: 'result.EffectsCert.certificate.data.transactions.0', defaultValue: {});
    var txKind = '';
    var amount = 0;
    var recipient = '';
    if (txn.keys.first is String) {
      txKind = txn.keys.first;
      // print("txKind = "+txKind);
      if (txKind == "Pay") {
        List amounts = JSON.resolve(json: json, path: 'result.EffectsCert.certificate.data.transactions.0.Pay.amounts', defaultValue: []);

        List recipients = JSON.resolve(json: json, path: 'result.EffectsCert.certificate.data.transactions.0.Pay.recipients', defaultValue: []);

        print('tsadfgasdfasdf');
        print(json);
        print(amounts);

        amount = amounts.first;
        recipient = recipients.first;
        // print("txKind = "+txKind+ " amount = "+ amount.toString() +" recipient "+recipient);
      } else if (txKind == "PaySui") {
        List amounts = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0.PaySui.amounts', defaultValue: []);
        int totalamount = 0;
        for (int objamount in amounts) {
          totalamount += objamount;
        }
        List recipients = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0.PaySui.recipients', defaultValue: []);
        recipient = recipients.first;
        amount = totalamount;
      } else {
        amount = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0.$txKind.amount', defaultValue: 0);

        recipient = JSON.resolve(json: json, path: 'result.certificate.data.transactions.0.$txKind.recipient', defaultValue: '');
        // print("txKind = "+txKind+ " amount = "+ amount.toString() +" recipient "+recipient);
      }
    }

    // print("SuiTansaction : "+ transactionDigest.toString() + " "+ status.toString() + " "+ from.toString() + " "+  amount.toString());
    return SuiTansaction(
      // seq: seq[digests.indexOf(transactionDigest)],
      txId: transactionDigest,
      status: status,
      txGas: txGas,
      kind: txKind,
      from: from,
      error: error,
      timestampMs: timestampMs,
      isSender: addressStandard(from) == addressStandard(address),
      amount: amount,
      recipient: recipient,
    );
  }
  /*
  https://fullnode.devnet.sui.io/
  ## Post:
  {
  "jsonrpc": "2.0",
  "id": 1,
  "method": "sui_getTransactions",
  "params": [
    {
      "FromAddress": "0xdb360a6241bcc14f185767c526d8cb7e41a92869"
    },
    null,
    100,
    false
  ]
  }
  ## Return:
  {
    "jsonrpc": "2.0",
    "result": {
        "data": [
            "8mNQ/oEk7w1X81YGPi9LB89fAQJF1Rdl1FSwhtDJccI=",
            "Bzix6sF/6I2FInp/qTohmR9791c8sO8LAf3eKKU2pr8=",
            "vlecW60Bo8AD0QqCSyvJpUTy4VPBxrSCMJM5geexcmE=",
            "c+DkI9I9UMh1NcAz5uqBEkj7TLx61eL+J6ZjmK0ZmVE=",
            "8m48P3uSc7yNoJzw9qkrKixJ2ak4GprKYcZ5YEadAhw="
        ],
        "nextCursor": null
    },
    "id": 1
}
  */
  //获取地址关联的交易id号
  Future<List<SuiTansaction>> getTransactionsForAddress(address) async {
    final List<SuiTansaction> tansactions = [];
    final List<String> digests = [];
    final List<num> seq = [];
    final List<String> txids = [];
    final paramsfrom = [
      {"FromAddress": '0x' + address},
      null,
      100,
      false
    ];

    final paramsto = [
      {"ToAddress": '0x' + address},
      null,
      100,
      false
    ];
    // print(paramsfrom);

    (await _apiServiceCurrent.post('/', [SuiRequest(method: 'sui_getTransactions', params: paramsfrom), SuiRequest(method: 'sui_getTransactions', params: paramsto)]))
        .data
        .forEach((json) {
      final result = JSON.resolve(json: json, path: 'result', defaultValue: {});
      // print("result = " + result.toString());
      final data = JSON.resolve(json: json, path: 'result.data', defaultValue: []);
      // print("data = " + data.toString());

      for (var e in data) {
        if (!digests.contains(e)) {
          digests.add(e);
          //  print("not contains");
        }
        // print("contains");
      }
    });

    if (digests.isEmpty) {
      return tansactions;
    }
    (await _apiServiceCurrent.post('/', digests.map((digest) => SuiRequest(method: 'sui_getTransaction', params: [digest])).toList())).data.forEach((json) {
      // print("sui_getTransaction json = " + json.toString());
      SuiTansaction tx = transformTransaction(json, address);
      if (!txids.contains(tx.txId)) {
        txids.add(tx.txId);
        tansactions.add(transformTransaction(json, address));
        if (tx.amount == 0) {
          //  print("tx.amount == 0 txid: "+tx.txId);
        }
      }
    });
    tansactions.sort((a, b) => b.timestampMs - a.timestampMs);
    return tansactions;
  }

  // sui_getTransactions
  suigetTransactions(List<dynamic> params) async {
    return await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_getTransactions', params: params));
  }

  transferSuiObject(List<dynamic> params) async {
    return await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_transferObject', params: params)); //sui_transferSui->sui_transferObject
  }

  suiTransferSui(List<dynamic> params) async {
    return await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_transferSui', params: params));
  }

  splitSui(List<dynamic> params) async {
    return await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_splitCoin', params: params));
  }

  suiBatchTransferSui(List<dynamic> params) async {
    return await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_batchTransaction', params: params));
  }

  suiMergeCoins(List<dynamic> params) async {
    return await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_mergeCoins', params: params));
  }

  paySuiCoins(List<dynamic> params) async {
    return await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_pay', params: params));
  }

  suiMoveCall(List<dynamic> params) async {
    return await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_moveCall', params: params));
  }

  //sui_getEventsBySender
  suigetEventsBySender(List<dynamic> params) async {
    return await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_getEventsBySender', params: params));
  }
   //发送sui交易
  Future<SuiTansaction> suiExecuteTransaction(String address, List<dynamic> params) async {
    final response = await _apiServiceCurrent.post('/', SuiRequest(method: 'sui_executeTransaction', params: params));
    // print("response = " + response.data.toString());
    return transformTransactionRes(response.data, address);
  }
  //发送sui交易 不返回值
  suiExecuteTransactionWithoutReturn(String address, List<dynamic> params) async {
    final response = await _apiServiceCurrent.postWithoutReturn('/', SuiRequest(method: 'sui_executeTransaction', params: params));
    // print("response = " + response.data.toString());
    // transformTransactionRes(response.data, address);
  }
}

class UserData {
  final String account;
  final String memo;
  final String sign;

  UserData({required this.account, required this.memo, required this.sign});
}

class SuiObject {
  final String type;
  final String dataType;
  final bool hasPublicTransfer;
  final Map<dynamic, dynamic> fields;

  SuiObject({required this.type, required this.dataType, required this.hasPublicTransfer, required this.fields});
}

class SuiTansaction {
  // final num seq;
  final String txId;
  final String status;
  final num txGas;
  final String kind;
  final String from;
  final String error;
  final int timestampMs;
  final bool isSender;
  final num amount;
  final String recipient;

  SuiTansaction(
      {
      // required this.seq,
      required this.txId,
      required this.status,
      required this.txGas,
      required this.kind,
      required this.from,
      required this.error,
      required this.timestampMs,
      required this.isSender,
      required this.amount,
      required this.recipient});
}

// class MoveCallTransaction {
//   final String packageObjectId;
//   final String module;
//   final String function;
//   final List<String> typeArguments;
//   final List<String> arguments;
//   final String? gasPayment; //objId
//   final num gasBudget;
//
//   MoveCallTransaction(
//       {required this.packageObjectId,
//       required this.module,
//       required this.function,
//       required this.typeArguments,
//       required this.arguments,
//       this.gasPayment,
//       required this.gasBudget});
// }
