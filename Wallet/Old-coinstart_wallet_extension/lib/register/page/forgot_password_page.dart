import 'dart:async';

import 'package:bip39/bip39.dart' as bip39;
import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class ForgotPasswordPage extends StatefulWidget {
  final Map? arguments;
  const ForgotPasswordPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/ForgotPasswordPage';
  }

  @override
  void dispose() {
    super.dispose();
  }

  int toDoStep = 1;
  String _mnemonic = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
          body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          color: APP_MainBGColor,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Offstage(
                  offstage: toDoStep == 3,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (toDoStep > 1) {
                        if (toDoStep == 3) {
                          // Navigator.pop(context);
                        } else {
                          setState(() {
                            toDoStep--;
                          });
                        }
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Offstage(
                offstage: !(toDoStep == 1),
                child: stepOne(),
              ),
              Offstage(
                offstage: !(toDoStep == 2),
                child: stepTwo(),
              ),
              Offstage(
                offstage: !(toDoStep == 3),
                child: stepThree(),
              ),
            ],
          ),
        ),
      )),
    );
  }

  final TextEditingController mnemonicPasswordController = TextEditingController();
  bool stepOneCheck = false;

  Widget stepOne() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                S.current.keep_your_mnemonic,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
          TextField(
            controller: mnemonicPasswordController,
            cursorColor: APP_MainPurpleColor,
            maxLines: 6,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 2),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              fillColor: APP_MainBlackColor,
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
            onChanged: (e) {
              setState(() {});
            },
          ),
          const SizedBox(
            height: 10,
          ),
          // GestureDetector(
          //   onTap: (){
          //     setState(() {
          //       stepOneCheck = !stepOneCheck;
          //     });
          //   },
          //   child:Row(
          //     children: [
          //       Container(
          //         width: 16,
          //         height: 16,
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(10),
          //           color: stepOneCheck ? APP_MainPurpleColor : Colors.transparent,
          //         ),
          //         child: Center(
          //           child: SvgHelper(stepOneCheck ? '/icons/check.svg' : '/icons/node_setting_check.svg'),
          //         ),
          //       ),
          //       const SizedBox(width: 9),
          //       Text(S.current.Forgot_Password_Tip1, style: const TextStyle(color: APP_MainTextGrayColor),
          //       ),
          //     ],
          //   ),
          // ),
          const Expanded(child: SizedBox()),
          InkWell(
            onTap: () async {
              if (mnemonicPasswordController.text.isEmpty == false && (bip39.validateMnemonic(mnemonicPasswordController.text) == true)) {
                setState(() {
                  _mnemonic = mnemonicPasswordController.text.trimLeft().trimRight();
                  toDoStep = 2;
                });
              } else {
                showMyCustomText("invalid mnemonic");
                return;
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: mnemonicPasswordController.text.trimLeft().trimRight().split(" ").length == 12 ? APP_MainPurpleColor : APP_MainGrayColor,
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Container(
                  width: 340,
                  height: 48,
                  alignment: Alignment.center,
                  child: Text(
                    S.current.Next,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController emailController = TextEditingController();
  bool isPassTwo = false;
  bool canTouch = true;

  String _sendMessageTitle = '获取验证码';
  Timer? _timer;
  int _countdownTime = 0;

  Widget stepTwo() {
    return Container(
      height: 500,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                S.current.Retrieve_password,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
          TextField(
            controller: emailController,
            cursorColor: APP_MainPurpleColor,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 2),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              fillColor: APP_MainBlackColor,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Color.fromRGBO(78, 79, 82, 1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Color.fromRGBO(78, 79, 82, 1)),
              ),
              hintText: S.current.Forgot_Password_Tip3,
              hintStyle: const TextStyle(fontSize: 14, color: APP_MainTextGrayColor, height: 1.5),
            ),
            onChanged: (e) {
              setState(() {
                isPassTwo = RegexUtil.isEmail(e);
              });
            },
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              if (!isPassTwo) {
                return;
              }
              setState(() {
                toDoStep = 3;
              });
              // canTouch = false;
              // _countdownTime = 60;
              // startCountdownTimer();
            },
            onLongPress: () {
              setState(() {
                toDoStep = 3;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isPassTwo ? (canTouch ? APP_MainPurpleColor : APP_MainGrayColor) : APP_MainGrayColor,
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: Text(
                    canTouch ? S.current.Next : _sendMessageTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget stepThree() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: const ImageHelper(
              '/images/register_done.png',
              height: 140,
              width: 140,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 5),
            child: Text(
              S.current.Forgot_Password_Tip4,
              style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.3),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              emailController.text,
              style: const TextStyle(fontSize: 15, color: APP_MainPurpleColor, height: 1.3),
              textAlign: TextAlign.center,
            ),
          ),
          InkWell(
            onTap: () async {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Container(
              width: 169,
              height: 46,
              decoration: const BoxDecoration(
                color: APP_MainPurpleColor,
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
              ),
              alignment: Alignment.center,
              child: Text(
                S.current.Wallet_Login,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdownTime < 1) {
            _timer!.cancel();
          } else {
            _countdownTime = _countdownTime - 1;
            _sendMessageTitle = '${_countdownTime}s';
            if (_countdownTime == 0) {
              canTouch = true;
              _sendMessageTitle = '重新发送';
            }
          }
        });
      }
    });
  }
}
