import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
class GeneralInfoPage extends StatefulWidget {
  final Map? arguments;
  const GeneralInfoPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _GeneralInfoPageState();
}

class _GeneralInfoPageState extends State<GeneralInfoPage> {


  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/GeneralInfoPage';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: ListView(
        children: [
          Container(
            width: 460,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      ImageHelper('/images/coinstart_logo.png',height: 20,width: 20,),
                      SizedBox(width: 5,),
                      ImageHelper('/images/coinstart_logo_word.png',height: 10,),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: const Text("Coinstart wallet", style: TextStyle( fontSize: 14),),
                ),
                const Divider(color: Color(0xff565656)),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.current.Email, style: const TextStyle(fontSize: 14),),
                      const Text("ABC@gmail.com", style: TextStyle( fontSize: 14),),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.current.Check_for_updates, style: const TextStyle(fontSize: 14),),
                      const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,size: 16,)
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.current.User_Agreement, style: const TextStyle(fontSize: 14),),
                      const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,size: 16,)
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.current.Privacy_Agreement, style: const TextStyle(fontSize: 14),),
                      const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,size: 16,)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

