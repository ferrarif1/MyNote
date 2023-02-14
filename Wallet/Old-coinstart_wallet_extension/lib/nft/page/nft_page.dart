import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:flutter/material.dart';

import '../../api/sui_api.dart';
import '../../api/sui_wallet.dart';
import '../../controller/sui_sdk.dart';
import '../../main.dart';

class NFTPage extends StatefulWidget {
  final Map? arguments;
  const NFTPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _NFTPageState();
}

class _NFTPageState extends State<NFTPage> {
  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/NFTPage';
  }

  @override
  void dispose() {
    super.dispose();
  }

  getNFT() async{ 
    await suiWallet.getNFTs();
    List<SuiObject> nfts = suiWallet.currentWalletNFTs;
    for (SuiObject element in nfts) {
      print("NFT : "+element.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

 


   print("Test nft mint start**************************");

    const name = 'NFT for test';
    const desc = 'Coinstart NFT description';
    const url =
        'https://gateway.pinata.cloud/ipfs/QmZ73jRb723qXftdpwmcry7vvn43dLfj3SuJddk2ZMuL4a/IMG_6646.jpg';
   
    String pwd = "";
    ////Step 1. Mint

    MoveCallTransaction mintNFT = MoveCallTransaction(
        packageObjectId: '0x2',
        module: 'devnet_nft',
        function: 'mint',
        typeArguments: [],
        arguments: [name, desc, url],
        gasPayment: null,
        gasBudget: defaultGasBudgetForMoveCall);
    suiWallet.suiMoveCall(mintNFT, pwd);

    ////Step 2. get all nft
    getNFT();

    ////Step 3. transfer nft
    // List<SuiObject> nfts = suiWallet.currentWalletNFTs;
    // suiWallet.transferNFT(nfts[0], '0x53b8f1fc4c018e73ff1c64d7415cfef2ceca3355', pwd);

    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
        body: Container(
          color: APP_MainBGColor,
          child: ListView(
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(34, 35, 39, 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3.0)),
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "NFT",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "最新上线",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //每行三列
                    childAspectRatio: 0.65, //显示区域宽高相等
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 20,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/NFTDetailsPage",
                            arguments: {
                              "1": "1",
                            });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(0),
                            child: const Image(
                              image: AssetImage("assets/images/testImage2.png"),
                              fit: BoxFit.contain,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Monster Polyart",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "#3301",
                              style:
                                  TextStyle(fontSize: 11, color: Colors.white),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: const [
                                  Image(
                                    image:
                                        AssetImage("assets/icons/crypto/ETH.png"),
                                    fit: BoxFit.contain,
                                    height: 15,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "0.014",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white),
                                  ),
                                  Text(
                                    " ~ \$21.20",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "前沿市场",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //每行三列
                    childAspectRatio: 0.65, //显示区域宽高相等
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 20,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/NFTDetailsPage",
                            arguments: {
                              "1": "1",
                            });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(0),
                            child: const Image(
                              image: AssetImage("assets/images/testImage2.png"),
                              fit: BoxFit.contain,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Monster Polyart",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "#3301",
                              style:
                                  TextStyle(fontSize: 11, color: Colors.white),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: const [
                                  Image(
                                    image:
                                        AssetImage("assets/icons/crypto/ETH.png"),
                                    fit: BoxFit.contain,
                                    height: 15,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "0.014",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white),
                                  ),
                                  Text(
                                    " ~ \$21.20",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
