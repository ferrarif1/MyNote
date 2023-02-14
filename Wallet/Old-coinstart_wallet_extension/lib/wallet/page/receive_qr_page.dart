import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
class ReceiveQRPage extends StatefulWidget {
  final Map? arguments;
  const ReceiveQRPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _ReceiveQRPageState();
}

class _ReceiveQRPageState extends State<ReceiveQRPage> {
  String coin = "";
  String address = "";

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/ReceiveQRPage';
    coin = widget.arguments!["coin"];
    if(widget.arguments?["address"]!=null){
      address = widget.arguments?["address"];
    }

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
            title: Text(S.current.Receive),
          ),
          body:Container(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: const BoxDecoration(
                  color: APP_MainBgViewColor,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      alignment: Alignment.center,
                      child: ImageHelper('/icons/crypto/$coin.png', width: 60, height: 60,),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Text("$coin  ${S.current.Collection}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Text("${S.current.Collection_network} SUI", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      width: 220,
                      height: 220,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: QrImage(
                        data: address,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                      alignment: Alignment.center,
                      child: Text(address, style: const TextStyle(color: Colors.white, fontSize: 14,),maxLines: 3,
                        textAlign: TextAlign.center,),
                    ),
                    GestureDetector(
                      onTap: (){
                        Clipboard.setData(ClipboardData(text: address));
                        showMyCustomCopyText(S.current.Copy_successfully);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          //边框圆角设置
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                        ),
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        alignment: Alignment.center,
                        child: Text(S.current.Copy_Address,style: const TextStyle(color: Colors.white),),
                      ),
                    ),
                  ],
                ),
              )
          )
      ),
    );
  }
}


