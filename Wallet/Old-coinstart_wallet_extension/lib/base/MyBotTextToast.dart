
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

closeMyCustomBotLoading(){
  BotToast.closeAllLoading();
}

showMyCustomText(String text,{int seconds = 2}) {
  BotToast.showCustomText(
    duration: Duration(seconds: seconds),
    onlyOne: true,
    clickClose: false,//点击关闭
    crossPage: true,//跨页面
    ignoreContentClick: true,//穿透
    backgroundColor: Colors.transparent,
    backButtonBehavior: BackButtonBehavior.none,
    animationDuration: const Duration(milliseconds: 200),
    animationReverseDuration: const Duration(milliseconds: 200),
    toastBuilder: (_) => Align(
      alignment: const Alignment(0, 0.5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 1),
          //设置四周圆角 角度
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
          boxShadow: [BoxShadow(blurRadius: 10, spreadRadius: 0.5, color: Colors.black.withOpacity(0.3), offset:const Offset(1,1)),],
        ),
        // padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
        width: 240,
        height: 40,
        alignment: Alignment.center,
        child: Text(text,style: const TextStyle(fontSize: 13,color: Colors.white),textAlign: TextAlign.center,),
      ),
    ),
  );
}

//帮助文本弹窗
showMyCustomHelpText(String text,{double fontSize = 14.0}) {
  BotToast.showCustomText(
    duration: const Duration(seconds: 600),
    onlyOne: true,
    clickClose: true,//点击关闭
    crossPage: false,//跨页面
    ignoreContentClick: false,//穿透
    backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
    backButtonBehavior: BackButtonBehavior.close,
    animationDuration: const Duration(milliseconds: 200),
    animationReverseDuration: const Duration(milliseconds: 200),

    toastBuilder: (_) => Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      alignment: const Alignment(0, 0),
      child: Container(
        decoration: const BoxDecoration(
          //背景
          color: Color.fromRGBO(37, 50, 58, 1),
          //设置四周圆角 角度
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              child: Text(text,style: TextStyle(fontSize:fontSize,color: Colors.white),),
            ),
          ],
        ),
      ),
    ),
  );
}

showMyCustomLoading(String text,{double fontSize = 14.0,int seconds = 10}) {

  BotToast.showCustomLoading(
      clickClose: false,//点击关闭
      allowClick: false,//
      backButtonBehavior: BackButtonBehavior.none,
      ignoreContentClick: false,
      animationDuration: const Duration(milliseconds: 200),
      animationReverseDuration: const Duration(milliseconds: 200),
      duration: Duration(seconds: seconds,),
      backgroundColor: const Color(0x42000000),
      align: Alignment.center,
      toastBuilder: (cancelFunc) {
        return _CustomLoadWidget(cancelFunc: cancelFunc,text: text,);
      });
}

showMyCustomCopyText(String text,{int seconds = 4}) {
  BotToast.showCustomText(
    duration: Duration(seconds: seconds),
    onlyOne: true,
    clickClose: false,//点击关闭
    crossPage: true,//跨页面
    ignoreContentClick: true,//穿透
    backgroundColor: Colors.transparent,
    backButtonBehavior: BackButtonBehavior.none,
    animationDuration: const Duration(milliseconds: 200),
    animationReverseDuration: const Duration(milliseconds: 200),
    toastBuilder: (_) => Align(
      alignment: const Alignment(0, -0.2),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 1),
          //设置四周圆角 角度
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
          boxShadow: [BoxShadow(blurRadius: 10, spreadRadius: 0.5, color: Colors.black.withOpacity(0.3), offset:const Offset(1,1)),],
        ),
        // padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
        width: 240,
        height: 40,
        alignment: Alignment.center,
        child: Text(text,style: const TextStyle(fontSize: 13,color: Colors.white),),
      ),
    ),
  );
}

showError(title, message) {
  Get.showSnackbar(GetSnackBar(
    duration: 2.seconds,
    snackPosition: SnackPosition.TOP,
    borderRadius: 24,
    title: title,
    message: message,
    animationDuration: 2.seconds,
    backgroundColor: Colors.red,
  ));
}


class _CustomLoadWidget extends StatefulWidget {
  final CancelFunc? cancelFunc;
  final String? text;
  const _CustomLoadWidget({Key? key, this.cancelFunc,this.text}) : super(key: key);

  @override
  __CustomLoadWidgetState createState() => __CustomLoadWidgetState();
}

class __CustomLoadWidgetState extends State<_CustomLoadWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    animationController!.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        animationController!.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController!.forward();
      }
    });
    animationController!.forward();

    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FadeTransition(
              opacity: animationController!,
              child: const Image(image: AssetImage("assets/images/icon_allSize.png"),
                width: 60,
                height: 60,),
            ),
            const SizedBox(height: 10,),
            Text(widget.text!,),
          ],
        ),
      ),
    );
  }
}