import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
class WalletInfoPage extends StatefulWidget {
  final Map? arguments;
  const WalletInfoPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _WalletInfoPageState();
}

class _WalletInfoPageState extends State<WalletInfoPage> {

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/GeneralInfoPage';
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
          title: Text(S.current.Wallet_information),
        ),
        body:Column(
          children: [

            const SizedBox(height: 15),
            InkWell(
              hoverColor:Colors.white.withOpacity(0.2),
              onTap: () {

                final TextEditingController walletNameController = TextEditingController();

                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context){
                    return Container(
                      height: 200,
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
                                Text(S.current.Modify_wallet_name, style: const TextStyle(color: Colors.white,fontSize: 13),),
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
                              controller: walletNameController,
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
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: APP_MainBgViewColor,
                                foregroundColor: APP_MainBgViewColor,

                                minimumSize: const Size(360, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                ), // NEW
                              ),
                              child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );

              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.current.Modify_wallet_name, style: const TextStyle(color: Colors.white,fontSize: 13),),
                    const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,size: 14,)
                  ],
                ),
              ),
            ),
            InkWell(
              hoverColor:Colors.white.withOpacity(0.2),
              onTap: () async{

                final TextEditingController pwdController = TextEditingController();
                final TextEditingController privateKeyController = TextEditingController();
                String pwd = await neverLocalStorageRead("LocalPassword");
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context){
                    return Container(
                      height: 200,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () async {
                                if(pwd == pwdController.text){
                                  Navigator.pop(context);
                                  String privateKey = suiWallet.getPrivateKey(pwdController.text);
                                  privateKeyController.text = privateKey;
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context){
                                      return Container(
                                        height: 320,
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
                                                  Text(S.current.View_private_key, style: const TextStyle(color: Colors.white,fontSize: 13),),
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
                                                controller: privateKeyController,
                                                cursorColor: const Color(0xFF584ED3),
                                                style: const TextStyle(color: Colors.white,fontSize: 13,textBaseline: TextBaseline.alphabetic),
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
                                                maxLines: 4,
                                              ),
                                            ),
                                            const Expanded(child: SizedBox()),
                                            Container(
                                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                                              alignment: Alignment.center,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Clipboard.setData(ClipboardData(text: privateKey));
                                                  showMyCustomCopyText(S.current.Copy_successfully);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: APP_MainBgViewColor,
                                                  foregroundColor: APP_MainBgViewColor,
                                                  minimumSize: const Size(360, 50),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(7.0),
                                                  ), // NEW
                                                ),
                                                child: Text(S.current.Copy, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                              alignment: Alignment.center,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: APP_MainBgViewColor,
                                                  foregroundColor: APP_MainBgViewColor,

                                                  minimumSize: const Size(360, 50),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(7.0),
                                                  ), // NEW
                                                ),
                                                child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }else{
                                  showMyCustomText(S.current.Wrong_Password);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: APP_MainBgViewColor,
                                foregroundColor: APP_MainBgViewColor,

                                minimumSize: const Size(360, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                ), // NEW
                              ),
                              child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );

              },
              child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.current.View_private_key, style: const TextStyle(color: Colors.white,fontSize: 13),),
                    const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,size: 14,)
                  ],
                ),
              ),
            ),
            InkWell(
              hoverColor:Colors.white.withOpacity(0.2),
              onTap: () async{
                final TextEditingController pwdController = TextEditingController();
                final TextEditingController mnemonicController = TextEditingController();
                String pwd = await neverLocalStorageRead("LocalPassword");
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context){
                    return Container(
                      height: 200,
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
                              obscureText: true,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () async {
                                if(pwd == pwdController.text){
                                  Navigator.pop(context);
                                  String mnemonic = suiWallet.decryptMnemonic("display",pwdController.text);
                                  mnemonicController.text = mnemonic;
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context){
                                      return Container(
                                        height: 300,
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
                                                  Text(S.current.View_mnemonics, style: const TextStyle(color: Colors.white,fontSize: 13),),
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
                                                controller: mnemonicController,
                                                cursorColor: const Color(0xFF584ED3),
                                                style: const TextStyle(color: Colors.white,fontSize: 13,textBaseline: TextBaseline.alphabetic),
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
                                                maxLines: 3,
                                              ),
                                            ),
                                            const Expanded(child: SizedBox()),
                                            Container(
                                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                                              alignment: Alignment.center,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Clipboard.setData(ClipboardData(text: mnemonic));
                                                  showMyCustomCopyText(S.current.Copy_successfully);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: APP_MainBgViewColor,
                                                  foregroundColor: APP_MainBgViewColor,
                                                  minimumSize: const Size(360, 50),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(7.0),
                                                  ), // NEW
                                                ),
                                                child: Text(S.current.Copy, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                              alignment: Alignment.center,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: APP_MainBgViewColor,
                                                  foregroundColor: APP_MainBgViewColor,

                                                  minimumSize: const Size(360, 50),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(7.0),
                                                  ), // NEW
                                                ),
                                                child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }else{
                                  showMyCustomText(S.current.Wrong_Password);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: APP_MainBgViewColor,
                                foregroundColor: APP_MainBgViewColor,

                                minimumSize: const Size(360, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                ), // NEW
                              ),
                              child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );

              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.current.View_mnemonics, style: const TextStyle(color: Colors.white,fontSize: 13),),
                    const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,size: 14,)
                  ],
                ),
              ),
            ),
            InkWell(
              hoverColor:Colors.white.withOpacity(0.2),
              onTap: () {
                Navigator.pushNamed(context, "/NodeSettingPage");
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.current.Node_settings, style: const TextStyle(color: Colors.white,fontSize: 13),),
                    const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,size: 14,)
                  ],
                ),
              ),
            ),

            const Expanded(child: SizedBox()),

            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GestureDetector(
                onTap: (){
                  // suiWallet.deleteWallet();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: APP_MainRedColor),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Text(S.current.Delete_Wallet,style: const TextStyle(fontSize: 18,color: APP_MainRedColor),),
                ),
              )
            ),
          ],
        )
      ),
    );
  }


}



