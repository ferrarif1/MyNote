import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
class SwapRecordDetailsPage extends StatefulWidget {
  final Map? arguments;
  const SwapRecordDetailsPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _SwapRecordDetailsPageState();
}

class _SwapRecordDetailsPageState extends State<SwapRecordDetailsPage> {

  String coin = "";

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/SwapRecordDetailsPage';
   // coin = widget.arguments!["coin"];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(20, 21, 26, 1),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      height: 500,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.current.Swap_Record_Details, style: const TextStyle(color: Colors.white,fontSize: 13),),
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    // color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.close,color: Colors.white,size: 20,),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 2,color: APP_MainGrayColor,),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
                  child: Text(S.current.Amount, style: const TextStyle(color: Colors.grey,fontSize: 13),),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                  child: Text("${(true ? "-" : "+")
                      + (NumUtil.getNumByValueDouble(neverDoubleTryOrZero("39001000000000") / 1000000000, 9)).toString()} $coin", style: const TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w600),),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      "success" == "success" ? const ImageHelper("/images/create_account_success.png",height: 15,)
                          : const ImageHelper("/images/fall_icon.png",height: 15,),
                      const SizedBox(width: 5,),
                      Text("success" == "success" ? S.current.Success : S.current.Fail, style: const TextStyle(color: Colors.grey,fontSize: 13),),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(20, 5, 10, 20),
                  child: const Text("The digital currency has been sent successfully, you can check the balance in the wallet", style: TextStyle(color: Colors.grey,fontSize: 11),),
                ),
                const Divider(height: 2,color: APP_MainGrayColor,),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(S.current.Transfer_network, style: const TextStyle(color: Colors.white,fontSize: 12),),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: const Text("SUI", style: TextStyle(color: Colors.white,fontSize: 12),),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(S.current.Sell_Away, style: const TextStyle(color: Colors.white,fontSize: 12),),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: const Text("20000 ETH", style: TextStyle(color: Colors.white,fontSize: 12),),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(S.current.Buy_In, style: const TextStyle(color: Colors.white,fontSize: 12),),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: const Text("200000000 UST", style: TextStyle(color: Colors.white,fontSize: 12),),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(S.current.Address,style: const TextStyle(fontSize: 12,color: Colors.white),),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            Clipboard.setData(const ClipboardData(text: "0x12dge474ccgejgighdigegildg eijilc3dadbgeiddxba"));
                            showMyCustomCopyText(S.current.Copy_successfully);
                          },
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                              alignment: Alignment.centerRight,
                              child: Row(
                                children: const [
                                  Expanded(
                                    child: Text("0x12dge474ccgejgighdigegildg eijilc3dadbgeiddxba"
                                      ,style: TextStyle(fontSize: 13,color: Colors.grey),textAlign: TextAlign.end,),
                                  ),
                                  SizedBox(width: 5,),
                                  ImageHelper("/images/copy.png",width: 10,height: 10,),
                                ],
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(S.current.Hash,style: const TextStyle(fontSize: 12,color: Colors.white),),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            Clipboard.setData(const ClipboardData(text: "0x12dge474ccgejgighdigegildg eijilc3dadbgeiddxba"));
                            showMyCustomCopyText(S.current.Copy_successfully);
                          },
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                              alignment: Alignment.centerRight,
                              child: Row(
                                children: const [
                                  Expanded(
                                    child: Text("0x12dge474ccgejgighdigegildg eijilc3dadbgeiddxba"
                                      ,style: TextStyle(fontSize: 13,color: Colors.grey),textAlign: TextAlign.end,),
                                  ),
                                  SizedBox(width: 5,),
                                  ImageHelper("/images/copy.png",width: 10,height: 10,),
                                ],
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(S.current.Date, style: const TextStyle(color: Colors.white,fontSize: 12),),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: const Text("2021-10-22 12:20:32", style: TextStyle(color: Colors.white,fontSize: 12),),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}