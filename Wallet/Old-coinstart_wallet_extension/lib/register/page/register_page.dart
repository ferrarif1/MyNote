import 'dart:ui';

import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:flutter/material.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../main.dart';

class RegisterPage extends StatefulWidget {
  final Map? arguments;

  const RegisterPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? localPwa;

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/RegisterPage';

    neverLocalStorageRead("LocalPassword").then((v) {
      localPwa = v;
      setState(() {});
    });

    neverLocalStorageRead("register_flow").then((v) {
      if (v != 'null') {
        Navigator.pushNamed(context, "/RegisterAccountPage", arguments: {
          "register_flow": v,
        });
      }
    });


    neverLocalStorageRead("register_flow2").then((v) {
      if (v != 'null') {
        Navigator.pushNamed(context, "/CreateImportWalletPage", arguments: {
          "register_flow": v,
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff19191A),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image(
              image: const AssetImage("assets/images/welcome_line.png"),
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Image(
                      image: AssetImage("assets/images/welcome_logo.png"),
                      fit: BoxFit.contain,
                      width: 124,
                      height: 124,
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    const Text(
                      'Welcome to',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Open CoinWallet",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, "/RegisterAccountPage");
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 45)
                            .copyWith(top: 60),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          gradient: LinearGradient(colors: [
                            Color(0xffA376DD),
                            Color(0xff7C4FC0),
                          ]),
                        ),
                        height: 50,
                        alignment: Alignment.center,
                        child: const Text(
                          'Create New Wallet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (localPwa == 'null') {
                          Navigator.pushNamed(context, "/RegisterAccountPage");
                        } else {
                          Navigator.pushNamed(context, "/EmailLoginPage");
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 45)
                            .copyWith(top: 15),
                        decoration: const BoxDecoration(
                          color: Color(0xff3A393F),
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        height: 50,
                        alignment: Alignment.center,
                        child: const Text(
                          'Login with email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                        'Have recovery phrase?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xffB798DF),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Forget Password',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xffB798DF),
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
    );
  }
}
