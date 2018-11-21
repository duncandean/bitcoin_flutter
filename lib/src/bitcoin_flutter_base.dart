// TODO: Put public facing types in this file.
import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'package:bip32/bip32.dart' show BIP32;
import 'models/networks.dart';
import 'payments/p2pkh.dart';
import 'ecpair.dart';
import 'package:meta/meta.dart';

/// Checks if you are awesome. Spoiler: you are.
class HDWallet {
  BIP32 _bip32;
  P2PKH _p2pkh;
  String seed;
  NetworkType network;
  String get privKey => _bip32 != null ? HEX.encode(_bip32.privateKey) : null;
  String get pubKey => _bip32 != null ? HEX.encode(_bip32.publicKey) : null;
  String get base58Priv => _bip32 != null ? _bip32.toBase58() : null;
  String get base58 => _bip32 != null ? _bip32.neutered().toBase58() : null;
  String get wif => _bip32 != null ? _bip32.toWIF() : null;
  String get address => _p2pkh != null ? _p2pkh.data.address : null;

  HDWallet(
      {@required bip32, @required p2pkh, @required this.network, this.seed}) {
    this._bip32 = bip32;
    this._p2pkh = p2pkh;
  }
  HDWallet derivePath(String path) {
    final bip32 = _bip32.derivePath(path);
    final p2pkh = new P2PKH(
        data: new P2PKHData(pubkey: bip32.publicKey), network: network);
    return HDWallet(bip32: bip32, p2pkh: p2pkh, network: network);
  }

  HDWallet derive(int index) {
    final bip32 = _bip32.derive(index);
    final p2pkh = new P2PKH(
        data: new P2PKHData(pubkey: bip32.publicKey), network: network);
    return HDWallet(bip32: bip32, p2pkh: p2pkh, network: network);
  }

  factory HDWallet.fromSeed(Uint8List seed, {NetworkType network}) {
    network = network ?? bitcoin;
    final seedHex = HEX.encode(seed);
    final bip32 = BIP32.fromSeed(seed);
    final p2pkh = new P2PKH(
        data: new P2PKHData(pubkey: bip32.publicKey), network: network);
    return HDWallet(
        bip32: bip32, p2pkh: p2pkh, network: network, seed: seedHex);
  }
}

class Wallet {
  ECPair _keyPair;
  P2PKH _p2pkh;
  String get privKey =>
      _keyPair != null ? HEX.encode(_keyPair.privateKey) : null;
  String get pubKey => _keyPair != null ? HEX.encode(_keyPair.publicKey) : null;
  String get wif => _keyPair != null ? _keyPair.toWIF() : null;
  String get address => _p2pkh != null ? _p2pkh.data.address : null;

  Wallet(this._keyPair, this._p2pkh);

  factory Wallet.random([NetworkType network]) {
    final _keyPair = ECPair.makeRandom(network: network);
    final _p2pkh = new P2PKH(
        data: new P2PKHData(pubkey: _keyPair.publicKey), network: network);
    return Wallet(_keyPair, _p2pkh);
  }
  factory Wallet.fromWIF(String wif, [NetworkType network]) {
    final _keyPair = ECPair.fromWIF(wif, network: network);
    final _p2pkh = new P2PKH(
        data: new P2PKHData(pubkey: _keyPair.publicKey), network: network);
    return Wallet(_keyPair, _p2pkh);
  }
}
