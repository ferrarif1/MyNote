import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:flutter/material.dart';
import 'package:ones/ui.dart';

import '../../main.dart';

class ForgotPasswordHomePage extends StatefulWidget {
  final Map? arguments;

  const ForgotPasswordHomePage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _ForgotPasswordHomePageState();
}

class _ForgotPasswordHomePageState extends State<ForgotPasswordHomePage> {
  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/ForgotPasswordHomePage';
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
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 44),
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xFF181818),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Image.asset(
                                'assets/images/clipboard.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            const Text('Retrieve password by mnemonic'),
                            const Spacer(),
                            const Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: Colors.white,
                              size: 27,
                            )
                          ],
                        ),
                      ),
                    ).roundedRect(5).onClick(() {
                      Navigator.pushNamed(context, "/ForgotPassword2Page");
                    }),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: const Color(0xFF181818),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Image.asset(
                                'assets/images/mail.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            const Text('Retrieve password by email'),
                            const Spacer(),
                            const Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: Colors.white,
                              size: 27,
                            )
                          ],
                        ),
                      ),
                    ).roundedRect(5).onClick(() {
                      Navigator.pushNamed(context, "/FindPasswordCodePage");
                    })
                  ],
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
