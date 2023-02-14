import 'package:coinstart_wallet_extension/api/eth_api.dart';

var apiUrls = [
  ApiUrls("devurl", "https://fullnode.devnet.sui.io/", "SUI"),
  ApiUrls("stagingurl", "https://fullnode.staging.sui.io/", "SUI"),
  ApiUrls("testneturl", "https://fullnode.testnet.sui.io/", "SUI"),
];

class ApiUrls {
  String name;
  String url;
  String icon;

  ApiUrls(this.name, this.url, this.icon);
}
