import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_star/flutter_star.dart';

import '../../main.dart';
class DAppDetailsPage extends StatefulWidget {
  final Map? arguments;
  const DAppDetailsPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _DAppDetailsPageState();
}

class _DAppDetailsPageState extends State<DAppDetailsPage> {


  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/DAppDetailsPage';
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
          title: const Text(""),
        ),
        body:Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                  child: const Image(image: AssetImage("assets/icons/crypto/testIcon.png"),height: 48,width: 48,fit: BoxFit.contain,),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Art Blocks",style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.w600),),
                        const SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AbsorbPointer(
                              child: CustomRating(
                                max: 5,
                                score: 5.0,
                                star: Star(num: 5, fillColor: Colors.orangeAccent, fat: 0.5, emptyColor: Colors.grey.withAlpha(88),size: 16),
                                onRating: (s) {
                                  print(s);
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              alignment: Alignment.centerLeft,
                              child: const Text("5.0",style: TextStyle(color: Colors.orangeAccent,fontSize: 16),),
                            )
                          ],
                        ),
                      ],
                    )
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
              child: const Text("Dapp description",
                style: TextStyle(fontSize: 12,color: Colors.grey,fontWeight: FontWeight.w600),),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: APP_MainGrayColor,
                      border: Border.all(width: 1.5, color: APP_MainGrayColor),
                      borderRadius: const BorderRadius.all(Radius.circular(99.0)),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Image(image: AssetImage("assets/icons/crypto/SUI.png"),height: 15,width: 15,),
                        const SizedBox(width: 5,),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                          child: const Text("SUI",style: TextStyle(fontSize: 12,color: Colors.white),),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
              ),
              child: Image.asset('assets/images/top_img.png', fit: BoxFit.cover,),
            ),
            const Expanded(child: SizedBox()),
            InkWell(
              onTap: () async {
                Navigator.pop(context);
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
                  child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontSize: 16,),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
