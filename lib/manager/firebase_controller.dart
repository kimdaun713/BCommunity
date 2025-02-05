import 'dart:async';

import 'dart:convert';
import 'dart:io';
import 'package:new_bc/manager/chain_controller.dart';
import 'package:new_bc/manager/verify_controller.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:convert/convert.dart';
import 'package:quiver/core.dart';
import 'dart:typed_data';

class MyFire {
  static final box = GetStorage();
  static String wallet = box.read('wallet' ?? '');
  static CollectionReference users =
      FirebaseFirestore.instance.collection('Users');
  static CollectionReference groups =
      FirebaseFirestore.instance.collection('Groups');
  static CollectionReference joins =
      FirebaseFirestore.instance.collection('Joins');
  static CollectionReference post =
      FirebaseFirestore.instance.collection('Post');
  static int hashedPostCount = 3;

  //유저 정보 불러오기
  static Future<Map<dynamic, dynamic>> getUser(String wallet) async {
    final userSnap = await users.doc(wallet).get();
    final userData = userSnap.data() as Map;
    print(userData);
    return userData;
  }

  /*포스트 해시값 불러오기기 v1
  static void hashWithPost(int id) async {
    if (id % hashedPostCount == 0) {
      QuerySnapshot querySnapshot = await post
          .orderBy("id", descending: true)
          .limit(hashedPostCount)
          .get();
      final data = querySnapshot.docs.map((doc) => doc.data()).toList();

      String postHash = getPostsHash(data);

      MyChain.addHashOnChain(id, postHash);
    } else {
      return;
    }
  }*/

  //포스트 해시 불러오기 (블룸필터 버전) v1.1
  static Future<String> hashWithPost(int id, bool isAdd) async {
    QuerySnapshot querySnapshot = await post
        .orderBy("id", descending: true)
        .where("groupID", isEqualTo: box.read('currentGroup' ?? ''))
        .where("id", isEqualTo: id)
        .limit(1)
        .get();

    var dataList = querySnapshot.docs.map((doc) => doc.data()).toList();
    var data = dataList[0] as Map;
    String postHash = getPostsHash(data);
    print("postHash!!$postHash");
    if (isAdd) {
      Verification.addFilterOnChain(id, postHash);
    }

    return postHash;
  }

  /*
  static Future<String> getPostHashFromDataBundle(int id) async {
    var postsData = await getPostBundle(id);
    return getPostsHash(postsData);
  }*/

  static Future<List> getPostBundle(int id) async {
    int bundleIndex = id ~/ hashedPostCount;
    if (id % hashedPostCount == 0) {
      bundleIndex = bundleIndex - 1;
    }

    int postId = bundleIndex * 3 + 1;
    List<int> postIdList = [];
    for (int i = 0; i < hashedPostCount; i++) {
      postIdList.add(postId);
      postId++;
    }

    QuerySnapshot querySnapshot =
        await post.where("id", whereIn: postIdList).get();
    final postData =
        querySnapshot.docs.map((doc) => doc.data()).toList() as List;
    postData.sort((a, b) => b['id'].compareTo(a['id']));
    return postData;
  }

  static String getPostsHash(Map<dynamic, dynamic> data) {
    String postHashes = '';

    final postData = data;

    var hashText = hashString(postData['text'].toString());
    var hashGroupID = hashString(postData['groupID'].toString());
    var hashTimestamp = hashString(postData['timestamp'].toString());
    var hashWriterID = hashString(postData['writerID'].toString());

    var combinedPostHash =
        hashString(hashText + hashGroupID + hashTimestamp + hashWriterID);

    postHashes = '0x$combinedPostHash';

    return postHashes;
  }

  static String hashString(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<int> getPostLastID() async {
    QuerySnapshot querySnapshot = await post
        .where('groupID', isEqualTo: MyFire.box.read('currentGroup' ?? ''))
        .orderBy("id", descending: true)
        .limit(1)
        .get();
    final data = querySnapshot.docs.map((doc) => doc.data()).toList();
    var id = data[0] as Map;

    return id['id'];
  }

  static Future<String> getPostImage(int id) async {
    String imageURL = "";
    String currentGroup = MyFire.box.read('currentGroup' ?? '');

    imageURL = await FirebaseStorage.instance
        .ref()
        .child("PostPics/$currentGroup/$id.jpg")
        .getDownloadURL();

    return imageURL;
  }

  static Future<bool> isNotPendingPost(int id) async {
    final lastid = await getPostLastID();
    var num = lastid % hashedPostCount;

    if (id <= lastid - num) {
      return true;
    } else {
      return false;
    }
  }

  static int getLastID(int id) {
    return id;
  }

  //유저 이미지 불러오기
  static Future<String> getUserImage(String wallet) async {
    String imageURL = await FirebaseStorage.instance
        .ref()
        .child("UserPics/$wallet.jpg")
        .getDownloadURL();

    box.write('userImg', imageURL);
    print(box.read('userImg'));
    return imageURL;
  }

  //유저 정보 세팅
  static void setUser(String nickName, String aboutUser) {
    users.doc(box.read('wallet' ?? '')).set({
      "nickname": nickName,
      "about": aboutUser,
    });
  }

  //유저 기본 사진 설정정
  static Future<String> newUserPhoto() async {
    final ByteData assetByteData =
        await rootBundle.load('assets/user_default.png');
    final Uint8List assetBytes = assetByteData.buffer.asUint8List();
    final fileName = MyFire.box.read('wallet' ?? '');
    final storageRef =
        FirebaseStorage.instance.ref().child('UserPics/$fileName' ".jpg");
    final UploadTask uploadTask = storageRef.putData(assetBytes);
    await uploadTask;
    final String downloadUrl = await storageRef.getDownloadURL();
    box.write('userImg', downloadUrl);
    return downloadUrl;
  }

  //유저 사진 저장
  static Future<String> setUserPic(String filePath) async {
    File imageFile = File(filePath);
    Reference storageReference =
        FirebaseStorage.instance.ref().child('UserPics/$wallet' '.jpg');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    box.write('userImg', imageUrl);
    return filePath;
  }

  //문서 전체 개수 가져오기
  static Future<int> getTotalDocumentCount(String collectionName) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();
    int totalDocumentCount = snapshot.docs.length;
    return totalDocumentCount;
  }

  //그룹 사진 저장
  static void setGroupPic(String filePath, String groupName) async {
    File imageFile = File(filePath);
    Reference storageReference =
        FirebaseStorage.instance.ref().child('GroupPics/$groupName');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
  }

  static addComment(int postID, String content, String writerID) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Post')
        .where('groupID', isEqualTo: MyFire.box.read('currentGroup' ?? ''))
        .where('id', isEqualTo: postID)
        .get();

    String postDocID = querySnapshot.docs[0].id;
    print(postDocID);
    FirebaseFirestore.instance
        .collection('Post')
        .doc(postDocID)
        .collection('Comments')
        .add({
      'timestamp': getCurrentTimestamp(),
      'writerID': writerID,
      'content': content,
    });
  }

  static Future<int> getCommentCount(int postID) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Post')
        .where('groupID', isEqualTo: MyFire.box.read('currentGroup' ?? ''))
        .where('id', isEqualTo: postID)
        .get();

    String postDocID = querySnapshot.docs[0].id;

    QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
        .collection('Post')
        .doc(postDocID)
        .collection('Comments')
        .get();

    return commentsSnapshot.docs.length;
  }

  static getComment(int postID) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Post')
        .where('groupID', isEqualTo: MyFire.box.read('currentGroup' ?? ''))
        .where('id', isEqualTo: postID)
        .get();

    String postDocID = querySnapshot.docs[0].id;

    QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
        .collection('Post')
        .doc(postDocID)
        .collection('Comments')
        .orderBy('timestamp', descending: false)
        .get();

    return commentsSnapshot.docs as List;
  }

  //그룹 개수 반환
  static Future<int> getGroupNum() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Groups').get();

    return querySnapshot.size;
  }

  //그룹 존재하는지 확인
  static Future<bool> existGroup(String group) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Groups')
        .where('name', isEqualTo: group)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  //해당 그룹 정보 가져오기
  static Future<Map> fetchGroup(String group) async {
    QuerySnapshot querySnapshot =
        await groups.where("name", isEqualTo: group).get();
    final data = querySnapshot.docs.map((doc) => doc.data()).toList();
    print(data[0]);
    return data[0] as Map;
  }

  static String getCurrentTimestamp() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }

  static Future<void> updateGroupMember() async {
    final querySnapshot = await groups
        .where('name', isEqualTo: box.read('currentGroup' ?? ''))
        .get();
    final docSnapshot = querySnapshot.docs.first;
    await docSnapshot.reference.update({'members': docSnapshot['members'] + 1});
  }

  //가입된 그룹 모두 가져오기
  static Future<List> getAllJoin() async {
    final DocumentReference documentReference =
        FirebaseFirestore.instance.collection('Joins').doc(wallet);

    final docSnapshot = await documentReference.get();

    final data = docSnapshot.data() as Map;

    return data['groups'] as List;
  }

  static void initJoin() async {
    List<String> list = [];
    joins.doc(wallet).set({'groups': list});
  }

  //그룹 사진 불러오기
  static Future<String> getGroupImage(String group) {
    Completer<String> completer = Completer<String>();
    Future.delayed(const Duration(seconds: 0), () async {
      String imageURL = await FirebaseStorage.instance
          .ref()
          .child("GroupPics/$group")
          .getDownloadURL();
      completer.complete(imageURL);
    });
    return completer.future;
  }

  //그룹 사진 불러오기
  static Future<String> getGroupImage2(String group) async {
    String imageURL = await FirebaseStorage.instance
        .ref()
        .child("GroupPics/$group")
        .getDownloadURL();

    return imageURL;
  }

  //가입됐는지 체크하기
  static Future<bool> checkUserJoin(String group) async {
    final List userGroups = await getAllJoin();
    print(userGroups);
    for (int i = 0; i < userGroups.length; i++) {
      print(group);
      if (group == userGroups[i].toString()) {
        return false;
      }
    }
    return true;
  }
}
