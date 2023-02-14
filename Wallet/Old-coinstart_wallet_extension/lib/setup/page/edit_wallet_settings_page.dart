import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/controller/sui_wallet_controller.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:neveruseless/neveruseless.dart';
import '../../main.dart';

class EditWalletSettingPage extends StatefulWidget {
  final Map? arguments;
  const EditWalletSettingPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _EditWalletSettingPageState();
}

class _EditWalletSettingPageState extends State<EditWalletSettingPage> {

  SuiWallet? _data;

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/EditWalletSettingPage';
    _data = widget.arguments!["data"];
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
          title: Text(S.current.The_Wallet_Details),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.24),
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                ),
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Row(
                  children: [
                    Container(
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
                        child: Text(_data!.name!,style: TextStyle(fontSize: 14,color: Colors.white),),
                      ),
                    ),
                  ],
                ),
              ),
              // InkWell(
              //   onTap: () async{
              //     final TextEditingController pwdController = TextEditingController();
              //     String pwd = await neverLocalStorageRead("LocalPassword");
              //     showModalBottomSheet(
              //       isScrollControlled: true,
              //       backgroundColor: Colors.transparent,
              //       context: context,
              //       builder: (context){
              //         return Container(
              //           height: 220,
              //           decoration: const BoxDecoration(
              //             color: Color.fromRGBO(20, 21, 26, 1),
              //             borderRadius: BorderRadius.all(Radius.circular(10.0)),
              //           ),
              //           alignment: Alignment.centerLeft,
              //           child: Column(
              //             children: [
              //               Container(
              //                 padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
              //                 child: Row(
              //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                   children: [
              //                     Text(S.current.Please_input_password, style: const TextStyle(color: Colors.white,fontSize: 13),),
              //                     GestureDetector(
              //                       onTap: (){
              //                         Navigator.of(context).pop();
              //                       },
              //                       child: Container(
              //                         // color: Colors.white,
              //                         padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              //                         alignment: Alignment.centerRight,
              //                         child: const Icon(Icons.close,color: Colors.white,size: 20,),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //               const Divider(height: 2,color: APP_MainGrayColor,),
              //               Container(
              //                 padding:const EdgeInsets.fromLTRB(20, 20, 20, 20),
              //                 child: TextField(
              //                   controller: pwdController,
              //                   obscureText:true,
              //                   cursorColor: const Color(0xFF584ED3),
              //                   style: const TextStyle(color: Colors.white,fontSize: 15,textBaseline: TextBaseline.alphabetic),
              //                   decoration: InputDecoration(
              //                     isDense: true,
              //                     contentPadding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              //                     fillColor: Colors.white.withOpacity(0.05),
              //                     filled: true,
              //                     border: OutlineInputBorder(
              //                       borderRadius: BorderRadius.circular(5),
              //                       borderSide: const BorderSide(
              //                         width: 0,
              //                         style: BorderStyle.none,
              //                       ),
              //                     ),
              //                   ),
              //                   maxLines: 1,
              //                 ),
              //               ),
              //               const Expanded(child: SizedBox()),
              //               InkWell(
              //                 onTap: () async {
              //                   if(pwd == pwdController.text){
              //                     Navigator.pop(context);
              //                     String privateKey = suiWallet.getPrivateKey(pwdController.text);
              //                     Navigator.pushNamed(context, "/ViewPrivateKeyPage",arguments: {
              //                       "privateKey" : privateKey,
              //                     });
              //                   }else{
              //                     showMyCustomText(S.current.Wrong_Password);
              //                   }
              //                 },
              //                 child: Container(
              //                   decoration: const BoxDecoration(
              //                     color: APP_MainPurpleColor,
              //                     borderRadius: BorderRadius.all(Radius.circular(5.0)),
              //                   ),
              //                   child: Container(
              //                       width: 340,
              //                       height: 48,
              //                       alignment: Alignment.center,
              //                       child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontSize: 16,),
              //                       )
              //                   ),
              //                 ),
              //               ),
              //               const SizedBox(height: 20,),
              //             ],
              //           ),
              //         );
              //       },
              //     );
              //   },
              //   child:Container(
              //     padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(S.current.View_private_key, style: const TextStyle(color: Colors.white,fontSize: 13),),
              //         const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,size: 14,)
              //       ],
              //     ),
              //   ),
              // ),
             // const Divider(height: 1,color: Colors.grey,),
              InkWell(
                onTap: () async{
                  final TextEditingController pwdController = TextEditingController();
                  String pwd = await neverLocalStorageRead("LocalPassword");
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context){
                      return Container(
                        height: 220,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(20, 21, 26, 1),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(S.current.Please_input_password, style: const TextStyle(color: Colors.white,fontSize: 13),),
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
                            Container(
                              padding:const EdgeInsets.fromLTRB(20, 20, 20, 20),
                              child: TextField(
                                controller: pwdController,
                                obscureText:true,
                                cursorColor: const Color(0xFF584ED3),
                                style: const TextStyle(color: Colors.white,fontSize: 15,textBaseline: TextBaseline.alphabetic),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                                  fillColor: Colors.white.withOpacity(0.05),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                ),
                                maxLines: 1,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            InkWell(
                              onTap: () async {
                                if(pwd == pwdController.text){
                                  Navigator.pop(context);
                                  String mnemonic = suiWallet.decryptMnemonic("display",pwdController.text);
                                  Navigator.pushNamed(context, "/ViewMnemonicPage",arguments: {
                                    "mnemonic" : mnemonic,
                                  });
                                }else{
                                  showMyCustomText(S.current.Wrong_Password);
                                }
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: APP_MainPurpleColor,
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                child: Container(
                                    width: 340,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontSize: 16,),
                                    )
                                ),
                              ),
                            ),
                            const SizedBox(height: 20,),
                          ],
                        ),
                      );
                    },
                  );
                },
                child:Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.current.View_mnemonics, style: const TextStyle(color: Colors.white,fontSize: 13),),
                      const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,size: 14,)
                    ],
                  ),
                ),
              ),
              const Divider(height: 1,color: Colors.grey,),
              const Expanded(child: SizedBox()),
              InkWell(
                onTap: () async {
                  if(suiWallet.wallets.length == 1){
                    showMyCustomText("This is the last wallet that cannot be deleted");
                    return;
                  }else{
                    suiWallet.deleteWallet(_data!.name!);
                    Navigator.pop(context,{
                      "name" : _data!.name!,
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(width: 1, color: Colors.red),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Container(
                      width: 340,
                      height: 48,
                      alignment: Alignment.center,
                      child: Text(S.current.Delete_Wallet, style: const TextStyle(color: Colors.red, fontSize: 16,),
                      )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}