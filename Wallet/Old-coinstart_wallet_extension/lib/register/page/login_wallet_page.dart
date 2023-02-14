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

class LoginWalletPage extends StatefulWidget {
  final Map? arguments;

  const LoginWalletPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _LoginWalletPageState();
}

class _LoginWalletPageState extends State<LoginWalletPage> {
  String _mnemonic = '';

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/LoginWalletPage';
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

  final TextEditingController passwordController = TextEditingController();

  Widget content() {
    return Container(
      height: 500,
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Image.asset(
            'assets/images/avatar.png',
            width: 145,
            height: 145,
          ),
          SizedBox(
            height: 13,
          ),
          Text(
            'My wallet',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(
            height: 50,
          ),
          TextField(
            controller: passwordController,
            cursorColor: const Color(0xFF584ED3),
            style: const TextStyle(color: Colors.white, fontSize: 15, textBaseline: TextBaseline.alphabetic),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Please enter transaction password',
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
          SizedBox(
            height: 27,
          ),
          InkWell(
            onTap: () async {
              Navigator.pushNamed(context, "/ImportWalletPage", arguments: {
                "AddWallet": "false",
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: passwordController.text.characters.length >= 8 ? APP_MainPurpleColor : APP_MainGrayColor,
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Container(
                  width: 340,
                  height: 48,
                  alignment: Alignment.center,
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            S.current.Forgot_Password,
            style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
