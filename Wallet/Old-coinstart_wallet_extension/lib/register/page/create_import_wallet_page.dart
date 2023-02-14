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

class CreateImportWalletPage extends StatefulWidget {
  final Map? arguments;

  const CreateImportWalletPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _CreateImportWalletPageState();
}

class _CreateImportWalletPageState extends State<CreateImportWalletPage> {
  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/CreateImportWalletPage';
    neverLocalStorageWrite('register_flow2', '2');
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
          const SizedBox(
            height: 80,
          ),
          Image.asset(
            'assets/images/image_bg1.png',
            width: 261,
            height: 261,
          ),
          const SizedBox(
            height: 40,
          ),
          InkWell(
            onTap: () async {
              await neverLocalStorageRemove('register_flow2');
              Navigator.pushNamed(context, "/CreateNewWalletPage", arguments: {
                "AddWallet": "false",
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                color: APP_MainPurpleColor,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Container(
                  width: 340,
                  height: 48,
                  alignment: Alignment.center,
                  child: const Text(
                    'Create new wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              await neverLocalStorageRemove('register_flow2');
              Navigator.pushNamed(context, "/ImportWalletPage", arguments: {
                "AddWallet": "false",
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 1, color: APP_MainPurpleColor),
                borderRadius: const BorderRadius.all(Radius.circular(7.0)),
              ),
              child: Container(
                  width: 340,
                  height: 48,
                  alignment: Alignment.center,
                  child: const Text(
                    'Import existing wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
