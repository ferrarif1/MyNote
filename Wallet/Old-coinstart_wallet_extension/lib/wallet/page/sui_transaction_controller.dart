import 'package:get/get.dart';

import '../../api/sui_api.dart';

class SuiTransactionController extends GetxController {
  List<SuiTansaction>? suiTansactionList = [];
  List<SuiTansaction> suiTansactionListSend = [];
  List<SuiTansaction> suiTansactionListReceive = [];

  SuiTansaction getTransactionSend(int index) {
    return suiTansactionListSend[index];
  }
  SuiTansaction getTransactionReceive(int index) {
    return suiTansactionListReceive[index];
  }
}