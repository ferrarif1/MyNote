import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
class ViewMnemonicPage extends StatefulWidget {
  final Map? arguments;
  const ViewMnemonicPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _ViewMnemonicPageState();
}

class _ViewMnemonicPageState extends State<ViewMnemonicPage> {

  String mnemonic = "";
  List<String>? mnemonicList;
  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/ViewMnemonicPage';
    mnemonic = widget.arguments!["mnemonic"];
    mnemonicList = mnemonic.split(" ");
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
          appBar: AppBar(
            title: Text(S.current.View_mnemonics),
          ),
          body:ListView(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(48, 48, 48, 1),
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
                margin: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                padding:const EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: Column(
                  children: [
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 6,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 20,
                      children: List.generate(12, (index) {
                        return Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('${index + 1}', style: const TextStyle(color: Color.fromRGBO(158, 157, 157,1),),),
                                const SizedBox(width: 20),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(0 , 0, 0, 5),
                                  child: SelectableText(mnemonicList![index], style: const TextStyle(color: Colors.white),),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: (){
                          Clipboard.setData(ClipboardData(text: mnemonic));
                          showMyCustomCopyText(S.current.Copy_successfully);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 68,
                          height: 32,
                          alignment: Alignment.center,
                          // padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: const BoxDecoration(
                            color: APP_MainBgViewColor,
                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          ),
                          child: Text(S.current.Copy,style: const TextStyle(fontSize: 14,color: Colors.white),),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}

