import 'dart:collection';
import 'dart:convert';
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

class FindPasswordCodePage extends StatefulWidget {
  final Map? arguments;

  const FindPasswordCodePage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _FindPasswordCodePageState();
}

class _FindPasswordCodePageState extends State<FindPasswordCodePage> {
  String email = '';

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/FindPasswordCodePage';
    neverLocalStorageWrite("recovery_flow", '1');
    neverLocalStorageRead('register_email').then((v) {
      email = v;
      retrievePassword(email);
      setState(() {});
    });

    //
    // if (widget.arguments?['recovery_flow'] != null) {
    //   emailController.text = widget.arguments?['register_flow'];
    // }
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
                      onTap: () async{
                        await neverLocalStorageRemove("recovery_flow");
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
          height: 49,
        ),
        const Text('Please check your email', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 6,
        ),
        Text(email, style: const TextStyle(color: APP_MainPurpleColor, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 6,
        ),
        const Text('and enter the recovery code in the email', style: TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(
          height: 42,
        ),
        Container(
          height: 48,
          child: TextField(
            obscureText: true,
            controller: passwordController,
            cursorColor: APP_MainPurpleColor,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1),
            decoration: InputDecoration(
              hintText: 'recovery code',
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
          ),
        ),
        const SizedBox(
          height: 36,
        ),
        InkWell(
          onTap: () async {
            showMyCustomLoading('Loading...');

            var localPwa = await neverLocalStorageRead("LocalPassword");

            var psd = '';
            try {
              psd = await suiWallet.decryptPassword(passwordController.text);
            } catch (e) {}

            if (psd != localPwa) {
              showMyCustomLoading('Recovery code error.');
              Future.delayed(const Duration(seconds: 1)).then((onValue) async {
                closeMyCustomBotLoading();
              });
              return;
            }

            await neverLocalStorageWrite('forgot_enc', passwordController.text);
            await neverLocalStorageRemove("recovery_flow");
            Navigator.pushNamed(context, "/ShowPasswordPage");
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            decoration: const BoxDecoration(
              color: APP_MainPurpleColor,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: Container(
                height: 48,
                alignment: Alignment.center,
                child: const Text(
                  'Next',
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
