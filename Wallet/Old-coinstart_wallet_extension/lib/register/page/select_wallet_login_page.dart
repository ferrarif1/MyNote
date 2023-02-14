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

class SelectWalletLoginPage extends StatefulWidget {
  final Map? arguments;

  const SelectWalletLoginPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _SelectWalletLoginPageState();
}

class _SelectWalletLoginPageState extends State<SelectWalletLoginPage> {
  String _mnemonic = '';

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/SelectWalletLoginPage';
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

  var wallets = [1, 2];

  Widget content() {
    return Container(
      height: 500,
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: ListView(
        children: [
          ...wallets.map((element) {
            return GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, "/LoginWalletPage");
              },
              child: Container(
                color: const Color(0xff37383D),
                margin: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                padding: const EdgeInsets.fromLTRB(20, 21, 5, 18),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/avatar.png',
                      width: 42,
                      height: 42,
                    ),
                    const SizedBox(
                      width: 14,
                    ),
                    const Text('my wallet'),
                    const Spacer(),
                    const SizedBox(
                      height: 27,
                      width: 27,
                      child: Center(
                        child: SvgHelper(
                          '/icons/arrow_right.svg',
                          width: 16,
                          height: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}