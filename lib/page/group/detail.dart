import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/page/board/feed.dart';
import 'package:new_bc/page/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupDetail extends StatelessWidget {
  final int view;
  const GroupDetail({Key? key, required this.view}) : super(key: key);

  Widget build(BuildContext context) {
    var isActive = true;

    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: MyFire.getGroupImage(MyFire.box.read('currentGroup')),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 151, 222, 255)));
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                } else {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(snapshot.data),
                          fit: BoxFit.cover),
                    ),
                  );
                }
              }),
          Positioned(
            left: 30,
            top: 30 + MediaQuery.of(context).padding.top,
            child: InkWell(
              onTap: () {
                if (view == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(
                        walletaddress: MyFire.box.read('wallet' ?? ''),
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              child: ClipOval(
                child: Container(
                  height: 42,
                  width: 41,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.25),
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.arrow_back_ios,
                        color: Colors.black.withOpacity(.5)),
                  ),
                ),
              ),
            ),
          ),
          FutureBuilder(
              future: MyFire.fetchGroup(MyFire.box.read('currentGroup' ?? '')),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                } else {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .58,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.2),
                            offset: Offset(0, -4),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 30,
                              left: 30,
                              right: 20,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    snapshot.data['name'],
                                    style: GoogleFonts.ptSans(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 30, right: 30),
                            child: Row(
                              children: [
                                Text("Creator ",
                                    style: GoogleFonts.ptSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )),
                                FutureBuilder(
                                  future:
                                      MyFire.getUser(snapshot.data['founder']),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snap) {
                                    if (snap.hasData == false) {
                                      return Center();
                                    } else if (snap.hasError) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Error: ${snapshot.error}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        snap.data['nickname'],
                                        style: GoogleFonts.ptSans(fontSize: 18),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 30,
                              right: 30,
                            ),
                            child: Row(
                              children: [
                                Text("Members ",
                                    style: GoogleFonts.ptSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text(
                                  snapshot.data['members'].toString(),
                                  style: GoogleFonts.ptSans(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 35,
                              right: 35,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data['intro'],
                                  style: GoogleFonts.ptSans(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Spacer(),
                          FutureBuilder<bool>(
                            future: MyFire.checkUserJoin(
                                MyFire.box.read('currentGroup' ?? '')),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData == false) {
                                return Center();
                              } else if (snapshot.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Error: ${snapshot.error}',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                );
                              }
                              //활성화 버튼 사진
                              else {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 33),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(.00),
                                          offset: Offset(0, -3),
                                          blurRadius: 12,
                                        )
                                      ]),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14, horizontal: 50),
                                            decoration: snapshot.data
                                                ? BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  )
                                                : BoxDecoration(
                                                    color: Color.fromARGB(
                                                        255, 243, 83, 83),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                            child: snapshot.data
                                                ? GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            AlertDialog(
                                                          title: Text("Join"),
                                                          content: Text(
                                                              "Would you like to join?"),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => {
                                                                MyFire.joins
                                                                    .doc(MyFire
                                                                        .wallet)
                                                                    .update({
                                                                  'groups':
                                                                      FieldValue
                                                                          .arrayUnion([
                                                                    MyFire.box.read(
                                                                        'currentGroup' ??
                                                                            '')
                                                                  ]),
                                                                }),
                                                                MyFire
                                                                    .updateGroupMember(),
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (_) =>
                                                                      AlertDialog(
                                                                    title: Text(
                                                                        "Joined"),
                                                                    content: Text(
                                                                        "Enter and try writing a post!"),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () =>
                                                                                {
                                                                          Navigator.of(context)
                                                                              .push(
                                                                            MaterialPageRoute(builder: (context) => FeedScreen()),
                                                                          ),
                                                                        },
                                                                        child: Text(
                                                                            "Enter"),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              },
                                                              child:
                                                                  Text("Done"),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: Text('Join',
                                                        style:
                                                            GoogleFonts.ptSans(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255))))
                                                : GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                FeedScreen()),
                                                      );
                                                    },
                                                    child: Text('Enter',
                                                        style:
                                                            GoogleFonts.ptSans(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255))),
                                                  ),
                                          ),
                                        ),
                                      ]),
                                );
                              }
                            },
                          ),
                          SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}
