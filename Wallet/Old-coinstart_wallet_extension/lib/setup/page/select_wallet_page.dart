import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/controller/sui_wallet_controller.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../main.dart';

class SelectWalletPage extends StatefulWidget {
  final Map? arguments;
  const SelectWalletPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _SelectWalletPageState();
}

class _SelectWalletPageState extends State<SelectWalletPage> {
  List<SuiWallet>? _walletList = [];

  int selectIndex = 0;

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/SelectWalletPage';
    loadWallet();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadWallet() async {
    await suiWallet.loadStorageWalletSelect(clean: true);
    _walletList = suiWallet.wallets;
    if (_walletList!.isNotEmpty) {
      selectIndex = _walletList!.indexWhere((element) {
        return element.address == suiWallet.currentWalletAddress.toString();
      });
      if (selectIndex == -1) {
        selectIndex = 0;
      }
    }
    setState(() {});
    // _load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
          appBar: AppBar(
            title: Text(S.current.Select_Wallet),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _walletList!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          children: [
                            selectIndex == index
                                ? const Image(
                                    image: AssetImage("assets/images/netword_done.png"),
                                    width: 16,
                                    height: 16,
                                  )
                                : const SizedBox(
                                    width: 16,
                                    height: 16,
                                  ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  neverLocalStorageWrite("NowAddressKey", _walletList![index].name!);
                                  Future.delayed(const Duration(seconds: 0)).then((onValue) async {
                                    Navigator.pushNamedAndRemoveUntil(context, "/NeedPasswordPage", (route) => false);
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(99),
                                        child: Image(
                                          image: const AssetImage("assets/images/coinstart_logo_white.png"),
                                          width: 26,
                                          height: 26,
                                          fit: BoxFit.contain,
                                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                            return Container(
                                              width: 26,
                                              height: 26,
                                              color: Colors.transparent,
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.sms_failed_rounded,
                                                color: Colors.grey.withOpacity(0.2),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          _walletList![index].name!,
                                          style: const TextStyle(fontSize: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      child: const Text(
                                        "\$0.00",
                                        style: TextStyle(fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, "/EditWalletSettingPage", arguments: {
                                  "data": _walletList![index],
                                }).then((value) {
                                  try {
                                    Map map = value as Map;
                                    _walletList!.removeWhere((element) => element.name == map["name"]);
                                    if (_walletList!.isNotEmpty) {
                                      selectIndex = _walletList!.indexWhere((element) => element.address == suiWallet.currentWalletAddress.toString());
                                      if (selectIndex == -1) {
                                        selectIndex = 0;
                                      }
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                  setState(() {});
                                });
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: const Image(
                                  image: AssetImage("assets/images/edit.png"),
                                  height: 13,
                                  width: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ); //netword_done
                  },
                ),
              ),
              InkWell(
                onTap: () async {
                  Navigator.pushNamed(context, "/AddWalletPage");
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: APP_MainPurpleColor,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Container(
                    width: 340,
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(
                      S.current.Add_Wallet,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
