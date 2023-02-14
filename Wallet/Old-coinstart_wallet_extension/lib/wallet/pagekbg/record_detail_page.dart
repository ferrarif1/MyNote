import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neveruseless/never/neverDoubleTryOrZero.dart';
import 'package:date_format/date_format.dart' as date_format;
import '../../Base/image_helper.dart';
import '../../base/Global.dart';
import '../../base/MyBotTextToast.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../page/sui_transaction_controller.dart';

class RecordDetailPage extends StatefulWidget {
  final Map? arguments;

  RecordDetailPage({super.key, this.arguments});

  @override
  State<StatefulWidget> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late SuiTansaction transactionItem;
  String coin = "SUI";
  final fonyMont14 = const TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontFamily: APP_FONT_MONTSERRAT);
  SuiTransactionController controller = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PagePick.nowPageName = '/RecordDetailPage';
    int index = widget.arguments?['index'] as int;
    bool isSend = widget.arguments?['isSend'] as bool;
    transactionItem = isSend
        ? controller.getTransactionSend(index)
        : controller.getTransactionReceive(index);

    // transactionItem = SuiTansaction(txId: '30001',
    //     status: 'success',
    //     txGas: 222,
    //     kind: '102678',
    //     from: '0x12dge474ccgejgighdigegildgeijilc3dadbgeiddxba',
    //     error: 'error',
    //     timestampMs: 112233212211,
    //     isSender: false,
    //     amount: 2000,
    //     recipient: 'test');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(S.current.Transaction_details),
        ),
        body: Container(
            padding: const EdgeInsets.fromLTRB(26, 10, 26, 10),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        S.current.Quantity,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: APP_FONT_MONTSERRAT),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        "${!transactionItem.kind.contains("Pay") ? transactionItem.kind : ((transactionItem.isSender ? "-" : "+") + (NumUtil.getNumByValueDouble(neverDoubleTryOrZero(transactionItem.amount.toString()) / 1000000000, 9)).toString())} $coin",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            fontFamily: APP_FONT_DDIN),
                      ),
                    ),
                    Container(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        transactionItem.status == "success"
                            ? const ImageHelper(
                                "/images/create_account_success.png",
                                height: 15,
                              )
                            : const ImageHelper(
                                "/images/fall_icon.png",
                                height: 15,
                              ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          transactionItem.status == "success"
                              ? S.current.Success
                              : S.current.Fail,
                          style: TextStyle(
                              color: transactionItem.status == "success"
                                  ? APP_MainGreenColor
                                  : APP_MainRedColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontFamily: APP_FONT_MONTSERRAT),
                        ),
                      ],
                    )),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(
                      height: 2,
                      color: APP_MainGrayColor2,
                    ),
                    const SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            S.current.Network,
                            style: fonyMont14,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            coin,
                            style: fonyMont14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            S.current.Token_name,
                            style: fonyMont14,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            coin,
                            style: fonyMont14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            S.current.Quantity,
                            style: fonyMont14,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                              NumUtil.getNumByValueDouble(neverDoubleTryOrZero(transactionItem.amount.toString()) / 1000000000, 9).toString(),
                            style: fonyMont14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            S.current.Send_Address,
                            style: fonyMont14,
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: transactionItem.from));
                              showMyCustomCopyText(S.current.Copy_successfully);
                            },
                            child: Container(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        transactionItem.from,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: APP_MainGrayColor3,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: APP_FONT_MONTSERRAT),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const ImageHelper(
                                      "/images/copy.png",
                                      width: 15,
                                      height: 15,
                                      color: APP_MainGrayColor3,
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            S.current.Receive_Address,
                            style: fonyMont14,
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: transactionItem.from));
                              showMyCustomCopyText(S.current.Copy_successfully);
                            },
                            child: Container(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        transactionItem.recipient,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: APP_MainGrayColor3,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: APP_FONT_MONTSERRAT),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const ImageHelper(
                                      "/images/copy.png",
                                      width: 15,
                                      height: 15,
                                      color: APP_MainGrayColor3,
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            S.current.Date,
                            style: fonyMont14,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            date_format.formatDate(
                                DateTime.fromMillisecondsSinceEpoch(
                                    transactionItem.timestampMs),
                                [
                                  date_format.yyyy,
                                  '-',
                                  date_format.mm,
                                  '-',
                                  date_format.dd,
                                  ' ',
                                  date_format.HH,
                                  ':',
                                  date_format.nn,
                                  ':',
                                  date_format.ss
                                ]),
                            style: fonyMont14,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            )));
  }
}
