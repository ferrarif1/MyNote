import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
class AboutUsPage extends StatefulWidget {
  final Map? arguments;
  const AboutUsPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {


  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/AboutUsPage';
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
          title: Text(S.current.About),
        ),
        body:Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
              child: const Image(image: AssetImage("assets/images/index_icon.png"),fit: BoxFit.contain,width: 71,height: 71,),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: const Divider(height: 1,color: Colors.grey,),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              alignment: Alignment.center,
              child: const Text("Socialfi- Encrypted Communication with our IM, to connect people, money and connections,"
                  " it supports red envelope, social account, Groupchat and payment."
                  " We doesn’t track any personal identifiable information, your account addresses, or asset balances."
                  " . Group Chat- Constart allows thousands of people to chat with group, "
                  "with a handful of friends can spend time together."
                  " A place that makes it easy to talk every day and hang out more often.",
                style: TextStyle(fontSize: 11,color: Colors.grey,height: 2),),
            ),

          ],
        ),
      ),
    );
  }
}