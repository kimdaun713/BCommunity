import 'package:new_bc/manager/chain_controller.dart';
import 'package:new_bc/manager/chain_controller2.dart';
import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/manager/verify_controller.dart';
import 'package:new_bc/models/recommend.dart';
import 'package:new_bc/page/board/search.dart';
import 'package:new_bc/page/components/body.dart';
import 'package:new_bc/page/home.dart';
import 'package:new_bc/page/user/my_profile.dart';
import 'package:new_bc/page/board/upload.dart';
import 'package:new_bc/page/user/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/user.dart';
import 'view_post.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _postLength = 0;
  //페이징 크기
  int postSize = 2;
  var _querySnapshot = null;
  var lastDocument;
  //초기 불러오는 post의 길이
  int postlength = 0;
  int currentPage = 1;
  var posts = [];
  var isEnd = false;

  CollectionReference post = FirebaseFirestore.instance.collection('Post');
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool isInitialLoading = true; // 초기 데
  Future<QuerySnapshot<Map<String, dynamic>>>? _future;
  QuerySnapshot<Map<String, dynamic>>? _snapshot;

  var post1;
  //포스트 로드 함수
  Future<List> getPostData(int index) async {
    DateTime startTime = DateTime.now();
    //시작 시간
    print('Post Read Test Function Start Time: $startTime');
    var data;
    if (_querySnapshot == null) {
      _querySnapshot = await post
          .where("groupID", isEqualTo: MyFire.box.read('currentGroup' ?? ''))
          .orderBy("id", descending: true)
          .limit(postSize)
          .get();

      data = _querySnapshot.docs.map((doc) => doc.data()).toList();
      if (data.length != 0) {
        lastDocument = _querySnapshot.docs.last;
      }
    } else {
      QuerySnapshot _nextQuerySnapshot = await post
          .where("groupID", isEqualTo: MyFire.box.read('currentGroup' ?? ''))
          .orderBy("id", descending: true)
          .startAfterDocument(lastDocument) // 다음 페이지
          .limit(postSize)
          .get();
      data = _nextQuerySnapshot.docs.map((doc) => doc.data()).toList();
      if (_nextQuerySnapshot.docs.isNotEmpty) {
        lastDocument = _nextQuerySnapshot.docs.last;
      }
    }

    for (int i = 0; i < postSize; i++) {
      if (i < data.length)
        posts.add(data[i] as Map);
      else {
        isEnd = true;
      }
    }
    DateTime endTime = DateTime.now();
    //종료 시간
    print('Post Read Test Function End Time: $endTime');
    Duration elapsed = endTime.difference(startTime);

    int hours = elapsed.inHours;
    int minutes = elapsed.inMinutes % 60;
    int seconds = elapsed.inSeconds % 60;
    int milliseconds = elapsed.inMilliseconds % 1000;

    print(
        'Post Read Test Function Elapsed Time: $hours hours, $minutes minutes, $seconds seconds, $milliseconds milliseconds');

    return posts;
  }

  Future<String> getPostImage(int id) async {
    String imageURL = "";
    String currentGroup = MyFire.box.read('currentGroup' ?? '');

    imageURL = await FirebaseStorage.instance
        .ref()
        .child("PostPics/$currentGroup/" + id.toString() + ".jpg")
        .getDownloadURL();

    return imageURL;
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 10) {
        _loadMoreData();
      }
    });

    FirebaseFirestore.instance
        .collection('Post')
        .where('groupID', isEqualTo: MyFire.box.read('currentGroup' ?? ''))
        .get()
        .then((value) {
      setState(() {
        _postLength = value.docs.length;
      });
    });
    //Verification.getFilterOnChain(1);
    //Verification.isVerified(1);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (isInitialLoading) {
      setState(() {
        isLoading = true;
      });
      // 초기 데이터 로딩 로직 추가
      await getPostData(1); // 최초 데이터 로딩 함수 호출

      setState(() {
        isLoading = false;
        isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      await getPostData(posts.length);

      setState(() {
        isLoading = false;
      });
    }
  }

  String _textSplit(String text) {
    List<String> lines = text.split('\n');
    if (lines[0] == null) {
      return "";
    }
    return lines[0];
  }

  Widget _buildPost(int index) {
    //snap의 0은 post, 1은 user정보
    return FutureBuilder(
      //여기 수정
      future: MyChain2.isVerified(posts[index]),
      //future: Verification.simpleVerified(posts[index]['id']),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData == false) {
          return Padding(
            padding: const EdgeInsets.all(100.0),
            //무한 스크롤
            child: Center(
                child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 151, 222, 255))),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(fontSize: 15),
            ),
          );
        }
        //개설자 닉네임
        else if (snapshot.data == true) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: Container(
              width: double.infinity,
              height: 430.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(children: <Widget>[
                      ListTile(
                        leading: Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              child: ClipOval(
                                child: FutureBuilder(
                                  future: MyFire.getUserImage(
                                      posts[index]['writerID']),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData == false) {
                                      return Center(
                                          child: CircularProgressIndicator(
                                              color: Color.fromARGB(
                                                  255, 151, 222, 255)));
                                    } else if (snapshot.hasError) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Error: ${snapshot.error}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      );
                                    } else {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserProfilePage(
                                                        userID: posts[index]
                                                            ['writerID'])),
                                          );
                                        },
                                        child: Image(
                                          height: 50.0,
                                          width: 50.0,
                                          //유저 이미지
                                          image: NetworkImage(
                                              snapshot.data), //사람 프로필
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            )),
                        //유저 이름
                        title: FutureBuilder(
                          future: MyFire.getUser(posts[index]['writerID']),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData == false) {
                              return Center(
                                  child: CircularProgressIndicator(
                                      color:
                                          Color.fromARGB(255, 151, 222, 255)));
                            } else if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(fontSize: 15),
                                ),
                              );
                            } else {
                              return Text(
                                snapshot.data['nickname'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                          },
                        ),
                        //시각
                        subtitle: Text(posts[index]['timestamp']),
                        trailing: IconButton(
                          icon: Icon(Icons.more_horiz),
                          color: Colors.black,
                          onPressed: () => print("더보기 액션"),
                        ),
                      ),
                      //이미지 불러오기

                      FutureBuilder<String>(
                        future: getPostImage(posts[index]['id']),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return InkWell(
                              onDoubleTap: () => print('Like post'), //두번클릭시좋아요
                              onTap: () {
                                MyFire.box
                                    .write('currentPost', posts[index]['id']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewPostScreen(
                                        postSnap: posts[index],
                                        imageURL: snapshot.data!),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                width: double.infinity,
                                height: 230.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black45,
                                      offset: Offset(0, 5),
                                      blurRadius: 8.0,
                                    )
                                  ],
                                  //본문 이미지
                                  image: DecorationImage(
                                      image: NetworkImage(snapshot.data!),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            );
                          } else {
                            return Center(
                                child: CircularProgressIndicator(
                                    color: Color.fromARGB(255, 151, 222, 255)));
                          }
                        },
                      ),

                      ListTile(
                        //본문
                        leading:
                            Text(_textSplit(posts[index]["text"].toString())),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.favorite_border),
                                      iconSize: 25.0,
                                      onPressed: () => print("추천"),
                                    ),
                                    Text(
                                      posts[index]["likes"].toString(),
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.chat_outlined),
                                          iconSize: 25.0,
                                          onPressed: () => {},
                                        ),
                                        FutureBuilder(
                                          future: MyFire.getCommentCount(
                                              posts[index]['id']),
                                          builder: (BuildContext context,
                                              AsyncSnapshot snaps) {
                                            if (snaps.hasData == false) {
                                              return Container();
                                            } else if (snaps.hasError) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Error: ${snaps.error}',
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                              );
                                            } else {
                                              return Text(
                                                snaps.data.toString(),
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => print("구독"),
                              iconSize: 25.0,
                              icon: Icon(Icons.bookmark_border),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            ),
          );
        } else if (snapshot.data == false) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Container(
              width: double.infinity,
              height: 430.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.red,
              ),
              child: Column(
                children: <Widget>[],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  //네브 인덱스
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 246, 252),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Text(
                MyFire.box.read('currentGroup' ?? ''),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              ),
              Spacer(),
              IconButton(
                onPressed: () async {
                  setState(() {});
                  await _loadInitialData();
                },
                icon: Icon(
                  Icons.refresh, // 새로고침 아이콘
                  size: 30,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: isEnd ? posts.length : posts.length + 1,
            itemBuilder: (context, index) {
              if (index == posts.length) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 151, 222, 255))); // 로딩 중 표시
              } else {
                return _buildPost(index);
              }
            },
          ),
          //검색
          const SearchPostPage(),
          //알림

          const SearchPostPage(),
          //MY
          ProfilePage(isEdit: false, isMain: false),
          ProfilePage(isEdit: false, isMain: false),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        //네브바
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 30.0, color: Colors.grey),
              label: "Feed",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 30.0, color: Colors.grey),
              label: "Search",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                child: TextButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 33, 229, 243)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                              side: const BorderSide(color: Colors.white)))),
                  onPressed: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Upload()),
                    ),
                  },
                  child: const Icon(Icons.create_outlined,
                      size: 30.0, color: Colors.white),
                ),
              ),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.notification_add_outlined,
                  size: 30.0, color: Colors.grey),
              label: "Alert",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 30.0, color: Colors.grey),
              label: "MY",
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });

            if (index == 1) {
              setState(() {});
            }
            if (index == 2) {}
          },
        ),
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    var format = new DateFormat('y-MM-dd  HH:mm'); // <- use skeleton here
    return format.format(timestamp.toDate());
  }
}
