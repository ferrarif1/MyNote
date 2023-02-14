import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/api/sui_api.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class NFTDetailsPage extends StatefulWidget {
  final Map? arguments;
  const NFTDetailsPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _NFTDetailsPageState();
}

class _NFTDetailsPageState extends State<NFTDetailsPage> {
  SuiObject? data;
  Map? _nftData = {};
  String? nftName = "";

  String url = ""; //_nftsList![index].fields["url"];

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/NFTTransferPage';
    data = widget.arguments!["data"];
    _nftData = data!.fields;
    nftName = _nftData!["name"];
    url = _nftData!["url"];
    if (url.contains("ipfs://")) {
      url = url.replaceAll("ipfs://", "https://ipfs.io/ipfs/");
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
        appBar: AppBar(
          title: Text(nftName!),
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(14.0)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image(
                      image: NetworkImage(url),
                      fit: BoxFit.contain,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return Container(
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
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nftName!,
                        style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        _nftData!["description"],
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.current.Current_price,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                //   alignment: Alignment.centerLeft,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: const [
                //       Image(image: AssetImage("assets/icons/crypto/ETH.png"),fit: BoxFit.contain,height: 20,),
                //       SizedBox(width: 10),
                //       Text("0.014 ETH",style: TextStyle(fontSize: 25,color: Colors.white,fontWeight: FontWeight.w700),),
                //       SizedBox(width: 10),
                //       Text("~\$21.20",style: TextStyle(fontSize: 15,color: Colors.grey,fontWeight: FontWeight.w500),),
                //     ],
                //   ),
                // ),
                // Container(
                //   padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                //   alignment: Alignment.centerLeft,
                //   child: const Text(
                //     "Sydney is a martial artist from the Eastern League. He likes to drink and will always bring wine gourds. But in fact, the amount of alcohol is very average, and the wine is a bit poor. After being drunk, he will go crazy and attack cute boys. Adventurer has been assaulted by her many times, so seeing her is a headache.  ",
                //     style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
                //   ),
                // ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(14.0)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: Image(
                          image: NetworkImage(_nftData!["url"]),
                          fit: BoxFit.cover,
                          width: 37,
                          height: 37,
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                            return Container(
                              width: 37,
                              height: 37,
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
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(5, 0, 20, 0),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "@KK",
                              style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(5, 3, 20, 0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              S.current.Creator,
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(
                  height: 100,
                ),
              ],
            ),
            InkWell(
              onTap: () async {
                Navigator.pushNamed(context, "/NFTTransferPage", arguments: {
                  "data": data,
                }).then((value) {
                  try {
                    Map t = value as Map;

                    if (t["flag"].toString() == "true") {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print(e);
                  }
                });
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: APP_MainPurpleColor,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(
                      S.current.Transfer,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
