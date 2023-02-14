
import 'package:coinstart_wallet_extension/base/Global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
class DAppPage extends StatefulWidget {
  final Map? arguments;
  const DAppPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _DAppPageState();
}

class _DAppPageState extends State<DAppPage> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/DAppPage';

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
        appBar: AppBar(
          title: Container(
            alignment: Alignment.centerLeft,
            child: const Text("Dapp",style: TextStyle(fontSize: 20),),
          ),
        ),
        body:false?
        Container(
          alignment: Alignment.center,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(image: AssetImage("assets/images/no_dapp.png"),width: 61,height: 61,),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                alignment: Alignment.center,
                child: Text(S.current.Null_Dapp,style: const TextStyle(fontSize: 12,color: APP_MainTextGrayColor),),
              )

            ],
          ),
        ):
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: APP_MainBGColor,
            child: ListView(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  height: 40,
                  child: TextField(
                    controller: addressController,
                    cursorColor: APP_MainPurpleColor,
                    style: const TextStyle(color: Colors.white,fontSize: 13,height: 1),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      fillColor:APP_MainBlackColor,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Color.fromRGBO(78, 79, 82, 1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Color.fromRGBO(78, 79, 82, 1)),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,size: 18,color: APP_MainTextGrayColor,),
                    ),


                    onChanged: (e){
                      // setState(() {});
                    },
                  ),
                ),
                SizedBox(
                  height: 128,
                  child:  Swiper(
                    itemBuilder: (context, index){
                      return Image.asset('assets/images/top_img.png', fit: BoxFit.contain);
                    },
                    itemCount: 1,
                    pagination: const SwiperPagination(),
                    control: const SwiperControl(
                        color: Colors.transparent
                    ),
                    viewportFraction: 0.8,
                    scale: 0.9,
                  ),
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 20),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 6,
                    itemBuilder: (context,index){
                      return GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(context, "/DAppDetailsPage");

                          return;

                          showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context){
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(20, 21, 26, 1),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                height: 500,
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Go to DApps", style: TextStyle(color: Colors.white,fontSize: 13),),
                                          GestureDetector(
                                            onTap: (){
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              alignment: Alignment.centerRight,
                                              child: const Icon(Icons.close,color: Colors.white,size: 20,),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 2,color: APP_MainGrayColor,),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                          child: const Image(image: AssetImage("assets/icons/crypto/testIcon.png"),height: 35,width: 35,fit: BoxFit.contain,),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          child:const Text("Art Blocks",style: TextStyle(fontSize: 13,color: Colors.white,fontWeight: FontWeight.w600),),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                                      child: const Text("Dapp description",
                                        style: TextStyle(fontSize: 12,color: Colors.grey,fontWeight: FontWeight.w600),),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
                                      child: const Text("Supported networks", style: TextStyle(color: Colors.white,fontSize: 13,fontWeight: FontWeight.w600),),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(width: 1.5, color: APP_MainGrayColor),
                                              borderRadius: const BorderRadius.all(Radius.circular(99.0)),
                                            ),
                                            padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
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
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                      alignment: Alignment.center,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: APP_MainBgViewColor,
                                          foregroundColor: APP_MainBgViewColor,

                                          minimumSize: const Size(360, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24.0),
                                          ), // NEW
                                        ),
                                        child: Text(S.current.Confirm, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              );
                            },
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child:Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child:  Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                child: const Image(image: AssetImage("assets/icons/crypto/testIcon.png"),height: 35,width: 35,fit: BoxFit.contain,),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                        child:Row(
                                          children: const [
                                            Text("Art Blocks",style: TextStyle(fontSize: 13,color: Colors.white,fontWeight: FontWeight.w600),),
                                            SizedBox(width: 10,),
                                            Image(image: AssetImage("assets/icons/crypto/erc.png"),height: 10,),
                                          ],
                                        )
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                                      child: const Text("The Lido Ethereum Liquid Staking Protocol, built on Ethereum 2.0's Beacon chain,",
                                        style: TextStyle(fontSize: 10,color: APP_MainTextGrayColor,fontWeight: FontWeight.w600),),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
               
              ],
            ),
          ),
        )
      ),
    );
  }
}





