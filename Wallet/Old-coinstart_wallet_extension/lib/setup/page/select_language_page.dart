import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/controller/sui_wallet_controller.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../main.dart';
class SelectLanguagePage extends StatefulWidget {
  final Map? arguments;
  const SelectLanguagePage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _SelectLanguagePageState();
}

class _SelectLanguagePageState extends State<SelectLanguagePage> {



  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/SelectLanguagePage';
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
          title: Text(S.current.Language),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: ListView(
            children: [
              InkWell(
                onTap: (){
                  neverBus.emit("checkLanguage","en");
                  setState(() {

                  });
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text("English",style: TextStyle(fontSize: 14,color: Colors.white),),
                      ),
                      localNow == "English" ? const Image(image: AssetImage("assets/images/netword_done.png"),width: 16,height: 16,) : const SizedBox(width: 16,height: 16,),
                    ],
                  )
                ),
              ),
              const Divider(height: 1,color: Colors.grey,),
              InkWell(
                onTap: (){
                  neverBus.emit("checkLanguage","zh");
                  setState(() {

                  });
                },
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text("中文简体",style: TextStyle(fontSize: 14,color: Colors.white),),
                        ),
                        localNow == "中文简体" ? const Image(image: AssetImage("assets/images/netword_done.png"),width: 16,height: 16,) : const SizedBox(width: 16,height: 16,),
                      ],
                    )
                ),
              ),
              const Divider(height: 1,color: Colors.grey,),
            ],
          ),
        ),
      ),
    );
  }
}