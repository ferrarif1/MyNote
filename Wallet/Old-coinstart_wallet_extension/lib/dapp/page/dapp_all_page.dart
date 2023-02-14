import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
class DAppAllPage extends StatefulWidget {
  final Map? arguments;
  const DAppAllPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _DAppAllPageState();
}

class _DAppAllPageState extends State<DAppAllPage> {


  String type = "TOP";
  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/DAppAllPage';

    type = widget.arguments!["type"];
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
        body:Container(
          color: APP_MainBGColor,
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(34, 35, 39, 1),
                                borderRadius: BorderRadius.all(Radius.circular(3.0)),
                              ),
                              child: const Icon(Icons.chevron_left,color: Colors.white,),
                            ),
                            const SizedBox(width: 5,),
                            Text(type, style: const TextStyle(color: Colors.white, fontSize: 14),),
                          ],
                        )
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 20,
                  itemBuilder: (context,index){
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                          child: const Image(image: AssetImage("assets/icons/crypto/testIcon.png"),height: 35,width: 35,fit: BoxFit.contain,),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child:Row(
                                    children: const [
                                      Text("Art Blocks",style: TextStyle(fontSize: 13,color: Colors.white,fontWeight: FontWeight.w600),),
                                      SizedBox(width: 10,),
                                      Image(image: AssetImage("assets/icons/crypto/erc.png"),height: 10,),
                                    ],
                                  )
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                                child: const Text("The Lido Ethereum Liquid Staking Protocol, built on Ethereum 2.0's Beacon chain,",
                                  style: TextStyle(fontSize: 10,color: APP_MainGrayColor,fontWeight: FontWeight.w600),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}