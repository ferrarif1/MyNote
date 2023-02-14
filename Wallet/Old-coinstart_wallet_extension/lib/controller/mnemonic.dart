import 'package:bip39/bip39.dart' as bip39;
import 'package:cryptography/cryptography.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:hex/hex.dart';
import 'package:sha3/sha3.dart';
import 'package:convert/convert.dart';
import 'package:web3dart/credentials.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'dart:typed_data';

enum COIN_TYPE { EVM_BASED, SUI }

String generateMnemonic() {
  return bip39.generateMnemonic();
}

// Future<SimpleKeyPair> getKeypairFromMnemonics(String mnemonic) async {
//   final seed = bip39.mnemonicToSeed(mnemonic).sublist(0, 32);
//   final algorithm = Ed25519();
//   final keyPair = await algorithm.newKeyPairFromSeed(seed);
//   return keyPair;
// }

// getSuiAddress(SimpleKeyPair keyPair) async {
//   final publicKey = (await keyPair.extractPublicKey()).bytes;
//   final prefixPublicKey = [0, ...publicKey];
//   var k = SHA3(256, SHA3_PADDING, 256);
//   k.update(prefixPublicKey);
//   return HEX.encode(k.digest()).substring(0, 40);
// }

//Sui - private key from mnemonic
Future<SimpleKeyPair> getKeypairFromMnemonics(String mnemonic) async {
  final seed = bip39.mnemonicToSeed(mnemonic);
  final seedBytes = seed;
  KeyData data =
      await ED25519_HD_KEY.derivePath("m/44'/784'/0'/0'/0'", seedBytes);
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(data.key);
  return keyPair;
}

//Sui - address from keypair
getSuiAddress(SimpleKeyPair keyPair) async {
  final publicKey = (await keyPair.extractPublicKey()).bytes;
  final prefixPublicKey = [0, ...publicKey];
  var k = SHA3(256, SHA3_PADDING, 256);
  k.update(prefixPublicKey);
  return HEX.encode(k.digest()).substring(0, 40);
}

//ETH - private key from mnemonic
Future<String> getETHPrivateKey(String mnemonic) async {
 
  String seed = bip39.mnemonicToSeedHex(mnemonic);

  final bip32.BIP32 root = bip32.BIP32.fromSeed(Uint8List.fromList(HEX.decode(seed)));
  final bip32.BIP32 child = root.derivePath(
      "m/44'/60'/0'/0/0");
  List<int> pk = child.privateKey != null? child.privateKey!.toList() : [0,0,1];
  final privateKey = HEX.encode(pk);
  // print('private Key: $privateKey'); 

  return privateKey;
}

//ETH - address from privatekey
Future<EthereumAddress> getETHPublicAddress(String privateKey) async {
  final private = EthPrivateKey.fromHex(privateKey);
  final address = await private.extractAddress();
  //print('address: $address');
  return address;
}

//ETH - from String to EthPrivateKey
EthPrivateKey getCredentials(String privateKey) =>
      EthPrivateKey.fromHex(privateKey);

