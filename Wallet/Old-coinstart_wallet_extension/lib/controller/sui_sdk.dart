import '../api/sui_api.dart';
import 'json.dart';

const coinType = '0x2::coin::Coin';
const coinSuiType = '0x2::sui::SUI';
const suiAddressLength = 20;
const defaultGasBudgetForMoveCall = 18000;
const defaultGasBudgetForSplit = 1000;
const defaultGasBudgetForMerge = 500;
const defaultGasBudgetForTransferSUI = 100;

RegExp coinTypeArgRegExp = RegExp(r'^0x2::coin::Coin<(.+)>$');

final txKindToTxt = {
  'TransferObject': 'Object transfer',
  'Call': 'Call',
  'Publish': 'Publish',
  'TransferSui': 'Sui transfer',
  'ChangeEpoch': 'Change epoch',
};

bool isCoin(type) {
  return type.startsWith(coinType);
}

bool isSuiCoin(type) {
  return type == '0x2::coin::Coin<$coinSuiType>';
}

bool isValidSuiAddress(String value) {
  return isHex(value) && getHexByteLength(value) == suiAddressLength;
}

bool isHex(String value) {
  return RegExp(r'^(0x|0X)?[a-fA-F0-9]+$').hasMatch(value) &&
      value.length % 2 == 0;
}

num getHexByteLength(String value) {
  return RegExp(r'/^(0x|0X)/').hasMatch(value)
      ? (value.length - 2) / 2
      : value.length / 2;
}

getCoinId(SuiObject obj) {
  return obj.fields['id']?['id'] ?? '';
}

//返回第二大的
coinsToMerge(List<SuiObject> coins) {
  if (coins.length <= 1) {
    return Null;
  }
  coins.sort((a, b) {
    return (a).fields['balance'] - (b).fields['balance'] > 0 ? 1 : -1;
  });
  return coins[coins.length - 2];
}

checkIfAmountIsENoughAfterMerge(SuiObject a, SuiObject b, int amount, int gas) {
  return (a).fields['balance'] + (b).fields['balance'] - gas - gas > amount
      ? 1
      : -1; //两个gas，一个是merge交易的，一个是send交易的
}

checkIfMergeIsNeed(List<SuiObject> coins, amount) {
  // prepareCoinWithEnoughBalance

  // Sort coins by balance in an ascending order
  coins.sort((a, b) {
    return (a).fields['balance'] - (b).fields['balance'] > 0 ? 1 : -1;
  });

  // return the coin with the smallest balance that is greater than or equal to the amount
  final coinWithSufficientBalance = coins.firstWhere(
    (c) => (c).fields['balance'] >= amount,
    orElse: () =>
        SuiObject(type: '', dataType: '', hasPublicTransfer: false, fields: {}),
  );
  if (coinWithSufficientBalance.type != '') {
    return false;
  }
  return true;
}

prepareCoinWithEnoughBalance(
  List<SuiObject> coins,
  amount,
) {
  // prepareCoinWithEnoughBalance

  // Sort coins by balance in an ascending order
  coins.sort((a, b) {
    return (a).fields['balance'] - (b).fields['balance'] > 0 ? 1 : -1;
  });

  // return the coin with the smallest balance that is greater than or equal to the amount
  final coinWithSufficientBalance = coins.firstWhere(
    (c) => (c).fields['balance'] >= amount,
    orElse: () =>
        SuiObject(type: '', dataType: '', hasPublicTransfer: false, fields: {}),
  );
  if (coinWithSufficientBalance.type != '') {
    return coinWithSufficientBalance;
  }

  // merge coins to have a coin with sufficient balance
  // we will start from the coins with the largest balance
  // and end with the coin with the second smallest balance(i.e., i > 0 instead of i >= 0)
  // we cannot merge coins with the smallest balance because we
  // need to have a separate coin to pay for the gas
  // TODO: there's some edge cases here. e.g., the total balance is enough before spliting/merging
  // but not enough if we consider the cost of splitting and merging.

  var primaryCoin = coins[coins.length - 1];

  for (int i = coins.length - 2; i > 0; i--) {
    final transaction = {
      'primaryCoin': getCoinId(primaryCoin),
      'coinToMerge': getCoinId(coins[i]),
      'gasBudget': defaultGasBudgetForMerge,
    };
  }

  return primaryCoin;
}


prepareCoinsWithEnoughTotalBalance(
  List<SuiObject> coins,
  amount,
) {
  // prepareCoinWithEnoughBalance
  
  // 降序
  coins.sort((a, b) {
    return (a).fields['balance'] - (b).fields['balance'] < 0 ? 1 : -1;
  });
  
  //1. single obj: return the coin with the smallest balance that is greater than or equal to the amount
  final coinWithSufficientBalance = coins.firstWhere(
    (c) => (c).fields['balance'] >= amount,
    orElse: () =>
        SuiObject(type: '', dataType: '', hasPublicTransfer: false, fields: {}),
  );
  if (coinWithSufficientBalance.type != '') {
    return [coinWithSufficientBalance];
  }
  //2. multi obj: 
  List<SuiObject> usecoins = [];
  num totalbalances=0;
  for (var ccc in coins) {
        totalbalances += (ccc).fields['balance'];
        usecoins.add(ccc);
        if(totalbalances > amount){
           return usecoins;
        }
  }
  return usecoins;
}
