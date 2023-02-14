import 'package:bip39/bip39.dart' as bip39;
import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/controller/mnemonic.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/home_page.dart';
import 'package:coinstart_wallet_extension/register/page/import_wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neveruseless/neveruseless.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/sui_api.dart';
import '../../main.dart';

final mnemonic = generateMnemonic();
List<String> mnemonicList = mnemonic.split(" ");

class ForgotPassword2Page extends StatefulWidget {
  final Map? arguments;

  const ForgotPassword2Page({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _ForgotPassword2PageState();
}

class _ForgotPassword2PageState extends State<ForgotPassword2Page> {
  String addWallet = "false";

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/CreateNewWalletPage';
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
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (toDoStep > 1) {
                      setState(() {
                        toDoStep--;
                      });
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
              Offstage(
                offstage: !(toDoStep == 1),
                child: stepOne(),
              ),
              Offstage(
                offstage: !(toDoStep == 2),
                child: stepTwo(),
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
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.current.keep_your_mnemonic,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                )),
                Text(
                  toDoStep.toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: APP_MainPurpleColor),
                ),
                const Text(
                  " / 2",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: APP_MainTextGrayColor),
                ),
              ],
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

  bool isError = false;
  bool isPassOne = false;
  final TextEditingController passwordController = TextEditingController();
  bool canPasswordSee = false;
  final TextEditingController confirmPasswordController = TextEditingController();

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
            child: Row(
              children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Setup Password',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                )),
                Text(
                  toDoStep.toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: APP_MainPurpleColor),
                ),
                const Text(
                  " / 2",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: APP_MainTextGrayColor),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: TextField(
              controller: passwordController,
              obscureText: !canPasswordSee,
              cursorColor: APP_MainPurpleColor,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                suffixIcon: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      canPasswordSee = !canPasswordSee;
                    });
                  },
                  child: Icon(
                    canPasswordSee ? Icons.visibility_sharp : Icons.visibility_off_sharp,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
              onChanged: (e) {
                if (e == "") {
                  isError = false;
                } else {
                  isError = isWeakPassword(e);
                  if (!isError) {
                    if (e == confirmPasswordController.text) {
                      isPassOne = true;
                    } else {
                      isPassOne = false;
                    }
                  }
                }
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Text(
              S.current.password_tip_1,
              style: TextStyle(color: isError ? Colors.red : APP_MainTextGrayColor, fontSize: 11),
            ),
          ),
          SizedBox(
            height: 48,
            child: TextField(
              controller: confirmPasswordController,
              obscureText: !canPasswordSee,
              cursorColor: APP_MainPurpleColor,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                suffixIcon: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      canPasswordSee = !canPasswordSee;
                    });
                  },
                  child: Icon(
                    canPasswordSee ? Icons.visibility_sharp : Icons.visibility_off_sharp,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
              onChanged: (e) {
                if (!isError) {
                  if (e == passwordController.text) {
                    isPassOne = true;
                  } else {
                    isPassOne = false;
                  }

                  setState(() {});
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Text(
              S.current.password_tip_2,
              style: TextStyle(color: isError ? Colors.red : APP_MainTextGrayColor, fontSize: 11),
            ),
          ),
          const Expanded(child: SizedBox()),
          InkWell(
            onTap: () async {
              if (passwordController.text.characters.length < 8 || passwordController.text != confirmPasswordController.text) {
                setState(() {
                  isError = true;
                });
              } else {
                if (isError) {
                  showMyCustomText(S.current.The_password_not_meet_the_requirements);
                  return;
                }

                suiWallet.wallets.clear();
                await suiWallet.safeStorage.deleteAll();
                suiWallet.mnemonic = _mnemonic;
                suiWallet.pwd = passwordController.text;
                String email = await neverLocalStorageRead('register_email');
                String code = await neverLocalStorageRead('register_code');
                var sp = await SharedPreferences.getInstance();
                sp.clear();
                await neverLocalStorageWrite('register_email', email);
                await neverLocalStorageWrite('register_code', code);
                await neverLocalStorageWrite("LocalPassword", passwordController.text);
                String enc = await suiWallet.encryptPassword(passwordController.text);
                await neverLocalStorageWrite('register_enc', enc);
                await SuiApi().setEncPassword(email, code, enc);

                await suiWallet.addWallet(_mnemonic, passwordController.text);

                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const HomePage(),
                    transitionDuration: const Duration(seconds: 0),
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isPassOne ? APP_MainPurpleColor : APP_MainGrayColor,
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
}
