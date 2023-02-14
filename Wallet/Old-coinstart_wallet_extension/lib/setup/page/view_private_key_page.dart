import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
class ViewPrivateKeyPage extends StatefulWidget {
  final Map? arguments;
  const ViewPrivateKeyPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _ViewPrivateKeyPageState();
}

class _ViewPrivateKeyPageState extends State<ViewPrivateKeyPage> {

  String privateKey = "";

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/ViewPrivateKeyPage';
    privateKey = widget.arguments!["privateKey"];
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
          title: Text(S.current.View_private_key),
        ),
        body:ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.24),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: Image(image: const AssetImage("assets/images/coinstart_logo_white.png"),width: 26,height: 26, fit: BoxFit.contain,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return Container(
                            width: 26,height: 26,
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: Icon(Icons.sms_failed_rounded,color: Colors.grey.withOpacity(0.2),),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Acc",style: TextStyle(fontSize: 16,color: Colors.white),),
                          SizedBox(height: 10,),
                          Text(privateKey,style: TextStyle(fontSize: 11,color: APP_MainTextGrayColor),),
                        ],
                      )
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      Clipboard.setData(ClipboardData(text: privateKey));
                      showMyCustomCopyText(S.current.Copy_successfully);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: const ImageHelper("/images/copy.png",width: 16,height: 16,),
                    )
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

