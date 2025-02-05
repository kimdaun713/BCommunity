import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/page/group/detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import '../../models/group.dart';

class MyGroupPage extends StatefulWidget {
  const MyGroupPage({Key? key}) : super(key: key);

  @override
  State<MyGroupPage> createState() => _MyGroupPageState();
}

class _MyGroupPageState extends State<MyGroupPage> {
  //dummy list
  DocumentSnapshot? _documents;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDocuments();
  }

  List display_group = [];

  Future<void> _loadGroup() async {
    int length = _documents!['groups'].length;

    for (int i = 0; i < length; i++) {
      Map data = await MyFire.fetchGroup(_documents!['groups']);
      display_group.add(data as Map);
    }
  }

  Future<void> _loadDocuments() async {
    // Firebase 초기화
    await Firebase.initializeApp();
    // Firestore 문서 컬렉션 가져오기
    print("로드닥" + MyFire.box.read('wallet' ?? ''));
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Joins/')
        .doc(MyFire.box.read('wallet' ?? ''))
        .get();

    for (int i = 0; i < snapshot['groups'].length; i++) {
      Map data = await MyFire.fetchGroup(snapshot!['groups'][i]);
      display_group.add(data as Map);
    }
    // 문서 리스트에 저장
    setState(() {
      display_group = display_group;
    });
  }

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
          "Joined Groups",
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
              height: 10.0,
            ),
            Expanded(
              child: display_group.length == 0
                  ? Center(
                      child: Text(
                      ("No joined groups found."),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                  : ListView.builder(
                      itemCount: display_group.length,
                      itemBuilder: (context, index) {
                        Map document = display_group[index];
                        return GestureDetector(
                          onTap: () {
                            MyFire.box.write('currentGroup', document['name']);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => GroupDetail(view: 1)),
                            );
                          },
                          child: Column(
                            children: [
                              FutureBuilder(
                                  future:
                                      MyFire.getGroupImage2(document['name']),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData == false) {
                                      return const Padding(
                                        padding: EdgeInsets.all(30.0),
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
                                        contentPadding: EdgeInsets.all(15.0),
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
                                          onTap: () {},
                                          child: Icon(
                                            Icons.star_border_outlined,
                                            color: Colors.yellow,
                                            size: 35,
                                          ),
                                        ),
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
                              Divider(
                                color: Colors.black.withOpacity(.15),
                                thickness: 0.6,
                              ),
                            ],
                          ),
                        );
                      }),
            ),
          ],
        ),
      ),
    );
  }
}
