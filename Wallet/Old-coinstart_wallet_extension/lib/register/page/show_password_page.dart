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

class ShowPasswordPage extends StatefulWidget {
  final Map? arguments;

  const ShowPasswordPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _ShowPasswordPageState();
}

class _ShowPasswordPageState extends State<ShowPasswordPage> {
  String password = '';

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/ShowPasswordPage';

    neverLocalStorageRead('forgot_enc').then((v) {
      suiWallet.decryptPassword(v).then((v) {
        setState(() {
          password = v;
        });
      });
    });
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
          height: 21,
        ),
        const Text('Your login password', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 126,
        ),
        Text(password, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const Expanded(child: SizedBox()),
        InkWell(
          onTap: () async {
            showMyCustomLoading("Loading...");
            neverLocalStorageRemove('isLock');
            Future.delayed(const Duration(seconds: 1)).then((onValue) async {
              closeMyCustomBotLoading();
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HomePage(),
                  transitionDuration: const Duration(seconds: 0),
                ),
              );
            });
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
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                )),
          ),
        ),
        const SizedBox(
          height: 74,
        )
      ]),
    );
  }
}
