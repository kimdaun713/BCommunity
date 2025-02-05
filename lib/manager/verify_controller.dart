import 'dart:async';

import 'dart:convert';
import 'dart:io';
import 'package:new_bc/manager/chain_controller.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:convert/convert.dart';
import 'package:quiver/core.dart';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:quiver/strings.dart';

import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../models/contract_abi.dart';
import 'firebase_controller.dart';

class Verification {
  static const NUM_HASH_FUNCTIONS = 7;
  static const FILTER_SIZE = 256;

  static final postContractAddr = EthereumAddress.fromHex('..');
  static final client = Web3Client('http://..', Client());
  static final postContract = DeployedContract(
      ContractAbi.fromJson(ContractABI.verifyABI, 'PostFilter'),
      postContractAddr);
  static final credentials = EthPrivateKey.fromHex('..');

  static String createFilterData(String postHash) {
    BigInt filter = BigInt.zero;
    String filterData = '0x';

    for (int i = 0; i < NUM_HASH_FUNCTIONS; i++) {
      final hash = BigInt.parse(
          sha256.convert(utf8.encode(postHash + i.toString())).toString(),
          radix: 16);
      final hashIndex = hash % BigInt.from(FILTER_SIZE);
      filter |= BigInt.one << hashIndex.toInt();
    }

    filterData += filter.toRadixString(16).padLeft(64, '0');

    return filterData;
  }

  static bool isFilterDataContainsHash(String filterData, String postHash) {
    final filterValue = BigInt.parse(filterData.substring(2), radix: 16);

    for (int i = 0; i < NUM_HASH_FUNCTIONS; i++) {
      final hash = BigInt.parse(
          sha256.convert(utf8.encode(postHash + i.toString())).toString(),
          radix: 16);
      final hashIndex = hash % BigInt.from(FILTER_SIZE);
      final hashMask = BigInt.one << hashIndex.toInt();

      if ((filterValue & hashMask) == BigInt.zero) {
        return false;
      }
    }

    return true;
  }

  static Uint8List hexStringToBytes32(String hex) {
    if (hex.length < 66) {
      hex = hex.padLeft(66, '0');
    }
    hex = hex.replaceFirst('0x', '');
    return Uint8List.fromList(hexToBytes(hex));
  }

  static String bytes32ToHexString(Uint8List bytes32) {
    return '0x${hex.encode(bytes32)}';
  }

  static Future<void> addFilterOnChain(int id, String postHash) async {
    final function = postContract.function('addItem2');
    var postFilter = createFilterData(postHash);
    print("postFilter!!$postFilter");
    Uint8List bytes32PostFilter = hexStringToBytes32(postFilter);
    final result = await client.sendTransaction(
      chainId: 1337,
      credentials,
      Transaction.callContract(
        contract: postContract,
        function: function,
        parameters: [BigInt.from(id), bytes32PostFilter],
      ),
    );
    print('Post Transcation hash: $result');
  }

  static Future<void> getFilterOnChain(int id) async {
    final function = postContract.function('getfilter');

    var postFilter = "";
    Uint8List bytes32PostFilter = hexStringToBytes32(postFilter);
    final result = await client.call(
      contract: postContract,
      function: function,
      params: [BigInt.from(id)],
    );
    var filterString = bytes32ToHexString(result[0]);
  }

  static const POST_BUNDLE_SIZE = 3;
  static Future<bool> simpleVerified(int id) async {
    return true;
  }

  static Future<bool> isVerified(int id) async {
    final function = postContract.function('getfilter');

    if (!(await MyFire.isNotPendingPost(id))) {
      return true;
    }
    if (id % POST_BUNDLE_SIZE == 0) {
      final requestfilter = await client.call(
        contract: postContract,
        function: function,
        params: [BigInt.from(id)],
      );
      var filterString = bytes32ToHexString(requestfilter[0]);
      MyFire.box.write('currentFilter', filterString);
      var posthash = await MyFire.hashWithPost(id, false);
      var isVerify = isFilterDataContainsHash(filterString, posthash);
      return isVerify;
    } else {
      final filter = MyFire.box.read('currentFilter' ?? '');

      var posthash = await MyFire.hashWithPost(id, false);
      var isVerify = isFilterDataContainsHash(filter, posthash);
      return isVerify;
    }
  }
}
