import 'dart:async';
import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
class BinDingMailPage extends StatefulWidget {
  final Map? arguments;
  const BinDingMailPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _BinDingMailPageState();
}

class _BinDingMailPageState extends State<BinDingMailPage> {


  final TextEditingController emailController = TextEditingController();

  final TextEditingController vcodeController = TextEditingController();

  final TextEditingController pwaController = TextEditingController();

  Timer? _timer;
  int _countdownTime = 0;
  String _sendMessageTitle = S.current.Get_Code;
  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/BinDingMailPage';
  }

  @override
  void dispose() {
    if(_timer!= null){
      _timer!.cancel();
    }
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
          title: Text(S.current.Email),
        ),
        body:GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                alignment: Alignment.centerLeft,
                child: Text(S.current.Email_Address,style: const TextStyle(fontSize: 14,color: Colors.white),),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                height: 48,
                child: TextField(
                  controller: emailController,
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
                    hintText: S.current.Email_Tip_1,
                    hintStyle: const TextStyle(fontSize: 13, color: APP_MainTextGrayColor ,height: 1.5),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                alignment: Alignment.centerLeft,
                child: Text(S.current.Verification_Code,style: const TextStyle(fontSize: 14,color: Colors.white),),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                height: 48,
                child: TextField(
                  controller: vcodeController,
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
                    suffixIcon: SizedBox(
                      width: 100,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const VerticalDivider(width: 1,color: Colors.grey,),
                          InkWell(
                            onTap: (){
                              _countdownTime = 10;
                              startCountdownTimer();
                            },
                            child: Container(
                              width: 80,
                              alignment: Alignment.center,
                              child: Text(_sendMessageTitle,style: const TextStyle(fontSize: 12,color: Colors.white),),
                            ),
                          )
                        ],
                      ),
                    )
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                alignment: Alignment.centerLeft,
                child: Text(S.current.Login_Password,style: const TextStyle(fontSize: 14,color: Colors.white),),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                height: 48,
                child: TextField(
                  controller: pwaController,
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
                ),
              ),


              const SizedBox(height: 30,),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  decoration: const BoxDecoration(
                    color:  APP_MainPurpleColor,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  alignment: Alignment.center,
                  height: 48,
                  child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontSize: 16,),
                ),
              ),),
            ],
          ),
        )
      ),
    );
  }

  //倒计时
  void startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer){
      if(mounted){
        setState(() {
          if (_countdownTime < 1) {
            _timer!.cancel();
          } else {
            _countdownTime = _countdownTime - 1;
            _sendMessageTitle = '${_countdownTime}s';
            if (_countdownTime == 0) {
              _sendMessageTitle = S.current.Get_Code;
            }
          }
        });
      }
    });
  }

}

