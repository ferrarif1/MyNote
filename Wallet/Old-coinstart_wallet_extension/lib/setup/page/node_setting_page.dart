import 'package:coinstart_wallet_extension/Base/Global.dart';
import 'package:coinstart_wallet_extension/base/image_helper.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
class NodeSettingPage extends StatefulWidget {
  final Map? arguments;
  const NodeSettingPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _NodeSettingPageState();
}

class _NodeSettingPageState extends State<NodeSettingPage> {


  @override
  void initState() {
    super.initState();
    PagePick.nowPageName = '/NodeSettingPage';
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
        body:Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(34, 35, 39, 1),
                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                        ),
                        child: const Icon(Icons.chevron_left,color: Colors.white,),
                      ),
                      const SizedBox(width: 5,),
                      Text(S.current.Node_settings, style: TextStyle(color: Colors.white, fontSize: 14),),
                    ],
                  )
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context,index){
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          child: Text('${S.current.Node_Name}${index.toString()}', style: const TextStyle(color: Colors.white, fontSize: 13,),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){

                          },
                          behavior: HitTestBehavior.opaque,
                          child: const SvgHelper('/icons/node_setting_check.svg'),
                        )
                      ],
                    ),
                  );
                }
              ),
            ),
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
                    borderRadius: BorderRadius.circular(7.0),
                  ), // NEW
                ),
                child: Text(S.current.Confirm, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}