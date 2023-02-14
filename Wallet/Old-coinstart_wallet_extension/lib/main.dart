import 'package:bot_toast/bot_toast.dart';
import 'package:coinstart_wallet_extension/Base/routes.dart';
import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:coinstart_wallet_extension/controller/sui_wallet_controller.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/home_page.dart';
import 'package:coinstart_wallet_extension/register/page/register_page.dart';
import 'package:coinstart_wallet_extension/setup/page/need_password_page.dart';
import 'package:coinstart_wallet_extension/wallet/page/record_page.dart';
import 'package:coinstart_wallet_extension/wallet/page/swap_page.dart';
import 'package:coinstart_wallet_extension/wallet/page/swap_record_details_page.dart';
import 'package:coinstart_wallet_extension/wallet/pagekbg/record_detail_page.dart';
import 'package:coinstart_wallet_extension/wallet/pagekbg/swap_detail_page_kbg.dart';
import 'package:coinstart_wallet_extension/wallet/pagekbg/swap_page_kbg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neveruseless/neveruseless.dart';

String localNow = "English";
String localPara = "CNY";
SuiApi suiApi = SuiApi();
SuiWalletController suiWallet = SuiWalletController();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Get.put(suiApi);
  await suiWallet.loadStorageWallet();
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: const MyApp(),
    // locale: Get.deviceLocale,
    locale: const Locale('en'),
    fallbackLocale: const Locale('en'),
    // translations: MyTranslations(),
    builder: EasyLoading.init(),
  ));
  // runApp(const MyApp());
  ErrorWidget.builder = (FlutterErrorDetails error) {
    return const Center(
      child: Text("遇到错误,请联系客服"),
    );
  };
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    Clipboard.setData(const ClipboardData(text: ""));

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(suiWallet);
    // print(MediaQuery.of(context).size.height);
    // print(MediaQuery.of(context).size.width);
    return ScreenUtilInit(
      designSize: const Size(360, 600),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'CoinStart',
          navigatorKey: navigatorKey,
          onGenerateRoute: onGenerateRoute,
          navigatorObservers: [BotToastNavigatorObserver()],
          // scrollBehavior: MyCustomScrollBehavior(),
          builder: BotToastInit(),
          debugShowCheckedModeBanner: false,
          locale: const Locale('en', 'US'),
          localizationsDelegates: const [S.delegate, GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
          // 讲zh设置为第一项，缺省为英文
          supportedLocales: const <Locale>[
            Locale('en', 'US'),
            Locale("zh", "ZH"),
          ],
          theme: ThemeData(
            textTheme: const TextTheme(
              displayMedium: TextStyle(textBaseline: TextBaseline.alphabetic),
              bodyMedium: TextStyle(color: Colors.white, fontSize: 13),
            ),
            fontFamily: 'AliPuHuiTi',
            cardColor: APP_MainBGColor, //为了弹窗
            brightness: Brightness.light,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            canvasColor: APP_MainBGColor, //页面背景色
            appBarTheme: const AppBarTheme(
              color: APP_MainBGColor,
              elevation: 0.0,
              iconTheme: IconThemeData(size: 18, color: Colors.white),
              titleTextStyle: TextStyle(fontFamily: 'AliPuHuiTi', color: Colors.white, fontSize: 16),
            ),
          ),
          home: suiWallet.hasWallet ? const NeedPasswordPage() : const RegisterPage(), //suiWallet.hasWallet? const HomePage() : const RegisterPage(),
        );
      },
    );
  }
}

//全局临时参数
class PagePick {
  static String nowPageName = '';
}

//插件
//flutter build web --web-renderer html --csp

//H5
// flutter build web --pwa-strategy none --web-renderer canvaskit --release
