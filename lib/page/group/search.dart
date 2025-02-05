import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/page/group/detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var _querySnapshot = null;
  var _searchSnapshot = null;
  var lastDocument;
  var lastSearch;
  var isSearch = false;
  //dummy list
  List<DocumentSnapshot> _documents = [];
  List<DocumentSnapshot> display_list = [];
  //불러오는 그룹의 수
  var groupSize = 4;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    var data;
    // Firestore 문서 컬렉션 가져오기
    if (_querySnapshot == null) {
      _querySnapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .limit(groupSize)
          .get();

      setState(() {
        lastDocument = _querySnapshot.docs.last;
        _documents = _querySnapshot.docs.toList();
        display_list = _documents;
      });
    } else {
      QuerySnapshot _nextQuerySnapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .startAfterDocument(lastDocument) // 마지막 문서를 기준으로 다음 문서 가져오기
          .limit(groupSize)
          .get();
      data = _nextQuerySnapshot.docs.toList();
      if (_nextQuerySnapshot.docs.isNotEmpty) {
        lastDocument = _nextQuerySnapshot.docs.last;
      }
      print("data length: " + data.length.toString());

      for (int i = 0; i < data.length; i++) {
        var dataMap = data[i].data() as Map<String, dynamic>;
        // print("data is " + dataMap.toString());
        if (i < data.length && dataMap.containsKey('name')) {
          _documents.add(data[i]);
        }
      }
    }

    // 문서 리스트에 저장
  }

  Future<void> _loadSearch(String value) async {
    var data;
    // Firestore 문서 컬렉션 가져오기
    isSearch = true;
    /*if (_searchSnapshot == null) {*/
    _searchSnapshot = await FirebaseFirestore.instance
        .collection('Groups')
        .where('name', isGreaterThanOrEqualTo: value)
        .where('name', isLessThan: value + 'z')
        .get();

    if (_searchSnapshot.docs.isNotEmpty) {
      lastSearch = _searchSnapshot.docs.last;
    }

    _documents = _searchSnapshot.docs.toList();
    display_list = _documents;
    print("----------------");
    print(display_list.length);
    /*} else {
      QuerySnapshot _nextQuerySnapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .where('name', isGreaterThanOrEqualTo: value)
          .where('name', isLessThan: value + 'z')
          .get();
      data = _nextQuerySnapshot.docs.toList();
      if (_nextQuerySnapshot.docs.isNotEmpty) {
        lastSearch = _nextQuerySnapshot.docs.last;
      }
      for (int i = 0; i < groupSize; i++) {
        if (i < data.length) {
          _documents.add(data[i]);
        }
      }
    }*/
    setState(() {
      display_list = _documents;
      print(display_list.length);
    });
    // 문서 리스트에 저장
  }

  Future updateList(String value) async {
    setState(() {
      if (value == '') {
        isSearch = false;
        _querySnapshot = null;
        _loadDocuments();
      } else {
        _loadSearch(value);
      }
    });
  }

  void handleTextFieldSubmit(String value) async {
    await updateList(value);
  }

  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.grey.shade600,
          ),
        ),
        title: Text(
          "Board search",
          style: TextStyle(
              color: Colors.blue, fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
      ),
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
                //onChanged: (value) => updateList(value),
                onSubmitted: handleTextFieldSubmit,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Search for boards.",
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
                      itemCount: isSearch
                          ? display_list.length
                          : display_list.length + 1,
                      itemBuilder: (context, index) {
                        if (index == display_list.length && isSearch != true) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 150),
                            child: ElevatedButton(
                              onPressed: () async {
                                // 새로운 페이지의 데이터를 가져와서 posts 리스트에 추가
                                await _loadDocuments();
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 77, 174, 253),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10), // 버튼 크기 조정
                                foregroundColor: Color.fromARGB(
                                    255, 116, 112, 112), // 배경 색상 설정
                              ),
                              child: Text(
                                'More',
                                style: TextStyle(
                                  color: Colors.white, // 텍스트 색상 설정
                                ),
                              ),
                            ),
                          );
                        } else {
                          DocumentSnapshot document = display_list[index];
                          return Column(
                            children: [
                              FutureBuilder(
                                  future:
                                      MyFire.getGroupImage2(document['name']),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData == false) {
                                      return Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Center(
                                            child: CircularProgressIndicator(
                                                color: Color.fromARGB(
                                                    255, 151, 222, 255))),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Error: ${snapshot.error}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      );
                                    } else {
                                      return ListTile(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(30, 15, 30, 15),
                                        title: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 15.0),
                                          child: Text(
                                            document['name'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Members ${document['members'].toString()}',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 71, 71, 71)),
                                        ),
                                        trailing: GestureDetector(
                                            onTap: () {
                                              MyFire.box.write('currentGroup',
                                                  document['name']);

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      GroupDetail(view: 1),
                                                ),
                                              );
                                            },
                                            child: Text("Show",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 17, 117, 199)))),
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: Image.network(
                                            snapshot.data,
                                            fit: BoxFit.cover,
                                            width: 43,
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                              Container(
                                padding: EdgeInsets.zero,
                                child: Divider(
                                  color: Colors.black.withOpacity(0.15),
                                  thickness: 0.6,
                                ),
                              ),
                            ],
                          );
                        }
                      }),
            ),
          ],
        ),
      ),
    );
  }
}
