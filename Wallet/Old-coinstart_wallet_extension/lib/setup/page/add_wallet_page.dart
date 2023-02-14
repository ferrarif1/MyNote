import 'dart:ui';
import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
class AddWalletPage extends StatefulWidget {
  final Map? arguments;
  const AddWalletPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {


  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/RegisterPage';
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
        body:GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
              color: const Color.fromRGBO(1, 6, 9, 1),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Stack(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        color: Colors.black,
                        child: Image(image: const AssetImage("assets/images/index_bg_image.png"),fit: BoxFit.contain,width:MediaQuery.of(context).size.width,),
                      ),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRect(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Padding(
                                  padding:const EdgeInsets.all(10),
                                  child: Stack(
                                    children: [
                                      const Image(image: AssetImage("assets/images/index_icon.png"),fit: BoxFit.contain,width: 124,height: 124,),
                                      BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 0.4,sigmaY: 0.4),
                                        child: const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40,),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                                child: const Text("Welcome to ",style: TextStyle(fontSize: 18,color: Colors.white),),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                child: const Text("coinstart wallet",style: TextStyle(fontSize: 28,color: Colors.white,fontWeight: FontWeight.w600),),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: (){
                                  Navigator.pushNamed(context, "/CreateNewWalletPage",arguments: {
                                    "AddWallet" : "true",
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: APP_MainPurpleColor,
                                    borderRadius: BorderRadius.all(Radius.circular(7.0)),
                                  ),
                                  // padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                  // margin: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                  height: 46,
                                  width: 300,
                                  alignment: Alignment.center,
                                  child: Text(S.current.Create_new_wallet,style: const TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.w700),),
                                ),
                              ),
                              const SizedBox(height: 10,),
                              InkWell(
                                onTap: (){
                                  Navigator.pushNamed(context, "/ImportWalletPage",arguments: {
                                    "AddWallet" : "true",
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(width: 1, color: APP_MainPurpleColor),
                                    borderRadius: const BorderRadius.all(Radius.circular(7.0)),
                                  ),
                                  height: 46,
                                  width: 300,
                                  // padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                  // margin: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                  alignment: Alignment.center,
                                  child: Text(S.current.Import_existing_wallet,style: const TextStyle(fontSize: 14,color: APP_MainPurpleColor,fontWeight: FontWeight.w700),),
                                ),
                              ),
                              const SizedBox(height: 40,),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child:  Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(3.0)),
                          ),
                          child: const Icon(Icons.chevron_left,color: Colors.white,),
                        ),
                    ),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }
}

