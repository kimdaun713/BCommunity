import 'dart:io';

import 'package:new_bc/manager/chain_controller2.dart';
import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/page/board/feed.dart';
import 'package:new_bc/page/board/upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadDescription extends StatefulWidget {
  final File selectedImg;

  const UploadDescription({Key? key, required this.selectedImg})
      : super(key: key);

  @override
  State<UploadDescription> createState() => _UploadDescriptionState();
}

class _UploadDescriptionState extends State<UploadDescription> {
  var text = '';
  Widget _description() {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: SizedBox(
                width: 85,
                height: 85,
                child: Image.file(widget.selectedImg, fit: BoxFit.cover)),
          ),
          Expanded(
            child: TextField(
              maxLines: null,
              decoration: InputDecoration(
                  hintText: "input contents..\n\n",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10)),
              onChanged: (val) => text = val,
            ),
          ),
        ],
      ),
    );
  }

  AssetEntity? selectedImage;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black.withOpacity(0.5),
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        actions: [
          GestureDetector(
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.all(5),
                child: IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.blue.withOpacity(0.7),
                    size: 35,
                  ),
                  onPressed: () async {
                    // 실행 중 로딩 스피너 표시
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: SpinKitFadingCircle(
                              itemBuilder: (BuildContext context, int index) {
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: index.isEven
                                        ? Color.fromARGB(255, 85, 165, 255)
                                        : Colors.green,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );

                    // Firestore에서 데이터 가져오기
                    CollectionReference post =
                        FirebaseFirestore.instance.collection('Post');
                    var currentGroup = MyFire.box.read('currentGroup' ?? '');
                    QuerySnapshot querySnapshot = await post
                        .where('groupID', isEqualTo: currentGroup)
                        .orderBy("id", descending: true)
                        .limit(1)
                        .get();

                    final data =
                        querySnapshot.docs.map((doc) => doc.data()).toList();
                    var id;
                    var postId;
                    if (data.length != 0) {
                      id = data[0] as Map;
                      postId = id['id'] + 1;
                    } else {
                      postId = 1;
                    }

                    File? file = await widget.selectedImg;
                    //시작 시간
                    print('Add Test Function Start Time: ${DateTime.now()}');

                    DateTime startTime = DateTime.now();

                    final wallet = MyFire.box.read('wallet' ?? '');
                    final fileHash = await MyChain2.generateFileHash(file!);
                    final postIdHash = MyChain2.generateHash(postId.toString());
                    final textHash = MyChain2.generateHash(text);
                    final writerIdHash = MyChain2.generateHash(wallet);
                    final time = MyFire.getCurrentTimestamp().toString();
                    final timestampHash = MyChain2.generateHash(time);
                    final combinedHash = MyChain2.combineHashes([
                      fileHash,
                      postIdHash,
                      textHash,
                      writerIdHash,
                      timestampHash
                    ]);
                    //이미지 및 txt 데이터 오프체인에 저장
                    final ref = FirebaseStorage.instance.ref().child(
                        'PostPics/$currentGroup/' + postId.toString() + ".jpg");
                    await ref.putFile(file!);

                    await post.add({
                      "id": postId,
                      "groupID": MyFire.box.read('currentGroup' ?? ''),
                      "text": text,
                      "writerID": wallet,
                      "timestamp": time,
                      "activate": 0,
                      "views": 0,
                      "likes": 0,
                    });
                    //체인에 추가
                    MyChain2.addPostHash(combinedHash);
                    //종료 시간
                    DateTime endTime = DateTime.now();
                    print('Add Test Function End Time: $endTime');
                    // 경과 시간 계산
                    Duration elapsed = endTime.difference(startTime);

                    int hours = elapsed.inHours;
                    int minutes = elapsed.inMinutes % 60;
                    int seconds = elapsed.inSeconds % 60;
                    int milliseconds = elapsed.inMilliseconds % 1000;

                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FeedScreen()),
                    );

                    // 경과 시간 출력
                    print(
                        'Add Test Function Elapsed Time: $hours hours, $minutes minutes, $seconds seconds, $milliseconds milliseconds');
                  },
                ),
              ))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _description(),
            ],
          ),
        ),
      ),
    );
  }
}
