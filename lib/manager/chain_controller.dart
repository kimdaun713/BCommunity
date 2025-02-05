import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:new_bc/manager/firebase_controller.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import '../models/contract_abi.dart';

class MyChain {
  static final postContractAddr = EthereumAddress.fromHex('..');
  static final client = Web3Client('http://..:7545', Client());
  static final postContract = DeployedContract(
      ContractAbi.fromJson(ContractABI.postABI, 'Post'), postContractAddr);
  static final Credentials = EthPrivateKey.fromHex('..');

  static Future<List<dynamic>> postContractCall(
      String functionName, List<dynamic> args) async {
    final ethFunction = postContract.function(functionName);
    final result = await client.call(
      contract: postContract,
      function: ethFunction,
      params: args,
    );
    return result;
  }

  static Future<void> addHashOnChain(int id, String postHash) async {
    final function = postContract.function('addPostsHash');
    final result = await client.sendTransaction(
      Credentials,
      Transaction.callContract(
        contract: postContract,
        function: function,
        parameters: [BigInt.from(id), postHash],
      ),
    );
    print('Post Transcation hash: $result');
  }

  /*addHashOnChain v1
  static Future<void> addHashOnChain(int id, String postHash) async {
    final function = postContract.function('addPostsHash');
    final result = await client.sendTransaction(
      Credentials,
      Transaction.callContract(
        contract: postContract,
        function: function,
        parameters: [BigInt.from(id), postHash],
      ),
    );
    print('Post Transcation hash: ${result}');
  }*/

  static Future<String> getPostsHashOnChain(int id) async {
    var hashMapID = id % MyFire.hashedPostCount;
    if (hashMapID == 0) {
      final result = await postContractCall('getPostHash', [BigInt.from(id)]);
      return result[0] as String;
    }
    final result = await postContractCall(
        'getPostHash', [BigInt.from((id ~/ MyFire.hashedPostCount + 1) * 3)]);
    return result[0] as String;
  }

  static Future<bool> isVerified(int id) async {
    if (await MyFire.isNotPendingPost(id)) {
      /*var postHashOnChain = await getPostsHashOnChain(id);
      var postHashOnExternalStorage =
          await MyFire.getPostHashFromDataBundle(id);
      if (postHashOnChain == postHashOnExternalStorage) {
        return true;
      }
      //지워
      return true;
      //return false;*/
    }
    return true;
  }
}
