import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../main.dart';
class SelectParaPage extends StatefulWidget {
  final Map? arguments;
  const SelectParaPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _SelectParaPageState();
}

class _SelectParaPageState extends State<SelectParaPage> {



  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/SelectParaPage';
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
                  setState(() {
                    localPara = "CNY";
                  });
                },
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text("CNY",style: TextStyle(fontSize: 14,color: Colors.white),),
                        ),
                        localPara == "CNY" ? const Image(image: AssetImage("assets/images/netword_done.png"),width: 16,height: 16,) : const SizedBox(width: 16,height: 16,),
                      ],
                    )
                ),
              ),
              const Divider(height: 1,color: Colors.grey,),
              InkWell(
                onTap: (){
                  setState(() {
                    localPara = "USD";
                  });
                },
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text("USD",style: TextStyle(fontSize: 14,color: Colors.white),),
                        ),
                        localPara == "USD" ? const Image(image: AssetImage("assets/images/netword_done.png"),width: 16,height: 16,) : const SizedBox(width: 16,height: 16,),
                      ],
                    )
                ),
              ),
              const Divider(height: 1,color: Colors.grey,),
              InkWell(
                onTap: (){
                  setState(() {
                    localPara = "BRL";
                  });
                },
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text("BRL",style: TextStyle(fontSize: 14,color: Colors.white),),
                        ),
                        localPara == "BRL" ? const Image(image: AssetImage("assets/images/netword_done.png"),width: 16,height: 16,) : const SizedBox(width: 16,height: 16,),
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