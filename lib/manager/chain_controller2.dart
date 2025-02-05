import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:new_bc/manager/firebase_controller.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import '../models/contract_abi.dart';

class MyChain2 {
  static final postContractAddr = EthereumAddress.fromHex('..');
  static final client = Web3Client('http://..:7545', Client());
  static final postContract = DeployedContract(
      ContractAbi.fromJson(ContractABI.postABI2, 'Post'), postContractAddr);
  static final credentials = EthPrivateKey.fromHex('..');

  static Future<String> generateFileHash(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String generateHash(String input) {
    final digest = sha256.convert(utf8.encode(input));
    return digest.toString();
  }

  static String combineHashes(List<String> hashes) {
    final combined = hashes.join('');
    final digest = sha256.convert(utf8.encode(combined));
    return digest.toString();
  }

  static Future<void> addPostHash(String hash) async {
    //print("addPostHash is " + hash);

    final addPostHashFunction = postContract.function('addPostsHash');
    await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: postContract,
        function: addPostHashFunction,
        parameters: [hash],
      ),
      chainId: 1337,
    );
  }

  //블록체인 트랜잭션 호출 함수
  static Future<bool> verifyHash(String hash) async {
    final getPostHashFunction = postContract.function('getPostHash');
    final response = await client.call(
      contract: postContract,
      function: getPostHashFunction,
      params: [hash],
    );

    //print("post verification result is ${response[0]}");
    return response[0] as bool;
  }

  //검증 함수
  static Future<bool> isVerified(Map<String, dynamic> post) async {
    //시작 시간
    DateTime startTime = DateTime.now();
    File? file = await getPostImage(post['id']);
    var imghash = generateFileHash(file!);
    var id = generateHash(post['id'].toString());
    var text = generateHash(post['text']);
    var writer = generateHash(post['writerID']);
    var time = generateHash(post['timestamp']);

    // 종료 시간
    var hash = combineHashes([await imghash, id, text, writer, time]);
    if (await verifyHash(hash)) {
      //블록체인 트랜잭션 호출 함수 실행
      DateTime endTime = DateTime.now();
      Duration elapsed = endTime.difference(startTime);
      print('Post Verification Test Function Start Time: $startTime');
      print('Post Verification Test Function End Time: $endTime');
      print('Post Verification Test Function Elapsed Time: $elapsed');
      return true;
    }
    return false;
  }

/*
  static Future<bool> isVerified(Map<String, dynamic> post) async {
    //시작 시간
    DateTime startTime = DateTime.now();
    print('Post Verification Test Function Start Time: $startTime');
    File? file = await getPostImage(post['id']);
    var imghash = generateFileHash(file!);
    var id = generateHash(post['id'].toString());
    var text = generateHash(post['text']);
    var writer = generateHash(post['writerID']);
    var time = generateHash(post['timestamp']);

    DateTime postTime = DateTime.parse(post['timestamp']);
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(postTime);
    DateTime endTime;

    // 종료 시간
    var hash = combineHashes([await imghash, id, text, writer, time]);
    if (await verifyHash(hash) || difference.inSeconds < 10) {
      endTime = DateTime.now();
      Duration elapsed = endTime.difference(startTime);
      print('Post Verification Test Function End Time: $endTime');
      print('Post Verification Test Function Elapsed Time: $elapsed');
      return true;
    }

    return false;
  }*/
  static Future<File?> getPostImage(int id) async {
    String currentGroup = MyFire.box.read('currentGroup' ?? '');

    try {
      // Get a reference to the image
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child("PostPics/$currentGroup/" + id.toString() + ".jpg");

      // Download the image as a Uint8List
      final Uint8List? imageData = await ref.getData();

      if (imageData == null) {
        return null;
      }

      // Get the temporary directory of the app
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/post_$id.jpg';

      // Create a File instance
      final File file = File(path);

      // Write the image data to the file
      await file.writeAsBytes(imageData);

      return file;
    } catch (e) {
      print('Error downloading or saving image: $e');
      return null;
    }
  }
}
