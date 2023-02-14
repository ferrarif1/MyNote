import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../main.dart';
class GameFiPage extends StatefulWidget {
  final Map? arguments;
  const GameFiPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _GameFiPageState();
}

class _GameFiPageState extends State<GameFiPage> with AutomaticKeepAliveClientMixin  {

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    //PagePick.nowPageName = '/CommunityAnnouncementPage';

    neverBus.on('checkLanguage', (object) {
      setState(() {
        if(object == "en"){
          print("切换语言EN");
          localNow = "English";
          S.load(const Locale('en', 'US'));
        }else{
          print("切换语言ZH");
          localNow = "中文简体";
          S.load(const Locale("zh", "ZH"));
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
        body:Container(
          color: APP_MainBGColor,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Image.asset('assets/images/top_img.png', fit: BoxFit.cover,),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: APP_MainGrayColor,
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 5, 10, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(S.current.All, style:const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),),
                        const Icon(Icons.keyboard_arrow_down_rounded,color: Colors.white,),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text(S.current.Collect, style:const TextStyle(color: Color(0xffCBCBCB), fontSize: 16, fontWeight: FontWeight.w400),),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text(S.current.Browsing_history, style: const TextStyle(color: Color(0xffCBCBCB), fontSize: 16, fontWeight: FontWeight.w400),),
                  ),


                ],
              ),
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // 内部禁止滑动
                itemBuilder: (context, index){
                  return InkWell(
                    onTap: ()  {

                      // Get.to(GameFiDetailsPage());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: APP_MainGrayColor,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/logo.svg', semanticsLabel: 'Logo', height: 121, width: 121),
                          const SizedBox(width: 18,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Ghost Run', style: TextStyle(color:Colors.white,fontSize: 18, fontWeight: FontWeight.w700),),
                                const SizedBox(height: 5,),
                                Row(
                                  children: [
                                    Image.asset('assets/xing.png', width: 15,),
                                    const SizedBox(width: 5,),
                                    const Text('2124', style: TextStyle(color:Colors.white,fontSize: 14, fontWeight: FontWeight.w700),),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                const Text('This is a horror theme parkour game.How to play: Use your fingers to control fooling around, accumulating skeletons along the way', style: TextStyle(color: Color(0xffE7E7E7),fontSize: 14, fontWeight: FontWeight.w500),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 20,);
                },
                itemCount: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}