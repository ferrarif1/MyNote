import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/wallet/page/swap_record_details_page.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
class SwapRecordPage extends StatefulWidget {
  final Map? arguments;
  const SwapRecordPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _SwapRecordPageState();
}

class _SwapRecordPageState extends State<SwapRecordPage> {

  final textMont14 = const TextStyle(color : Colors.white,fontSize: 14,fontWeight: FontWeight.w500, fontFamily: APP_FONT_MONTSERRAT);
  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/SwapRecordPage';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(title: Text(S.current.Swap_Record),),
        body:Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                itemBuilder: (context,index){
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (){
                      Navigator.pushNamed(context, "/SwapRecordDetailPageNew",arguments: {
                        "coin" : "SUI",
                        "data" : ""
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Text(index % 2 ==0 ? S.current.Swap_Successfully : S.current.Swap_Failed,
                                  style: TextStyle(color : index % 2 ==0 ? APP_MainGreenColor : APP_MainRedColor,fontSize: 14, fontFamily: APP_FONT_MONTSERRAT,fontWeight: FontWeight.w500),),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: const Text("2021-10-22 12:20:31", style: TextStyle(color : Colors.grey,fontSize: 14, fontFamily: APP_FONT_MONTSERRAT,fontWeight: FontWeight.w500),),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: const Image(image: AssetImage("assets/images/swap_record_icon.png"),height: 18,)
                              ),
                              Expanded(
                                child: Container(//swap_record_icon.png
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("ETH", style: textMont14),
                                            const SizedBox(height: 10,),
                                            Text("USDT", style: textMont14),
                                          ],
                                        ),
                                        const SizedBox(width: 20,),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:  [
                                            Text("30", style: textMont14),
                                            const SizedBox(height: 10,),
                                            Text("0.141414141", style: textMont14),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ),
                              Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                  child: const Icon(Icons.keyboard_arrow_right_rounded,color: Colors.white,size: 20,)
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (context,index){
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    child: Divider(height: 1,color: APP_MainGrayDivideColor),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}