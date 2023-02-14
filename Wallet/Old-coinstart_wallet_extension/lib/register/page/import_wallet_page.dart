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

class ImportWalletPage extends StatefulWidget {
  final Map? arguments;

  const ImportWalletPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _ImportWalletPageState();
}

class _ImportWalletPageState extends State<ImportWalletPage> {
  int toDoStep = 1;

  String _mnemonic = '';

  String addWallet = "false";

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/ImportWalletPage';
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
                  ],
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
  final TextEditingController passwordController = TextEditingController();
  bool canPasswordSee = false;
  bool isBetterPwd = false;

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
                  child: Text(
                    S.current.Setup_Password,
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
            controller: passwordController,
            obscureText: !canPasswordSee,
            cursorColor: const Color(0xFF584ED3),
            style: const TextStyle(color: Colors.white, fontSize: 15, textBaseline: TextBaseline.alphabetic),
            decoration: InputDecoration(
              isDense: true,
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
              suffix: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      canPasswordSee = !canPasswordSee;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 40,
                    child: Icon(
                      canPasswordSee ? Icons.visibility_sharp : Icons.visibility_off_sharp,
                      color: Colors.white,
                      size: 14,
                    ),
                  )),
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
          Text(
            S.current.password_tip_2,
            style: TextStyle(color: isError ? Colors.red : APP_MainTextGrayColor, fontSize: 12),
          ),
          const Expanded(child: SizedBox()),
          InkWell(
            onTap: () async {
              if (passwordController.text.characters.length < 8) {
                setState(() {
                  isError = true;
                });
              } else {
                if (isError) {
                  showMyCustomText(S.current.The_password_not_meet_the_requirements);
                  return;
                }
                if (suiWallet.hasWallet) {
                  String localPwa = await neverLocalStorageRead("LocalPassword");
                  if (localPwa != passwordController.text) {
                    showMyCustomText(S.current.Wrong_Password_1);
                    return;
                  }
                }

                final mnemonic = _mnemonic;
                if (bip39.validateMnemonic(mnemonic) == true) {
                  suiWallet.pwd = passwordController.text;
                  suiWallet.mnemonic = mnemonic;
                  await neverLocalStorageWrite("LocalPassword", passwordController.text);
                  await suiWallet.addWallet(mnemonic, passwordController.text);

                  var email = await neverLocalStorageRead('register_email');
                  var code = await neverLocalStorageRead('register_code');
                  var enc = await suiWallet.encryptPassword(passwordController.text);
                  await neverLocalStorageWrite('register_enc', enc);
                  await SuiApi().setEncPassword(email, code, enc);

                  setState(() {
                    toDoStep = 3;
                  });
                } else {
                  showError("invalid mnemonic", "invalid mnemonic!");
                }
              }
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
