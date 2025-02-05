import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/page/board/feed.dart';
import 'package:new_bc/page/board/view_post.dart';
import 'package:new_bc/page/group/detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:walletconnect_flutter_v2/apis/core/relay_auth/relay_auth_models.dart';

import '../../models/group.dart';

class SearchPostPage extends StatefulWidget {
  const SearchPostPage({Key? key}) : super(key: key);

  @override
  State<SearchPostPage> createState() => _SearchPostPageState();
}

class _SearchPostPageState extends State<SearchPostPage> {
  var _querySnapshot = null;
  var _searchSnapshot = null;
  var lastDocument;
  var lastSearch;
  var isSearch = false;
  CollectionReference post = FirebaseFirestore.instance.collection('Post');
  List<DocumentSnapshot> _documents = [];
  List<DocumentSnapshot> display_list = [];
  //불러오는 그룹의 수
  var groupSize = 3;
  @override
  void initState() {
    super.initState();
  }

  var _value = "";
  Future<void> _loadSearchPost(String value) async {
    isSearch = true;
    if (value == "") {
      setState(() {
        display_list = [];
      });
    } else {
      _value = value;
      _querySnapshot = await post
          .where("groupID", isEqualTo: MyFire.box.read('currentGroup' ?? ''))
          .orderBy('text')
          .startAt([value]).endAt([value + '\uf8ff']).get();

      setState(() {
        display_list = _querySnapshot.docs.toList();
        display_list.sort((a, b) => b['id'].compareTo(a['id']));
      });
    }
  }

  void handleTextFieldSubmit(String value) async {
    await _loadSearchPost(value);
  }

  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 246, 252),
      body: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _textEditingController,
                onChanged: (value) => (value),
                onSubmitted: handleTextFieldSubmit,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Search for Post.",
                  prefixIcon: Icon(Icons.search),
                  prefixIconColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: display_list.length == 0
                  ? Center(
                      child: Text(
                      ("No search results found."),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                  : ListView.builder(
                      itemCount: display_list.length,
                      itemBuilder: (context, index) {
                        /* if (index == display_list.length) {
                          return ElevatedButton(
                            onPressed: () async {
                              // 새로운 페이지의 데이터를 가져와서 posts 리스트에 추가

                              setState(() {});
                            },
                            child: null,
                          );
                        } else {*/
                        DocumentSnapshot document = display_list[index];
                        return Column(
                          children: [
                            FutureBuilder(
                              future: MyFire.getPostImage(document['id']),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: const EdgeInsets.all(50.0),
                                    child: Center(
                                        child: SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: CircularProgressIndicator(
                                                color: Color.fromARGB(
                                                    255, 76, 197, 228)))),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return InkWell(
                                    onTap: () {
                                      Map<String, dynamic> data = document
                                          .data() as Map<String, dynamic>;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ViewPostScreen(
                                              postSnap: data,
                                              imageURL: snapshot.data!),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Image.network(
                                              snapshot.data,
                                              fit: BoxFit.cover,
                                              width: 120,
                                              height: 120, // 이미지 영역 높이 조절
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10), // 이미지와 텍스트 사이 여백
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  document['text'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: _value ==
                                                            document['text']
                                                        ? Colors.red
                                                        : Colors.black,
                                                  ),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                            Divider(
                              color: Colors.black.withOpacity(0.15),
                              thickness: 0.6,
                            ),
                          ],
                        );
                        //}
                      }),
            ),
          ],
        ),
      ),
    );
  }
}
