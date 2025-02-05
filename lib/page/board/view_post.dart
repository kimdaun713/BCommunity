import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/page/user/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/group.dart';
import '../../models/recommend.dart';
import 'package:get_storage/get_storage.dart';

import '../components/view_image.dart';

class ViewPostScreen extends StatefulWidget {
  final Map postSnap;
  final String imageURL;
  const ViewPostScreen(
      {super.key, required this.postSnap, required this.imageURL});

  @override
  _ViewPostScreenState createState() => _ViewPostScreenState();
}

class _ViewPostScreenState extends State<ViewPostScreen> {
  Widget _buildComment(Map snap) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ListTile(
        leading: Container(
          width: 50.0,
          height: 50.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 2),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: FutureBuilder(
            future: MyFire.getUserImage(snap['writerID']),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }
              //개설자 닉네임
              else {
                return CircleAvatar(
                  child: ClipOval(
                    child: Image(
                      height: 50.0,
                      width: 50.0,
                      image: NetworkImage(snapshot.data), //사용자 프로필
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
            },
          ),
        ),
        title: FutureBuilder(
          future: MyFire.getUser(snap['writerID']),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData == false) {
              return Container();
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontSize: 15),
                ),
              );
            }
            //댓글 작성자 닉네임
            else {
              return Text(snapshot.data['nickname'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ));
            }
          },
        ),
        subtitle: Text(snap['content']),
        trailing: Text(
          snap['timestamp'],
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  final _textController = TextEditingController();

// ...
  @override
  Widget build(BuildContext context) {
    bool showFullText = false; // 상태 변수
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
          child: Row(
            children: <Widget>[
              const SizedBox(
                height: 60,
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Text(MyFire.box.read('currentGroup' ?? ''),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 23)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.98,
                    child: ListTile(
                      leading: Container(
                          width: 55.0,
                          height: 55.0,
                          decoration: const BoxDecoration(
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
                                    widget.postSnap['writerID']),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData == false) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Error: ${snapshot.error}',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    );
                                  }
                                  //개설자 닉네임
                                  else {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UserProfilePage(
                                                      userID: widget.postSnap[
                                                          'writerID'])),
                                        );
                                      },
                                      child: Image(
                                        height: 60.0,
                                        width: 60.0,
                                        //유저 이미지
                                        image: NetworkImage(snapshot.data),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          )),
                      title: FutureBuilder(
                        future: MyFire.getUser(widget.postSnap['writerID']),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData == false) {
                            return Center(child: CircularProgressIndicator());
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
                          else {
                            return Text(
                              snapshot.data['nickname'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
                      ),
                      //타임스탬프
                      subtitle: Text(widget.postSnap['timestamp']),
                      trailing: IconButton(
                        icon: Icon(Icons.more_horiz),
                        color: Colors.black,
                        onPressed: () => print("더보기 액션"),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    //좋아요
                    onDoubleTap: () => print('Like post'), //두번클릭시좋아요
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ImageScreen(imageUrl: widget.imageURL!),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      height: 230.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            offset: Offset(0, 5),
                            blurRadius: 8.0,
                          )
                        ],
                        //본문 이미지
                        image: DecorationImage(
                            image: NetworkImage(widget.imageURL!),
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    padding: EdgeInsets.symmetric(vertical: 9, horizontal: 15),
                    child: Text(
                      widget.postSnap['text'],
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                                Text(widget.postSnap['likes'].toString(),
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: const Icon(Icons.chat_outlined),
                                      iconSize: 25.0,
                                      onPressed: () => {},
                                    ),
                                    FutureBuilder(
                                      future: MyFire.getCommentCount(
                                          widget.postSnap['id']),
                                      builder: (BuildContext context,
                                          AsyncSnapshot snap) {
                                        if (snap.hasData == false) {
                                          return Container();
                                        } else if (snap.hasError) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Error: ${snap.error}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          );
                                        } else {
                                          return Text(snap.data.toString(),
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ));
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
                          icon: const Icon(Icons.bookmark_border),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                width: double.infinity,
                height: 600.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: FutureBuilder(
                  future: MyFire.getComment(MyFire.box.read('currentPost')),
                  builder: (BuildContext context, AsyncSnapshot snap) {
                    if (snap.hasData == false) {
                      return Container();
                    } else if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Error: ${snap.error}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      );
                    } else {
                      return Column(children: <Widget>[
                        for (int i = 0; i < snap.data.length; i++)
                          _buildComment(snap.data[i].data() as Map),
                        Container(
                          width: 350,
                          height: 0.3,
                          color: const Color.fromARGB(255, 206, 206, 206),
                        ),
                      ]);
                    }
                  },
                ),
              )
            ],
          )),
      bottomNavigationBar: Container(
          height: 100.0,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(10),
                    hintText: 'Enter your comment.',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                          left: 5.0, right: 11.0, bottom: 12.0),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(115, 241, 241, 241),
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        /* child: CircleAvatar(
                            child: ClipOval(
                              child: Image(
                                height: 50.0,
                                width: 50.0,
                                image: NetworkImage(
                                    MyFire.box.read('userImg' ?? '')), 
                                fit: BoxFit.cover,
                              ),
                            ),
                          )*/
                      ),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        var textFieldValue = _textController.text.trim();
                        if (textFieldValue.isNotEmpty) {
                          MyFire.addComment(MyFire.box.read('currentPost'),
                              textFieldValue, MyFire.wallet);
                          _textController.clear();
                          setState(() {});
                        } else {
                          showDialog(
                            context: context,
                            builder: (_) => const AlertDialog(
                              title: Text("Fale"),
                              content: Text("Please enter the content."),
                              actions: [],
                            ),
                          );
                        }
                      },
                      child: Container(
                          margin: EdgeInsets.only(right: 0.0),
                          width: 70.0,
                          child: Icon(Icons.create, size: 30)),
                    ))),
          )),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    var format = new DateFormat('y-MM-dd  HH:mm');
    return format.format(timestamp.toDate());
  }
}
