import 'package:flutter/services.dart';
import 'dart:math' as math;


class TextInput_onlyNum extends TextInputFormatter {

  TextInput_onlyNum({this.integerRange = 6,this.decimalRange = 4})
      : assert(decimalRange == null || decimalRange >= 0);

  final int decimalRange;
  final int integerRange;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue) {
    // 拿到录入后的字符
    String nValue = newValue.text;
    //当前所选择的文字区域
    TextSelection nSelection = newValue.selection;

    // 先来一波过滤，过滤出数字及小数点
    // 匹配包含数字和小数点的字符
    Pattern p = RegExp(r'-|(\d+\.?)|(\.?\d+)|(\.?)');
    nValue = p.allMatches(nValue)
        .map<String>((Match match) => match.group(0)!)
        .join();


    // 用匹配完的字符判断

    //判断是否存在 - 号，如果存在，且不是在开头，那么把这个符号拼接到开头，同时实现输入过程中的正负转化
    if(nValue.contains('-') && nValue.indexOf('-') > 0){
      List<String> split = nValue.split('-');
      nValue = '-' + split[0] + split[1];
    }

    //多个 - 号，去掉多余的 - 号
    if (nValue.split('-').length > 2) {
      List<String> split = nValue.split('-');
      nValue = '-' + split[0] + split[1];
    }

    //如果小数点开头，我们给他补个0
    if (nValue.startsWith('.')) {
      nValue = '0.';
    } else if (nValue.contains('.')) {//如果存在小数点
      if(nValue.indexOf('.') > (nValue.contains('-') ? integerRange+1 : integerRange)){ // 存在小数点时，判断是否输入负号，若输入的负号，则长度需要+1
        nValue = oldValue.text;
      }
      //来验证小数点位置
      if (nValue.substring(nValue.indexOf('.') + 1).length > decimalRange) {
        nValue = oldValue.text;
      } else {
        if (nValue.split('.').length > 2) { //多个小数点，去掉后面的
          List<String> split = nValue.split('.');
          nValue = split[0] + '.' + split[1];
        }
      }
    }else if(nValue.length > (nValue.contains('-') ? integerRange+1 : integerRange)){//这里为了保证没有小数点时，输入整数部分达最大时，可以正确输入负号
      nValue = oldValue.text;
    }

    //使光标定位到最后一个字符后面
    nSelection = newValue.selection.copyWith(
      baseOffset: math.min(nValue.length, nValue.length + 1),
      extentOffset: math.min(nValue.length, nValue.length + 1),
    );

    return TextEditingValue(
        text: nValue,
        selection: nSelection,
        composing: TextRange.empty
    );
  }
}