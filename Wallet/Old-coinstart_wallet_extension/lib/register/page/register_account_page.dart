import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:coinstart_wallet_extension/controller/json.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/home_page.dart';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:neveruseless/neveruseless.dart';
import '../../main.dart';

class RegisterAccountPage extends StatefulWidget {
  final Map? arguments;

  const RegisterAccountPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _RegisterAccountPageState();
}

class _RegisterAccountPageState extends State<RegisterAccountPage> {
  String _mnemonic = '';

  bool canTouch = true;
  bool selected = false;

  String _sendMessageTitle = 'Send Code';
  Timer? _timer;
  int _countdownTime = 0;

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/RegisterAccountPage';

    if (widget.arguments?['register_flow'] != null) {
      emailController.text = widget.arguments?['register_flow'];
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
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
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
                    'Sign up for coinstart wallet',
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
              hintText: 'Verification Code',
              hintStyle: const TextStyle(color: Color(0xff9E9E9E)),
              contentPadding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              fillColor: Colors.white.withOpacity(0.05),
              filled: true,
              suffixIcon: GestureDetector(
                  onTap: () async {
                    if (!canTouch) return;
                    FocusScope.of(context).requestFocus(FocusNode());

                    canTouch = false;
                    _countdownTime = 60;
                    await neverLocalStorageWrite('register_flow', emailController.text);
                    var res = await SuiApi().sendVerifyCode(emailController.text);
                    startCountdownTimer();

                    Map<String, dynamic> map = jsonDecode(res.body);
                    print(map.toString());
                    if (map['msg'] == 'SUCCESS') {}
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 100,
                    child: Text(_sendMessageTitle, style: TextStyle(color: Color(0xff8053BB))),
                  )),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
            ),
            onChanged: (e) {
              setState(() {});
            },
          ),
          const SizedBox(
            height: 36,
          ),
          Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (v) {
                  setState(() {
                    selected = v ?? false;
                  });
                },
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
              if (codeController.text.characters.length < 4 || !selected) return;

              await neverLocalStorageWrite('register_email', emailController.text);
              await neverLocalStorageWrite('register_code', codeController.text);

              await SuiApi().verifyCode(emailController.text, codeController.text);

              await neverLocalStorageRemove('register_flow');
              Navigator.pushNamed(context, "/CreateImportWalletPage");
            },
            child: Container(
              decoration: BoxDecoration(
                color: (codeController.text.characters.length >= 4 && selected) ? APP_MainPurpleColor : APP_MainGrayColor,
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
              _sendMessageTitle = 'Send Code';
            }
          }
        });
      }
    });
  }
}
