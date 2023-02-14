import 'dart:html';

import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/Base/image_helper.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/main.dart';
import 'package:coinstart_wallet_extension/nft/page/nft_index_page.dart';
import 'package:coinstart_wallet_extension/setup/page/setup_page.dart';
import 'package:coinstart_wallet_extension/wallet/page/wallet_page.dart';
import 'package:coinstart_wallet_extension/wallet/pagekbg/swap_page_kbg.dart';
import 'package:flutter/material.dart';
import 'package:neveruseless/neveruseless.dart';

class HomePage extends StatefulWidget {
  final Map? arguments;

  const HomePage({Key? key, this.arguments}) : super(key: key);
  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  // SuiWalletController suiWallet = Get.find();

  String needUser = "0";

  @override
  bool get wantKeepAlive => true;

  int selectedIndex = 0;
  final pageController = PageController();
  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/indexView';
    try {
      needUser = widget.arguments!["needUser"];
    } catch (e) {
      needUser = "0";
    }
    loadWallet();
    neverBus.on('checkLanguage', (object) {
      setState(() {
        if (object == "en") {
          print("切换语言EN");
          localNow = "English";
          S.load(const Locale('en', 'US'));
        } else {
          print("切换语言ZH");
          localNow = "中文简体";
          S.load(const Locale("zh", "ZH"));
        }
      });
    });
  }

  void loadWallet() async {
    await suiWallet.loadStorageWallet(clean: true);
  }

  void onTap(int index) {
    // if (index == 2 || index == 3) {
    //   return;
    // }
    pageController.jumpToPage(index);
    neverBus.emit('pageController', pagesName[index]);
    // neverBus.emit('pageController', index);
  }

  void onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final pages = const [
    WalletPage(),
    NFTIndexPage(),
    SwapPageNew(),
    // TradePage(),
    // GameFiPage(),
    // DAppPage(),
    SetupPage(),
  ];

  final pagesName = const [
    "/WalletPage",
    "/NFTIndexPage",
    "/SwapPageNew"
    // "/TradePage",
    // "/DAppPage",
    "/SetupPage",
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // suiWallet.loadStorageWallet();
    // suiWallet.getBalance();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        right: true,
        bottom: true,
        left: true,
        top: false,
        child: Scaffold(
          backgroundColor: APP_MainBGColor,
          body: PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            physics: const NeverScrollableScrollPhysics(),
            children: pages, // 禁止滑动
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                backgroundColor: Colors.transparent,
                icon: Image(
                      image: AssetImage("assets/images/tab_coin_after.png"),
                      height: 27,
                      width: 27,
                    ),
                activeIcon: Image(
                      image: AssetImage("assets/images/tab_coin_before.png"),
                      height: 27,
                      width: 27,
                    ),
                label: "",
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.transparent,
                icon:  Image(
                      image: AssetImage("assets/images/tab_nft_after.png"),
                      height: 27,
                      width: 27,
                    ),
                activeIcon:
                 Image(
                      image: AssetImage("assets/images/tab_nft_before.png"),
                      height: 27,
                      width: 27,
                    ),
                label: "",
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.transparent,
                icon: Image(
                      image: AssetImage("assets/images/tab_swap_after.png"),
                      height: 27,
                      width: 27,
                      color: Colors.grey,
                    ),
                activeIcon:  Image(
                      image: AssetImage("assets/images/tab_swap_before.png"),
                      height: 27,
                      width: 27,
                    ),
                label: "",
              ),
              // BottomNavigationBarItem(
              //   backgroundColor: Colors.transparent,
              //   icon: Container(
              //       padding: const EdgeInsets.all(0),
              //       alignment: Alignment.center,
              //       child: const Image(image: AssetImage("assets/images/tab_dapp_after.png"),height: 27,width: 27,color: Colors.grey,)
              //   ),
              //   activeIcon: Container(
              //       padding: const EdgeInsets.all(0),
              //       alignment: Alignment.center,
              //       child: const Image(image: AssetImage("assets/images/tab_dapp_before.png"),height: 27,width: 27,)
              //   ),
              //   label: "",
              // ),
              BottomNavigationBarItem(
                backgroundColor: Colors.transparent,
                icon: Image(
                      image: AssetImage("assets/images/tab_discover_after.png"),
                      height: 27,
                      width: 27,
                    ),
                activeIcon: Image(
                      image: AssetImage("assets/images/tab_discover_before.png"),
                      height: 27,
                      width: 27,
                    ),
                label: "",
              ),
            ],
            showUnselectedLabels: false,
            showSelectedLabels: false,
            currentIndex: selectedIndex,
            backgroundColor: const Color.fromRGBO(19, 21, 27, 0.58),
            type: BottomNavigationBarType.fixed,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  Widget MyTileBody({String icon = "", String title = ""}) {
    return Row(
      children: [
        SvgHelper(
          icon,
          color: Colors.white,
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
