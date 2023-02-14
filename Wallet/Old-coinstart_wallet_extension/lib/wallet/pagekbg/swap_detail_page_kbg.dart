import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neveruseless/never/neverDoubleTryOrZero.dart';
import 'package:date_format/date_format.dart' as date_format;
import '../../Base/image_helper.dart';
import '../../base/Global.dart';
import '../../base/MyBotTextToast.dart';
import '../../generated/l10n.dart';
import '../../main.dart';

class SwapRecordDetailPageNew extends StatefulWidget {
  final Map? arguments;

  SwapRecordDetailPageNew({super.key, this.arguments});

  @override
  State<StatefulWidget> createState() => _SwapRecordDetailPageStateNew();

}

class _SwapRecordDetailPageStateNew extends State<SwapRecordDetailPageNew> {
  late SuiTansaction transactionItem;
  String coin = "SUI";
  final fonyMont14 = const TextStyle(fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontFamily: APP_FONT_MONTSERRAT);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PagePick.nowPageName = '/SwapRecordDetailPageNew';
    transactionItem = SuiTansaction(txId: '30001',
        status: 'success',
        txGas: 222,
        kind: '102678',
        from: '0x12dge474ccgejgighdigegildgeijilc3dadbgeiddxba',
        error: 'error',
        timestampMs: 112233212211,
        isSender: false,
        amount: 2000,
        recipient: 'test');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(S.current.Swap_Record_Details),),
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
                  style: const TextStyle(color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: APP_FONT_MONTSERRAT),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  "${(true ? "-" : "+")
                      + (NumUtil.getNumByValueDouble(neverDoubleTryOrZero("39001000000000") / 1000000000, 9)).toString()} $coin",
                  style: const TextStyle(color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700, fontFamily: APP_FONT_DDIN),
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
                        transactionItem.status == "success" ? S.current
                            .Success : S.current.Fail,
                        style: TextStyle(
                            color:  transactionItem.status == "success" ? APP_MainGreenColor: APP_MainRedColor, fontSize: 15, fontWeight: FontWeight.w400,fontFamily: APP_FONT_MONTSERRAT),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 20,
              ),
              const Divider(
                height: 1,
                color: APP_MainGrayDivideColor,
              ),
              const SizedBox(height: 17),
              getRowWith(S.current.Select_transfer_network, coin),
              const SizedBox(height: 15),
              getRowWith(S.current.Token_name, coin),
              const SizedBox(height: 15),
              getRowWith(S.current.Quantity, '3900'),
              const SizedBox(height: 15),
                getAddresRowWith(S.current.Receive_Address, '0x12dge474ccgejgighdigegildgeijilc3dadbgeiddxba'),
              const SizedBox(height: 15),
                getAddresRowWith(S.current.Send_Address, '0x12dge474ccgejgighdigegildgeijilc3dadbgeiddxba'),
              const SizedBox(height: 15),
              getRowWith(S.current.Date, '2021-10-22 12:30:32'),
              const SizedBox(height: 15)],)],
        )));
  }

  Widget getRowWith(String title , String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: fonyMont14,
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: Text(
            content,
            style: fonyMont14,
          ),
        ),
      ],
    );
  }
  Widget getAddresRowWith(String title , String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: fonyMont14,
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: content));
              showMyCustomCopyText(S.current.Copy_successfully);
            },
            child: Container(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        content,
                        style:  const TextStyle(fontSize: 12,
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
    );
  }
}