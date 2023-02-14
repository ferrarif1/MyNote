import 'dart:html';

import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/wallet/page/sui_transaction_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:date_format/date_format.dart' as date_format;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:neveruseless/never/neverDoubleTryOrZero.dart';
import 'package:neveruseless/never/neverLocalStorage.dart';
import 'package:ones/ui.dart';

import '../../controller/networks.dart';
import '../../controller/format.dart';
import '../../main.dart';

class RecordPage extends StatefulWidget {
  final Map? arguments;

  const RecordPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with SingleTickerProviderStateMixin {
  String coin = "";
  TextStyle gray2Monster14 = const TextStyle(fontSize: 14, color: APP_MainGrayColor2, fontFamily: APP_FONT_MONTSERRAT);
  final List tabs = ["Info", "Send", "Receive"];
  TabController? _tabController;

  var currentNetwork = networks[0];
  var controller  = Get.put(SuiTransactionController());

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/RecordPage';

    neverLocalStorageRead('network').then((value) {
      currentNetwork = networks[value != 'null' ? value.toString().toInt() : 0];
      setState(() {});
    });
    coin = widget.arguments!["coin"];
    suiWallet.getTxDigestForCurrentwallet();
    _getTxDigestForCurrentwallet();
    _tabController = TabController(length: tabs.length, vsync: this)
      ..addListener(() {
        if (_tabController!.index.toDouble() == _tabController!.animation!.value) {}
      });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }



  void _getTxDigestForCurrentwallet() async {
    await suiWallet.getTxDigestForCurrentwallet();
    final transactions = suiWallet.transactions;
    try {
      if (transactions.isNotEmpty) {
        controller.suiTansactionList = transactions.value as List<SuiTansaction>?;
      } else {
        controller.suiTansactionList = _getFakeTransactions();
      }
    } catch (e) {
      controller.suiTansactionList = [];
    }
    if (controller.suiTansactionList != null) {
      for (var trans in controller.suiTansactionList!) {
        if (trans.isSender) {
          controller.suiTansactionListSend.add(trans);
        } else {
          controller.suiTansactionListReceive.add(trans);
        }
      }
      setState(() {});
    }
  }
  List<SuiTansaction> _getFakeTransactions() {
    return [SuiTansaction(txId: '30001', status: 'success', txGas: 222, kind: '102678',
        from: 'from', error: 'error', timestampMs: 112233212211, isSender: false, amount: 2000, recipient: 'test'),
      SuiTansaction(txId: '30001', status: 'success', txGas: 222, kind: '102678',
          from: 'from', error: 'error', timestampMs: 112233212211, isSender: false, amount: 2000, recipient: 'test')];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(coin),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              alignment: Alignment.center,
              child: ImageHelper(
                '/icons/crypto/$coin.png',
                width: 70,
                height: 70,
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                (NumUtil.getNumByValueDouble(neverDoubleTryOrZero(suiWallet.suiBalance.toString()) / 1000000000, 9)).toString(),
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700, fontFamily: 'D-DIN'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                "\$${NumUtil.getNumByValueDouble(neverDoubleTryOrZero(suiWallet.suiBalance.toString()) / 1000000000, 9)}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontFamily: 'D-DIN'
                ),
              ),
            ),
      GestureDetector(
        onTap: () {
          Clipboard.setData(
              ClipboardData(text: suiWallet.currentWalletAddressFuzzyed.toString()));
          showMyCustomCopyText(S.current.Copy_successfully);
        },child:
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  suiWallet.currentWalletAddressFuzzyed.toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500,fontFamily: 'Montserrat'),
                ),
                const SizedBox(
                  width: 5,
                ),
                const ImageHelper(
                  "/images/copy.png",
                  width: 16,
                  height: 16,
                ),
              ],
            ).paddingSymmetric(horizontal: 24, vertical: 7).backgroundColor(const Color(0xff383838)).roundedRect(48)),

            Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              alignment: Alignment.centerLeft,
              child: TabBar(
                indicatorColor: APP_MainBgViewColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: APP_MainBgViewColor,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                unselectedLabelColor: const Color(0xffE5E5E5),
                controller: _tabController,
                tabs: tabs.map((e) => Tab(text: e)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                //构建
                controller: _tabController,
                children: tabs.map((e) {
                  if (e == "Info") {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                          alignment: Alignment.centerLeft,
                          child:  Text(
                            "Token info",
                            style: gray2Monster14,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    S.current.Token_name,
                                    style: gray2Monster14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    S.current.Project_name,
                                    style: gray2Monster14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    S.current.Total_circulation,
                                    style: gray2Monster14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  alignment: Alignment.centerLeft,
                                  child:  Text(
                                    "SUI",
                                    style: gray2Monster14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  alignment: Alignment.centerLeft,
                                  child:  Text(
                                    "SUI blockchain",
                                    style: gray2Monster14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  alignment: Alignment.centerLeft,
                                  child:  Text(
                                    "105 Million",
                                    style: gray2Monster14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Divider(
                          height: 1,
                          color: APP_MainGrayColor2,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("About $coin", style: const TextStyle(fontSize: 14, color: Colors.white, fontFamily: APP_FONT_MONTSERRAT, fontWeight: FontWeight.w600),),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Sui, a next-generation smart contract platform with high throughput, low latency, and an asset-oriented programming model powered by the Move programming language",
                            style: TextStyle(fontSize: 14, color: APP_MainGrayColor2, fontFamily: APP_FONT_MONTSERRAT, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    );
                  } else if (e == "Receive" || e == "Send") {
                    return getListView(e == "Send" ? controller.suiTansactionListSend : controller.suiTansactionListReceive);
                  } else {
                    return Container();
                  }
                }).toList(),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, "/TokenTransferPage", arguments: {
                          "coin": coin,
                        });
                      },
                      child: Container(
                        width: 106,
                        height: 48,
                        decoration: BoxDecoration(
                          color: APP_MainBgViewColor,
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child:  Center(
                          child: Text(
                            S.current.Send,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: APP_FONT_MONTSERRAT),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // push(context, const ShareAddressPage());
                        Navigator.pushNamed(context, "/ReceiveQRPage", arguments: {
                          "coin": coin,
                          // "allAdd" : suiWallet.currentWalletAddress.toString(),
                          // "lessAdd" : suiWallet.currentWalletAddressFuzzyed.toString()
                        });
                      },
                      child: Container(
                        width: 106,
                        height: 48,
                        decoration: BoxDecoration(
                          color: APP_MainBgViewColor,
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: Center(
                          child: Text(
                            S.current.Receive,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: APP_FONT_MONTSERRAT),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  ListView getListView(List<SuiTansaction> dataList) {
     return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        var item = dataList[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/RecordDetailPage", arguments: {
              "coin": coin,
              "index": index,
              "isSend": item.isSender
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child:  Text(
                        coin,
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700, fontFamily: APP_FONT_ROBOTO),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        date_format.formatDate(DateTime.fromMillisecondsSinceEpoch(dataList[index].timestampMs),
                            [date_format.yyyy, '-', date_format.mm, '-', date_format.dd, ' ', date_format.HH, ':', date_format.nn, ':', date_format.ss]),
                        style: const TextStyle(fontSize: 14, color: APP_MainGrayColor2, fontWeight: FontWeight.w500, fontFamily: APP_FONT_ROBOTO),
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          !item.kind.contains("Pay") ? item.kind : ((item.isSender ? "-" : "+") + (NumUtil.getNumByValueDouble(neverDoubleTryOrZero(item.amount.toString()) / 1000000000, 9)).toString()),
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500, fontFamily: APP_FONT_ROBOTO)),
                      ),
                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: dataList[index].status == "success" ? Colors.green : Colors.red,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              dataList[index].status == "success" ? S.current.Success : S.current.Fail,
                              style: TextStyle(fontSize: 14,
                                  color: dataList[index].status == "success" ? APP_MainGreenColor : APP_MainRedColor,
                                  fontWeight: FontWeight.w400, fontFamily: APP_FONT_ROBOTO),
                            ),
                          ],
                        ))
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
