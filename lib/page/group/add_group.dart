import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/page/group/detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user.dart';
import '../../utils/user_preferences.dart';
import '../../widget/photo_widget.dart';
import '../../widget/profile_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditGroup extends StatefulWidget {
  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  CollectionReference groups = FirebaseFirestore.instance.collection('Groups');
  User user = UserPreferences.myUser;
  var groupImg = '';
  var chosenFilepath = null;
  var chosenFile = null;
  var name = '';
  var intro = '';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.black,
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(
              height: 20,
            ),
            PhotoWidget(
              imagePath: groupImg,
              isEdit: true,
              onClicked: () async {
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  groupImg = pickedFile.path;
                } else if (pickedFile == null) {
                  groupImg = '';
                }
                setState(() {});
              },
            ),
            const SizedBox(height: 75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Board Name",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Please enter the name of the board.",
                    //안에 입력 패딩
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[400]!)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[400]!)),
                    hintStyle: TextStyle(fontSize: 13),
                  ),
                  onChanged: (val) => name = val,
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
            SizedBox(height: 0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Introduction",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Please provide an introduction.",
                    //안에 입력 패딩
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[400]!)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[400]!)),
                    hintStyle: TextStyle(fontSize: 13),
                  ),
                  onChanged: (val) => intro = val,
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            SizedBox(
              height: 35,
            ),
            Container(
              padding: EdgeInsets.only(top: 3, left: 3),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border(
                    bottom: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                  )),
              child: MaterialButton(
                minWidth: double.infinity,
                height: 65,
                //그룹 생성 버튼 클릭 시
                onPressed: () async {
                  if (groupImg != '' && name != '' && intro != '') {
                    bool exist = await MyFire.existGroup(name);
                    if (!exist) {
                      groups.add({
                        "founder": MyFire.box.read("wallet" ?? ''),
                        "name": name,
                        "intro": intro,
                        "url": groupImg,
                        "timestamp": MyFire.getCurrentTimestamp(),
                        "members": 1
                      });
                      MyFire.setGroupPic(groupImg, name);
                      MyFire.joins.doc(MyFire.wallet).update({
                        'groups': FieldValue.arrayUnion([name]),
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupDetail(view: 0),
                        ),
                      );
                      MyFire.box.write('currentGroup', name);
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Cannot Create"),
                          content: Text(
                            "The group already exists.",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          actions: [],
                        ),
                      );
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Cannot Create"),
                        content: Text("Please fill out the form completely.",
                            style: TextStyle(color: Colors.red)),
                        actions: [],
                      ),
                    );
                  }
                },
                color: Color.fromARGB(255, 153, 218, 255),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: Text(
                  "Create a board",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      );

  /* chooseFile() async {
    chosenFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (chosenFile != null) {
      chosenFilepath = chosenFile.path;
      return chosenFile.path;
    }
  }*/

  Widget makeInput({
    label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        SizedBox(
          height: 5,
        ),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            //안에 입력 패딩
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]!)),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]!)),
          ),
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
