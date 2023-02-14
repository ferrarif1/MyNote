import 'dart:collection';
import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/home_page.dart';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:neveruseless/neveruseless.dart';
import '../../main.dart';

class FindPasswordEmailPage extends StatefulWidget {
  final Map? arguments;

  const FindPasswordEmailPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _FindPasswordEmailPageState();
}

class _FindPasswordEmailPageState extends State<FindPasswordEmailPage> {
  String email = '';

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/FindPasswordEmailPage';
    neverLocalStorageRead('register_email').then((v) {
      email = v;
      retrievePassword(email);
      setState(() {});
    });
  }

  retrievePassword(String email) async {
    String enc = await neverLocalStorageRead('register_enc');
    SuiApi().retrievePassword(email, enc.substring(0, 4));
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
      child: Column(children: [
        const SizedBox(
          height: 116,
        ),
        const Text('Send code to email', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 9,
        ),
        Text(email, style: const TextStyle(color: APP_MainPurpleColor, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 36,
        ),
        InkWell(
          onTap: () async {
            Navigator.pushNamed(context, "/FindPasswordCodePage");
          },
          child: Container(
            decoration: const BoxDecoration(
              color: APP_MainPurpleColor,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: Container(
                width: 248,
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
      ]),
    );
  }
}
