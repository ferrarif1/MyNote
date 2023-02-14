import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../main.dart';
class NFTTransferPage extends StatefulWidget {
  final Map? arguments;
  const NFTTransferPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _NFTTransferPageState();
}

class _NFTTransferPageState extends State<NFTTransferPage> {

  SuiObject? data ;
  final TextEditingController addressController = TextEditingController();

  final TextEditingController pwdController = TextEditingController();
  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/NFTTransferPage';
    data = widget.arguments!["data"];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void trant() async{
    showMyCustomLoading("Loading...");
    SuiTansaction? result = await suiWallet.transferNFT(data!, addressController.text, pwdController.text);
    closeMyCustomBotLoading();
    pwdController.text = "";
    if(result!.status.toString() == "success"){
      Navigator.pop(context,{"flag" : "true",});
    }else{
      showMyCustomText("Fail");
    }
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
          title: const Text("NFT Send"),
        ),
        body:GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(30, 30, 30, 1),
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child:ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image(image: NetworkImage(data!.fields["url"]), fit: BoxFit.cover,height: 60,width: 60,
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                return Container(
                                  height: 60,
                                  width: 60,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data!.fields["name"],style: const TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.w700),),
                                const SizedBox(height: 10,),
                                const Text("Token ID : 1",style: TextStyle(fontSize: 12,color: APP_MainTextGrayColor,fontWeight: FontWeight.w700),),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Text(S.current.Recelving_Address,style: const TextStyle(color: APP_MainTextGrayColor,fontSize: 15),),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    height: 48,
                    child: TextField(
                      controller: addressController,
                      cursorColor: APP_MainPurpleColor,
                      style: const TextStyle(color: Colors.white,fontSize: 13,height: 1),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        fillColor:APP_MainBlackColor,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Color.fromRGBO(78, 79, 82, 1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Color.fromRGBO(78, 79, 82, 1)),
                        ),
                      ),
                      onChanged: (e){
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),

              InkWell(
                onTap: () async {
                  if(addressController.text.isEmpty){
                    showMyCustomText(S.current.Please_input_address);
                    return;
                  }

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
                                  Text(S.current.Please_input_password_address, style: const TextStyle(color: Colors.white,fontSize: 13),),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
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
                              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              height: 48,
                              child: TextField(
                                controller: pwdController,
                                obscureText:true,
                                cursorColor: APP_MainPurpleColor,
                                style: const TextStyle(color: Colors.white,fontSize: 13,height: 1),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  fillColor:APP_MainBlackColor,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(color: Color.fromRGBO(78, 79, 82, 1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(color: Color.fromRGBO(78, 79, 82, 1)),
                                  ),
                                  hintText: S.current.Please_input_password,
                                  hintStyle: const TextStyle(fontSize: 14, color: APP_MainTextGrayColor ,height: 1.5),
                                ),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            InkWell(
                              onTap: () async {
                                if(pwdController.text.isEmpty){
                                  showMyCustomText(S.current.Please_input_password);
                                  return;
                                }
                                Navigator.pop(context);
                                trant();
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: APP_MainPurpleColor,
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontSize: 16,),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );


                  // suiWallet.transferNFT(data!, '0x53b8f1fc4c018e73ff1c64d7415cfef2ceca3355', pwd);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: addressController.text.isNotEmpty ?  APP_MainPurpleColor : APP_MainGrayColor,
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: Text(S.current.Next, style: const TextStyle(color: Colors.white, fontSize: 16,),
                      )
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
