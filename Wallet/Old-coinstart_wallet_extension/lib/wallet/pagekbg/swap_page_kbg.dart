import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../main.dart';

class SwapPageNew extends StatefulWidget {
  final Map? arguments;

  const SwapPageNew({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _SwapPageNewState();
}

class _SwapPageNewState extends State<SwapPageNew> {
  List allCoinList = [
    "ETH",
    "SUI",
    "AVAX",
    "BNB",
    "FIL",
    "OKX",
    "SNX",
    "TRX",
    "USDT",
  ];

  String fromCoin = "ETH";

  String toCoin = "USDT";

  final TextEditingController sellController = TextEditingController();
  final TextEditingController buyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/SwapPage';
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
        appBar: AppBar(
          title: Text(S.current.Swap),
          actions: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushNamed(context, "/SwapRecordPage");
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Text(
                  S.current.Swap_Record,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        body: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child:
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              const SizedBox(
                height: 6,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 240,
                  ),
                  Positioned(
                      top: 2,
                      left: 0,
                      right: 0,
                      child: getCardView(S.current.Sell_Away, fromCoin, 'from',
                          sellController)),
                  Positioned(
                      top: 120,
                      left: 0,
                      right: 0,
                      child: getCardView(
                          S.current.Buy_In, toCoin, 'to', buyController)),
                  // Positioned(
                  //     top: 100,
                  //     left: ,
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        String tt = fromCoin;
                        fromCoin = toCoin;
                        toCoin = tt;
                      });
                    },
                    child: Image.asset(
                      'assets/images/cash_transaction_change.png',
                      width: 32,
                      height: 32,
                    ),
                    //)
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  decoration: const BoxDecoration(
                    color: APP_MainPurpleColor,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: Text(
                        S.current.Swap,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: APP_FONT_POPPINS),
                      )),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                '1 $fromCoin ≈ 1 $toCoin ',
                style: const TextStyle(
                    color: Color(0xff737373),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: APP_FONT_MONTSERRAT),
              ),
            ])),
      ),
    );
  }

  Container getCardView(String title, String coinName, String coinDirection,
      TextEditingController textEditingController) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.black,
        ),
        child: Column(
          children: [
            //Head
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: APP_FONT_MONTSERRAT),
                ),
                Text(
                  "${S.current.Balance}:0.00",
                  style: const TextStyle(
                      color: Color(0xff737373),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: APP_FONT_MONTSERRAT),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  ImageHelper(
                    '/icons/crypto/$coinName.png',
                    width: 38,
                    height: 38,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                          onTap: () {
                            addCoinSheet(coinDirection);
                          },
                          child: Row(
                            children: [
                              Text(
                                coinName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const ImageHelper('/icons/arrow_down.png'),
                            ],
                          )),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        coinName,
                        style: const TextStyle(
                            color: Color(0xff737373),
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ]),
                Expanded(
                  child: TextField(
                      controller: textEditingController,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          textBaseline: TextBaseline.alphabetic,
                          fontWeight: FontWeight.w700,
                          fontFamily: APP_FONT_MONTSERRAT),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Color(0xff737373)),
                      ),
                      onChanged: (e) {
                        if (e == "") {
                        } else {}
                      }),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ));
  }

  addCoinSheet(String fromTO) {
    TextEditingController searchController = TextEditingController();
    List tempCoinList = [];
    tempCoinList.addAll(allCoinList);
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, mSetState) {
            // final TextEditingController searchController = TextEditingController();
            return Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(36, 38, 44, 1),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              height: 575,
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18.0,horizontal: 0.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(width: MediaQuery.of(context).size.width,),
                        Text(
                          fromTO == 'from' ? S.current.Sell_Token_tip : S.current.Buy_Token_tip,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600,fontFamily: APP_FONT_MONTSERRAT),
                        ),
                        Positioned(
                            right: 18,
                            child:
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                // color: Colors.white,
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                alignment: Alignment.centerRight,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 2,
                    color: APP_MainGrayColor,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 20),
                    child: TextField(
                      controller: searchController,
                      cursorColor: const Color(0xFF584ED3),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          textBaseline: TextBaseline.alphabetic),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                        const EdgeInsets.fromLTRB(10, 0, 10, 20),
                        fillColor: const Color.fromRGBO(30, 30, 30, 1),
                        filled: true,
                        hintText: S.current.Search,
                        hintStyle: const TextStyle(color: Colors.white54, fontFamily: APP_FONT_POPPINS,fontSize: 12,fontWeight: FontWeight.w400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.solid,
                              color: Color.fromRGBO(55, 55, 55, 1)
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ),
                      onChanged: (coin) {
                        if (coin == "") {
                          tempCoinList.clear();
                          tempCoinList.addAll(allCoinList);
                        } else {
                          tempCoinList.clear();
                          tempCoinList.addAll(allCoinList.where((element) =>
                              element
                                  .toString()
                                  .toUpperCase()
                                  .contains(coin.toString().toUpperCase())));
                        }
                        setState(() {});
                        mSetState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tempCoinList.length,
                      itemBuilder: (context, index) {
                        String coin = tempCoinList[index];
                        return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (fromTO == "from") {
                                fromCoin = coin;
                              } else {
                                toCoin = coin;
                              }
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: Container(
                              padding:
                              const EdgeInsets.fromLTRB(20, 10, 10, 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ImageHelper(
                                    '/icons/crypto/$coin.png',
                                    height: 30,
                                    width: 30,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    coin,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: APP_FONT_POPPINS),
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
