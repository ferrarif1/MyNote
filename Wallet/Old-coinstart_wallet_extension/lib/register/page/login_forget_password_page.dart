import 'dart:collection';
import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/home_page.dart';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:neveruseless/neveruseless.dart';
import '../../main.dart';

class EmailLoginPage extends StatefulWidget {
  final Map? arguments;

  const EmailLoginPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  int toDoStep = 1;

  String _mnemonic = '';

  String addWallet = "false";

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/EmailLoginPage';
    try {
      addWallet = widget.arguments!["addWallet"];
    } catch (e) {
      addWallet = "false";
    }
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
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Offstage(
                      offstage: toDoStep == 3,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                            Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              content(),
            ],
          ),
        ),
      )),
    );
  }

  final TextEditingController emailController = TextEditingController();

  bool isError = false;
  final TextEditingController codeController = TextEditingController();
  bool isBetterPwd = false;

  Widget content() {
    return Container(
      height: 500,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Login with email',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                )),
              ],
            ),
          ),
          TextField(
            controller: emailController,
            cursorColor: const Color(0xFF584ED3),
            style: const TextStyle(color: Colors.white, fontSize: 15, textBaseline: TextBaseline.alphabetic),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Email Address',
              hintStyle: const TextStyle(color: Color(0xff9E9E9E)),
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
            onChanged: (e) {
              if (e == "") {
                isError = false;
              } else {
                isError = isWeakPassword(e);
              }
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: codeController,
            cursorColor: const Color(0xFF584ED3),
            style: const TextStyle(color: Colors.white, fontSize: 15, textBaseline: TextBaseline.alphabetic),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Enter login password',
              hintStyle: const TextStyle(color: Color(0xff9E9E9E)),
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
            onChanged: (e) {
              if (e == "") {
                isError = false;
              } else {
                isError = isWeakPassword(e);
              }
              setState(() {});
            },
          ),
          const SizedBox(
            height: 36,
          ),
          Row(
            children: [
              Checkbox(
                value: true,
                onChanged: (v) {},
                fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                  const Set<MaterialState> interactiveStates = <MaterialState>{
                    MaterialState.pressed,
                    MaterialState.hovered,
                    MaterialState.focused,
                  };
                  if (states.contains(MaterialState.disabled)) {
                    return ThemeData.from(colorScheme: const ColorScheme.light()).disabledColor;
                  }
                  if (states.contains(MaterialState.selected)) {
                    return ThemeData().toggleableActiveColor;
                  }
                  if (states.any(interactiveStates.contains)) {
                    return Colors.red;
                  }
                  return const Color(0xff3B3B3B);
                }),
              ),
              const Text(
                'Agree to coinstart wallet terms',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(
            height: 18,
          ),
          InkWell(
            onTap: () async {
              Navigator.pushNamed(context, "/SelectWalletLoginPage");
            },
            child: Container(
              decoration: BoxDecoration(
                color: codeController.text.characters.length >= 4 ? APP_MainPurpleColor : APP_MainGrayColor,
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Container(
                  width: 340,
                  height: 48,
                  alignment: Alignment.center,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
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
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Text(
              S.current.Create_Wallet_Successfully,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3),
              textAlign: TextAlign.center,
            ),
          ), //register_done.png

          InkWell(
            onTap: () async {
              if (addWallet != "true") {
                navigatorKey.currentState!.pushNamedAndRemoveUntil('/HomePage', (route) => false, arguments: {
                  "needUser": "0",
                });
              } else {
                navigatorKey.currentState!.pushNamedAndRemoveUntil('/HomePage', (route) => false, arguments: {
                  "needUser": "1",
                });
              }
            },
            child: Container(
              width: 169,
              height: 46,
              decoration: const BoxDecoration(
                color: APP_MainPurpleColor,
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Get Started',
                style: TextStyle(
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
}

bool isWeakPassword(String password) {
  if (password.isNotEmpty != true) return true; //密码为空，弱密码
  if (password.length < 8) return true; //位数不足，弱密码
  Set set = HashSet();
  for (var code in password.codeUnits) {
    if (code >= 48 && code <= 57) {
      set.add('Number');
    } else if (code >= 65 && code <= 90) {
      set.add('Uppercase letter');
    } else if (code >= 97 && code <= 122) {
      set.add('Lowercase letter');
    } else {
      set.add('Special letter');
    }
  }
  return set.length < 3; //种类小于3种，弱密码
}
