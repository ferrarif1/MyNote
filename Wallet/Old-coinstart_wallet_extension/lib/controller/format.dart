import 'package:intl/intl.dart';

final f = DateFormat('yyyy-MM-dd HH:mm', 'en_US');
final oCcy = NumberFormat("#,##0.00", 'en_US');

addressFuzzy(String address) {
  if (address.isEmpty) {
    return '';
  }
  if (address.startsWith('0x')) {
    address = address.substring(2);
  }

  if(address.length > 6){
    final start = address.substring(0, 6);
    final end = address.substring(address.length - 3);
    return '0x$start...$end';
  }else{
    return '...';
  }
}

addressStandard(String address) {
  if (address.isEmpty) {
    return '';
  }
  if (address.startsWith('0x')) {
    return address;
  }
  return '0x$address';
}

moneyFormat(money) {
  return oCcy.format(money);
}

dateTimeFormat(date) {
  return f.format(date);
}

String encodeHEX(List<int> bytes) {
  var str = '';
  for (var i = 0; i < bytes.length; i++) {
    var s = bytes[i].toRadixString(16);
    str += s.padLeft(2 - s.length, '0');
  }
  return str;
}

/// hex decode
List<int> decodeHEX(String hex) {
  var bytes = <int>[];
  var len = hex.length ~/ 2;
  for (var i = 0; i < len; i++) {
    bytes.add(int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16));
  }
  return bytes;
}