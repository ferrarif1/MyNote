import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/generated/l10n.dart';
import 'package:coinstart_wallet_extension/setup/page/general_info_page.dart';
import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:neveruseless/neveruseless.dart';

import '../../main.dart';
class SetupPage extends StatefulWidget {
  final Map? arguments;
  const SetupPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  var email = '';

  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/SetupPage';

    neverLocalStorageRead('register_email').then((v) {
      email = v;
      setState(() {});
    });

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
        backgroundColor: APP_MainBGColor,
        body:Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: ListView(
            children: [
              suiWallet.hasWallet ?
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.pushNamed(context, "/SelectWalletPage");
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: Image(image: const AssetImage("assets/images/coinstart_logo_white.png"),width: 42,height: 42, fit: BoxFit.contain,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  return Container(
                                    width: 42,height: 42,
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Icon(Icons.sms_failed_rounded,color: Colors.grey.withOpacity(0.2),),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Text(suiWallet.currentWallet!.name!,style: TextStyle(fontSize: 14,color: Colors.white),),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_right_rounded,color: Colors.white,size: 20,)
                          ],
                        ),
                      ),
                    ),

                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(54, 54, 54, 1),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Image(image: AssetImage("assets/images/fire.png"),height: 17,width: 17,),
                          SizedBox(width: 15,),
                          Text("Airdrop",style: TextStyle(fontSize: 14,color: Colors.white),),
                        ],
                      ),
                    ),

                    InkWell(
                      onTap: (){
                        // if(true){
                        //   Navigator.pushNamed(context, "/BinDingMailPage");
                        // }
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(S.current.Email, style: const TextStyle(color: Colors.white),),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              // decoration: BoxDecoration(
                              //   color: false ? Colors.green.withOpacity(0.4) : const Color.fromRGBO(255,53,53,1).withOpacity(0.3),
                              //   borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                              // ),
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Text(email,
                                style: const TextStyle(fontSize: 12,color: Colors.white),),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1,color: Color.fromRGBO(54, 54, 54, 1),),

                    InkWell(
                      onTap: (){
                        Navigator.pushNamed(context, "/SelectLanguagePage").then((value){
                          setState(() {});
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(S.current.Language, style: const TextStyle(color: Colors.white),),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Text(localNow, style: const TextStyle(fontSize: 11,color: Colors.white),),
                            ),
                            const Icon(Icons.keyboard_arrow_right_outlined,color: Colors.white,size: 18,)
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1,color: Color.fromRGBO(54, 54, 54, 1),),

                    InkWell(
                      onTap: (){
                        Navigator.pushNamed(context, "/SelectParaPage").then((value){
                          setState(() {});
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(S.current.Para_Birimi, style: const TextStyle(color: Colors.white),),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Text(localPara, style: const TextStyle(fontSize: 11,color: Colors.white),),
                            ),
                            const Icon(Icons.keyboard_arrow_right_outlined,color: Colors.white,size: 18,)
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1,color: Color.fromRGBO(54, 54, 54, 1),),

                    InkWell(
                      onTap: (){
                        Navigator.pushNamed(context, "/AboutUsPage");
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(S.current.About, style: const TextStyle(color: Colors.white),),
                            ),
                            const Icon(Icons.keyboard_arrow_right_outlined,color: Colors.white,size: 18,)
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1,color: Color.fromRGBO(54, 54, 54, 1),),



                    // InkWell(
                    //   onTap: (){
                    //     Navigator.pushNamed(context, "/CreateNewWalletPage",arguments: {
                    //       "canBack" : "true",
                    //     });
                    //   },
                    //   child: Row(
                    //     children: [
                    //       const Icon(Icons.add,color: Colors.white,),
                    //       const SizedBox(width: 10),
                    //       Text(S.current.Create_Account, style: const TextStyle(color: Colors.white),),
                    //     ],
                    //   ),
                    // ),
                    // InkWell(
                    //   onTap: (){
                    //     Navigator.pushNamed(context, "/ImportWalletPage",arguments: {
                    //       "canBack" : "true",
                    //     });
                    //   },
                    //   child: Container(
                    //     padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    //     child: Row(
                    //       children: [
                    //         const Image(image: AssetImage("assets/images/login.png"),width: 20,height: 20,),
                    //         const SizedBox(width: 14),
                    //         Text(S.current.Import_Account, style: const TextStyle(color: Colors.white),),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // ConfigurableExpansionTile(
                    //     header: Expanded(
                    //       child: Container(
                    //         padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    //         child: Row(
                    //           children: [
                    //             const Image(image: AssetImage("assets/images/settings.png"),width: 20,height: 20,),
                    //             const SizedBox(width: 14),
                    //             Text(S.current.Setting, style: const TextStyle(color: Colors.white),),
                    //             const Expanded(child: SizedBox()),
                    //             const Icon(Icons.keyboard_arrow_down_rounded,color: Colors.white,),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     childrenBody:Container(
                    //       padding: const EdgeInsets.fromLTRB(33, 0, 0, 0),
                    //       alignment: Alignment.centerLeft,
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           const SizedBox(height: 27),
                    //           InkWell(
                    //             onTap: () {
                    //               AwesomeDialog(
                    //                 context: context,
                    //                 headerAnimationLoop: false,
                    //                 dismissOnBackKeyPress: true,
                    //                 dialogType: DialogType.noHeader,
                    //                 animType: AnimType.bottomSlide,
                    //                 body: Column(
                    //                   children: [
                    //                     Container(
                    //                       alignment: Alignment.center,
                    //                       padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    //                       child: Row(
                    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                         children: [
                    //                           GestureDetector(
                    //                               behavior: HitTestBehavior.opaque,
                    //                               onTap: (){
                    //                                 Navigator.pop(context);
                    //                               },
                    //                               child: Row(
                    //                                 children: [
                    //                                   Container(
                    //                                     decoration: const BoxDecoration(
                    //                                       color: Color.fromRGBO(34, 35, 39, 1),
                    //                                       borderRadius: BorderRadius.all(Radius.circular(3.0)),
                    //                                     ),
                    //                                     child: const Icon(Icons.chevron_left,color: Colors.white,),
                    //                                   ),
                    //                                   const SizedBox(width: 5,),
                    //                                   Text(S.current.General_information, style: const TextStyle(color: Colors.white, fontSize: 14),),
                    //                                 ],
                    //                               )
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                     const GeneralInfoPage(),
                    //                   ],
                    //                 ),
                    //               ).show();
                    //             },
                    //             child: Text(S.current.General_information, style: const TextStyle(color: Colors.white,),),
                    //           ),
                    //           const SizedBox(height: 20),
                    //           InkWell(
                    //             onTap: () {
                    //               Navigator.pushNamed(context, "/WalletInfoPage");
                    //             },
                    //             child: Text(S.current.Wallet_information, style: const TextStyle(color: Colors.white,),),
                    //           ),
                    //           const SizedBox(height: 20),
                    //           InkWell(
                    //             onTap: () {
                    //               AwesomeDialog(
                    //                 context: context,
                    //                 headerAnimationLoop: false,
                    //                 dismissOnBackKeyPress: true,
                    //                 dialogType: DialogType.noHeader,
                    //                 animType: AnimType.bottomSlide,
                    //                 body: Column(
                    //                   children: [
                    //                     Container(
                    //                       alignment: Alignment.center,
                    //                       padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    //                       child: Row(
                    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                         children: [
                    //                           GestureDetector(
                    //                               behavior: HitTestBehavior.opaque,
                    //                               onTap: (){
                    //                                 Navigator.pop(context);
                    //                               },
                    //                               child: Row(
                    //                                 children: [
                    //                                   Container(
                    //                                     decoration: const BoxDecoration(
                    //                                       color: Color.fromRGBO(34, 35, 39, 1),
                    //                                       borderRadius: BorderRadius.all(Radius.circular(3.0)),
                    //                                     ),
                    //                                     child: const Icon(Icons.chevron_left,color: Colors.white,),
                    //                                   ),
                    //                                   const SizedBox(width: 5,),
                    //                                   Text(S.current.Security_and_Privacy, style: const TextStyle(color: Colors.white, fontSize: 14),),
                    //                                 ],
                    //                               )
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                     const GeneralInfoPage(),
                    //                   ],
                    //                 ),
                    //               ).show();
                    //             },
                    //             child: Text(S.current.Security_and_Privacy, style: const TextStyle(color: Colors.white,),),
                    //           ),
                    //           const SizedBox(height: 20),
                    //           InkWell(
                    //             onTap: () {
                    //               Navigator.pushNamed(context, "/AboutUsPage");
                    //             },
                    //             child: Text(S.current.Follow_Us, style: const TextStyle(color:  Colors.white,),),
                    //           ),
                    //         ],
                    //       ),
                    //     )
                    // ),
                    // const SizedBox(height: 30,),
                    // const Divider(height: 1,color: Colors.grey,),
                  ],
                ),
              ):
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pushNamedAndRemoveUntil(context, "/RegisterPage",(route) => false,);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: APP_MainBgViewColor,
                    foregroundColor: APP_MainBgViewColor,
                    minimumSize: const Size(360, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ), // NEW
                  ),
                  child: Text(S.current.Create_Wallet, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
                  ),
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       ConfigurableExpansionTile(
              //           header: Expanded(
              //             child: Container(
              //               padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              //               child: Row(
              //                 children: [
              //                   const Image(image: AssetImage("assets/images/globe.png"),width: 20,height: 20,),
              //                   const SizedBox(width: 14),
              //                   Text(S.current.Language, style: const TextStyle(color: Colors.white),),
              //                   const Expanded(child: SizedBox()),
              //                   const Icon(Icons.keyboard_arrow_down_rounded,color: Colors.white,),
              //                 ],
              //               ),
              //             ),
              //           ),
              //           childrenBody:Container(
              //             padding: const EdgeInsets.fromLTRB(33, 0, 0, 0),
              //             alignment: Alignment.centerLeft,
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 const SizedBox(height: 10),
              //                 InkWell(
              //                   onTap: () {
              //                     neverBus.emit("checkLanguage","zh");
              //                     // print("object");
              //                     // setState(() {
              //                     //   S.load(const Locale("zh", "ZH"));
              //                     // });
              //                   },
              //                   child: const Text("中文", style: TextStyle(color: Colors.white,),),
              //                 ),
              //                 const SizedBox(height: 20),
              //                 InkWell(
              //                   onTap: () {
              //                     neverBus.emit("checkLanguage","en");
              //                     // setState(() {
              //                     //   S.load(const Locale('en', 'US'));
              //                     // });
              //                   },
              //                   child: const Text('English', style: TextStyle(color: Colors.white,),),
              //                 ),
              //                 const SizedBox(height: 20),
              //               ],
              //             ),
              //           )
              //       ),
              //       const SizedBox(height: 28),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
