import 'dart:ui';

import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/base/MyBotTextToast.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/home_page.dart';
import 'package:flutter/material.dart';
import 'package:neveruseless/never/neverLocalStorage.dart';

import '../../main.dart';

class NeedPasswordPage extends StatefulWidget {
  final Map? arguments;

  const NeedPasswordPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _NeedPasswordPageState();
}

class _NeedPasswordPageState extends State<NeedPasswordPage> {
  final TextEditingController passwordController = TextEditingController();

  String localPwa = "";

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/NeedPasswordPage';

    neverLocalStorageRead("recovery_flow").then((v) {
      if(v!='null'){
        Navigator.pushNamed(context, "/FindPasswordCodePage",arguments: {
          "recovery_flow": v,
        });
      }
    });


    checkLock();
    loadPwa();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkLock() async {
    var isLock = await neverLocalStorageRead("isLock");
    if (isLock != '1') {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    }
  }

  void loadPwa() async {
    localPwa = await neverLocalStorageRead("LocalPassword");
  }

  @override
  Widget build(BuildContext context) {
    loadPwa();
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
            color: const Color.fromRGBO(1, 6, 9, 1),
            alignment: Alignment.center,
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  color: Colors.black,
                  child: Image(
                    image: const AssetImage("assets/images/index_bg_image.png"),
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Stack(
                              children: [
                                const Image(
                                  image: AssetImage("assets/images/index_icon.png"),
                                  fit: BoxFit.contain,
                                  width: 124,
                                  height: 124,
                                ),
                                BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 0.4, sigmaY: 0.4),
                                  child: const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                          child: const Text(
                            "Welcome to ",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                          child: const Text(
                            "coinstart wallet",
                            style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                          height: 48,
                          child: TextField(
                            obscureText: true,
                            controller: passwordController,
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
                            ),
                            onChanged: (e) {},
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                          child: InkWell(
                            onTap: () {
                              print(passwordController.text);
                              print(localPwa);
                              if (passwordController.text == localPwa) {
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
                              }else{
                                showMyCustomLoading('Password is error');
                                Future.delayed(const Duration(seconds: 1)).then((onValue) async {
                                  closeMyCustomBotLoading();
                                });
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: APP_MainPurpleColor,
                                borderRadius: BorderRadius.all(Radius.circular(7.0)),
                              ),
                              // padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                              // margin: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                              height: 46,
                              alignment: Alignment.center,
                              child: const Text(
                                'unlock',
                                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () async {
                              // suiWallet.deleteWallet();
                              Navigator.pushNamed(context, "/ForgotPasswordHomePage");
                            },
                            child: const Text(
                              'Forgot Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
