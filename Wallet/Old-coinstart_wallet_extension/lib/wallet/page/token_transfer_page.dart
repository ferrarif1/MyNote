import 'dart:async';
import 'dart:math';

import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/api/eth_api.dart';
import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:coinstart_wallet_extension/api/sui_sdk.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:coinstart_wallet_extension/controller/eth_locator.dart';
import 'package:coinstart_wallet_extension/controller/format.dart';
import 'package:coinstart_wallet_extension/controller/networks.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:neveruseless/neveruseless.dart';
import 'package:ones/extension/string_ex.dart';
import 'package:web3dart/web3dart.dart';

import '../../main.dart';

class TokenTransferPage extends StatefulWidget {
  final Map? arguments;

  const TokenTransferPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _TokenTransferPageState();
}

class _TokenTransferPageState extends State<TokenTransferPage> {
  String localPwa = "";

  final TextEditingController addrController = TextEditingController();

  final TextEditingController amountController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  String coin = "";

  String feeUser = "-";


  List allCoinList = [
    "ETH",
    "SUI",
    "AVAX",
    "BNB",
    "FIL",
    "OKX",
    "SNX",
    "TRX",
    "USDT",
  ];

  validateAmount(String val) {
    if (val.isEmpty) {
      return 'Amount is a required field';
    }
    if (val.isNotEmpty && int.parse(val) > suiWallet.primaryCoinBalance.value - suiWallet.gasDefault.value) {
      return 'Amount must be less than ${moneyFormat(suiWallet.primaryCoinBalance.value - suiWallet.gasDefault.value)} SUI';
    }

    if (val.isNotEmpty && int.parse(val) == 0) {
      return 'Amount must be greater than or equal to 1 SUI';
    }
  }

  validateSuiAddress(String val) {
    if (val.isEmpty) {
      return '''Recipient's address is a required field''';
    }
    if (!isValidSuiAddress(val.replaceAll(RegExp(r'^0x'), ''))) {
      return 'Invalid address. Please check again.';
    }
  }

  void loadPwa() async {
    localPwa = await neverLocalStorageRead("LocalPassword");
  }

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/TokenTransferPage';
    coin = widget.arguments!["coin"];
    loadPwa();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    suiWallet.getBalance();
    suiWallet.getOwnedObjectBatch();
    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.current.Token_Send),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(20, 21, 26, 1),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        height: 500,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    S.current.Select_transfer_network,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      // color: Colors.white,
                                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      alignment: Alignment.centerRight,
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 2,
                              color: APP_MainGrayColor,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: allCoinList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        coin = allCoinList[index];
                                        Navigator.pop(context);
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            ImageHelper(
                                              '/icons/crypto/${allCoinList[index]}.png',
                                              height: 30,
                                              width: 30,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              allCoinList[index],
                                              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ));
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(53, 54, 58, 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            ImageHelper(
                              '/icons/crypto/$coin.png',
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(width: 13),
                            Text(
                              coin,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Standard: $coin',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.current.Address,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(53, 54, 58, 1),
                        border: Border.all(color: Colors.grey[800]!),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: TextField(
                        controller: addrController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: S.current.Enter_Receiving_Address(coin),
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                          border: InputBorder.none,
                        ),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Text(S.current.Amount, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(53, 54, 58, 1),
                        border: Border.all(color: Colors.grey[800]!),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: TextField(
                        controller: amountController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: S.current.Enter_Receiving_Number,
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                          border: InputBorder.none,
                          suffixIcon: SizedBox(
                            width: 60,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  num feeMax = suiWallet.suiEstimateFee(suiWallet.suiBalance);
                                  num sendMax = suiWallet.suiBalance - feeMax;
                                  feeUser = feeMax.toString();
                                  amountController.text = (NumUtil.getNumByValueDouble((neverDoubleTryOrZero(sendMax.toString()) / 1000000000), 9)).toString();
                                });
                              },
                              child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(149, 97, 216, 0.3),
                                    borderRadius: BorderRadius.all(Radius.circular(3.0)),
                                  ),
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                  child: const Text(
                                    'MAX',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        onChanged: (e) {
                          setState(() {
                            if (e == "") {
                              feeUser = "-";
                            } else {
                              feeUser = suiWallet.suiEstimateFee(int.tryParse((neverDoubleTryOrZero(amountController.text) * 1000000000).toString()) ?? 0).toString();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                  child: Row(
                    children: [
                      const Text("Available: ", style: TextStyle(color: Colors.white, fontSize: 12)),
                      Text('${suiWallet.currentBalance} $coin', style: const TextStyle(color: APP_MainBgViewColor, fontSize: 12)),
                    ],
                  )),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[800]!),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fee',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    Text(feeUser, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: ElevatedButton(
                  onPressed: () async {
                    if (addrController.text.isEmpty) {
                      showMyCustomText(S.current.Enter_Receiving_Address(coin));
                      return;
                    }
                    if (amountController.text.isEmpty) {
                      showMyCustomText(S.current.Enter_Receiving_Number);
                      return;
                    }
                    final TextEditingController passwordController = TextEditingController();
                    bool canPasswordSee = false;
                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(20, 21, 26, 1),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          height: 200,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.current.Please_enter_transaction_password,
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        // color: Colors.white,
                                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        alignment: Alignment.centerRight,
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 2,
                                color: APP_MainGrayColor,
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  cursorColor: const Color(0xFF584ED3),
                                  style: const TextStyle(color: Colors.white, fontSize: 15, textBaseline: TextBaseline.alphabetic),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                                    fillColor: Colors.white.withOpacity(0.05),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (passwordController.text.isEmpty) {
                                      showMyCustomText(S.current.Please_input_password);
                                      return;
                                    }

                                    if (passwordController.text != localPwa) {
                                      showMyCustomText(S.current.Wrong_Password);
                                      return;
                                    }

                                    Navigator.pop(context);

                                    showMyCustomLoading(S.current.Please_Wait);

                                    var index = await neverLocalStorageRead('network');
                                    var network = networks[index != 'null' ? index.toString().toInt() : 0];
                                    switch (network.name) {
                                      case 'SUI':
                                        final result = await sendCoinsNow(passwordController.text);
                                        final address = result?.recipient;
                                        final amount = result?.amount;
                                        Future.delayed(const Duration(milliseconds: 500)).then((onValue) async {
                                          if (result?.status == 'success') {
                                            closeMyCustomBotLoading();
                                            showMyCustomText("Transfer success!");
                                          } else {
                                            closeMyCustomBotLoading();
                                            showMyCustomText("Transfer failed!");
                                          }
                                        });
                                        break;
                                      case 'ETHMAINNET':
                                        break;
                                      case 'GOERLI':
                                        var isSuccess = await sendETH(passwordController.text);
                                        Future.delayed(const Duration(milliseconds: 500)).then((onValue) async {
                                          if (isSuccess) {
                                            closeMyCustomBotLoading();
                                            showMyCustomText("Transfer success!");
                                          } else {
                                            closeMyCustomBotLoading();
                                            showMyCustomText("Transfer failed!");
                                          }
                                        });
                                        break;
                                      case 'BSC':
                                      case 'BSCTEST':
                                      case 'POLYGON':
                                      case 'KLAYTN':
                                      case 'KLAYTN_BAOBAB':
                                      case 'ASTAR':
                                        suiWallet.currentWalletAddress(suiWallet.wallets.first.ethaddress);
                                        break;
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: APP_MainBgViewColor,
                                    foregroundColor: APP_MainBgViewColor,

                                    minimumSize: const Size(360, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                    ), // NEW
                                  ),
                                  child: Text(
                                    S.current.Send,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: APP_MainBgViewColor,
                    foregroundColor: APP_MainBgViewColor,
                    minimumSize: const Size(360, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ), // NEW
                  ),
                  child: Text(
                    S.current.Confirm,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<SuiTansaction?> sendCoinsNow(String pwd) async {
    String address = addrController.text;
    int amount = int.tryParse((neverDoubleTryOrZero(amountController.text) * 1000000000).toString()) ?? 0;
    print("am = " + amount.toString());

    return await suiWallet.paySuiObjects(address, amount, pwd);
  }

  sendETH(String pwd) async {
    print("send eth start");
    final completer = Completer<bool>();

    String receiver = addrController.text;
    BigInt amount = BigInt.from(double.parse(amountController.text) * pow(10, 18));

    // final ContractLocator contractLocator = await ContractLocator.setup();
    int currentChainId = chainIdvalues[ChainId.GOERLI.index];
    final ethservice = ContractLocator.getInstance(currentChainId);
    final pk = await suiWallet.getEthPrivatekeyFromCurrentMnemonic(pwd);

    final receiverAddr = EthereumAddress.fromHex(receiver);

    await ethservice.sendETH(
      pk!,
      receiverAddr,
      amount,
      onTransfer: (from, to, value) {
        completer.complete(true);
      },
      onError: (ex) {
        print('send eth error');
        print(ex);
        completer.complete(false);
      },
    );

    return completer.future;
  }

}
