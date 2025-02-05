import 'package:new_bc/page/user/edit_profile.dart';
import 'package:new_bc/page/home.dart';
import 'package:new_bc/utils/user_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/user.dart';
import '../../widget/numbers_widget.dart';
import '../../widget/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  final bool isEdit;
  final bool isMain;

  const ProfilePage({Key? key, required this.isEdit, required this.isMain})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  final box = GetStorage();

  Future<Map<dynamic, dynamic>> getUser() async {
    CollectionReference user = FirebaseFirestore.instance.collection('Users');

    final userSnap = await user.doc(box.read('wallet' ?? '')).get();
    final userData = userSnap.data() as Map;

    return userData;
  }

  Future<String> getUserImage() async {
    var id = box.read('wallet' ?? '');
    String imageURL = await FirebaseStorage.instance
        .ref()
        .child("UserPics/" + id + ".jpg")
        .getDownloadURL();

    return imageURL;
  }

  @override
  Widget build(BuildContext context) {
    final user = UserPreferences.myUser;

    return Scaffold(
      backgroundColor:
          widget.isMain ? Colors.white : Color.fromARGB(255, 244, 246, 252),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            widget.isMain ? Colors.white : Color.fromARGB(255, 244, 246, 252),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          onPressed: () {
            if (widget.isEdit) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(
                    walletaddress: box.read('wallet' ?? ''),
                  ),
                ),
              );
            } else {
              if (widget.isMain) Navigator.pop(context);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: widget.isMain
                ? Colors.black
                : Color.fromARGB(255, 244, 246, 252),
          ),
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          SizedBox(
            height: 50,
          ),
          FutureBuilder<String>(
            future: getUserImage(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return Center(
                    child: CircularProgressIndicator(color: Colors.blue));
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 15),
                  ),
                );
              }
              //프로필 사진
              else {
                return ProfileWidget(
                  imagePath: snapshot.data,
                  onClicked: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(),
                      ),
                    );
                  },
                );
              }
            },
          ),
          /* ProfileWidget(
            imagePath: "assets/images/profile.png",
            onClicked: () async {},
          ),*/
          const SizedBox(height: 24),
          FutureBuilder<Map>(
            future: getUser(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.blue)),
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
                return buildUser(snapshot.data['nickname'],
                    box.read('wallet' ?? ""), snapshot.data['about']);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildUser(String name, String id, String intro) => Column(
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            id,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          NumbersWidget(),
          const SizedBox(height: 19),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 48),
            width: 365,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  intro,
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      );

  Widget buildAbout(User user) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              user.about,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
}
