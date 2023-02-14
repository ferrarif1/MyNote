import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:coinstart_wallet_extension/controller/mnemonic.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/home_page.dart';
import 'package:coinstart_wallet_extension/register/page/import_wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../main.dart';

final mnemonic = generateMnemonic();
List<String> mnemonicList = mnemonic.split(" ");

class CreateNewWalletPage extends StatefulWidget {
  final Map? arguments;

  const CreateNewWalletPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _CreateNewWalletPageState();
}

class _CreateNewWalletPageState extends State<CreateNewWalletPage> {
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
                child: Offstage(
                  offstage: toDoStep == 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (toDoStep > 1) {
                        if (toDoStep == 4) {
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
              Offstage(
                offstage: !(toDoStep == 4),
                child: stepFour(),
              ),
            ],
          ),
        ),
      )),
    );
  }

  bool isError = false;
  bool isPassOne = false;
  final TextEditingController walletNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool canPasswordSee = false;
  final TextEditingController confirmPasswordController = TextEditingController();

  Widget stepOne() {
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
                    'Create wallet',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                )),
                Text(
                  toDoStep.toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: APP_MainPurpleColor),
                ),
                const Text(
                  " / 4",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: APP_MainTextGrayColor),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: TextField(
              controller: walletNameController,
              cursorColor: APP_MainPurpleColor,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1),
              decoration: InputDecoration(
                hintText: "Wallet name",
                hintStyle: const TextStyle(color: Color(0xff9E9E9E)),
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
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 48,
            child: TextField(
              controller: passwordController,
              obscureText: !canPasswordSee,
              cursorColor: APP_MainPurpleColor,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1),
              decoration: InputDecoration(
                hintText: "Set wallet transaction password",
                hintStyle: const TextStyle(color: Color(0xff9E9E9E)),
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
                hintText: "Confirm wallet transaction password",
                hintStyle: const TextStyle(color: Color(0xff9E9E9E)),
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
                if (suiWallet.hasWallet) {
                  String localPwa = await neverLocalStorageRead("LocalPassword");
                  if (localPwa != passwordController.text) {
                    showMyCustomText(S.current.Wrong_Password_1);
                    return;
                  }
                }
                setState(() {
                  toDoStep = 2;
                });
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

  bool stepTwoCheck = false;

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
                    S.current.keep_your_mnemonic,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                )),
                Text(
                  toDoStep.toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: APP_MainPurpleColor),
                ),
                const Text(
                  " / 4",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: APP_MainTextGrayColor),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(48, 48, 48, 1),
              borderRadius: BorderRadius.all(Radius.circular(7.0)),
            ),
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  childAspectRatio: 6,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 20,
                  children: List.generate(12, (index) {
                    return Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Color.fromRGBO(158, 157, 157, 1),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                              child: SelectableText(
                                mnemonicList[index],
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: mnemonic));
                      showMyCustomCopyText(S.current.Copy_successfully);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 68,
                      height: 32,
                      alignment: Alignment.center,
                      // padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: const BoxDecoration(
                        color: APP_MainBgViewColor,
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      child: Text(
                        S.current.Copy,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                stepTwoCheck = !stepTwoCheck;
              });
            },
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: stepTwoCheck ? APP_MainPurpleColor : Colors.transparent,
                  ),
                  child: Center(
                    child: SvgHelper(stepTwoCheck ? '/icons/check.svg' : '/icons/node_setting_check.svg'),
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  S.current.Backed_Up_The_Memo,
                  style: const TextStyle(color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Expanded(child: SizedBox()),
          InkWell(
            onTap: () async {
              if (!stepTwoCheck) {
                showMyCustomText("Please confirm the record");
                return;
              } else {
                setState(() {
                  toDoStep = 3;
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: stepTwoCheck ? APP_MainPurpleColor : APP_MainGrayColor,
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

  final TextEditingController mnemonicPassword5Controller = TextEditingController();
  final TextEditingController mnemonicPassword9Controller = TextEditingController();
  final TextEditingController mnemonicPassword12Controller = TextEditingController();
  bool isPassThree = false;

  Widget stepThree() {
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
                    S.current.Verify_Mnemonic_Phrase,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                )),
                Text(
                  toDoStep.toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: APP_MainPurpleColor),
                ),
                const Text(
                  " / 4",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: APP_MainTextGrayColor),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Text(
              S.current.Verify_Mnemonic_Phrase_Tip,
              style: const TextStyle(fontSize: 12, color: APP_MainTextGrayColor, height: 1),
            ),
          ),
          SizedBox(
            height: 48,
            child: TextField(
              controller: mnemonicPassword5Controller,
              cursorColor: APP_MainPurpleColor,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1),
              decoration: InputDecoration(
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
                hintText: "#5",
                hintStyle: const TextStyle(fontSize: 14, color: APP_MainTextGrayColor, height: 1.5),
              ),
              onChanged: (e) {
                onThreeChange();
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 48,
            child: TextField(
              controller: mnemonicPassword9Controller,
              cursorColor: APP_MainPurpleColor,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1),
              decoration: InputDecoration(
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
                hintText: "#9",
                hintStyle: const TextStyle(fontSize: 14, color: APP_MainTextGrayColor, height: 1.5),
              ),
              onChanged: (e) {
                onThreeChange();
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 48,
            child: TextField(
              controller: mnemonicPassword12Controller,
              cursorColor: APP_MainPurpleColor,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1),
              decoration: InputDecoration(
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
                hintText: "#12",
                hintStyle: const TextStyle(fontSize: 14, color: APP_MainTextGrayColor, height: 1.5),
              ),
              onChanged: (e) {
                onThreeChange();
              },
            ),
          ),
          const Expanded(child: SizedBox()),
          InkWell(
            onTap: () async {
              if (!isPassThree) {
                return;
              }
              if (mnemonicPassword5Controller.text.isEmpty || mnemonicPassword5Controller.text.toString() != mnemonicList[4]) {
                showMyCustomText("mnemonic error");
                return;
              } else if (mnemonicPassword9Controller.text.isEmpty || mnemonicPassword9Controller.text.toString() != mnemonicList[8]) {
                showMyCustomText("mnemonic error");
                return;
              } else if (mnemonicPassword12Controller.text.isEmpty || mnemonicPassword12Controller.text.toString() != mnemonicList[11]) {
                showMyCustomText("mnemonic error");
                return;
              } else {
                suiWallet.mnemonic = mnemonic;
                suiWallet.pwd = passwordController.text;
                await neverLocalStorageWrite("LocalPassword", passwordController.text);
                String email = await neverLocalStorageRead('register_email');
                String code = await neverLocalStorageRead('register_code');
                String enc = await suiWallet.encryptPassword(passwordController.text);
                await neverLocalStorageWrite('register_enc', enc);
                await SuiApi().setEncPassword(email, code, enc);
                await suiWallet.addWallet(mnemonic, passwordController.text);
                setState(() {
                  toDoStep = 4;
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isPassThree ? APP_MainPurpleColor : APP_MainGrayColor,
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

  onThreeChange() {
    setState(() {
      if (mnemonicPassword5Controller.text.isNotEmpty && mnemonicPassword9Controller.text.isNotEmpty && mnemonicPassword12Controller.text.isNotEmpty) {
        isPassThree = true;
      } else {
        isPassThree = false;
      }
    });
  }

  Widget stepFour() {
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
