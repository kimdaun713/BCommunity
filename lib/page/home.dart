import 'package:new_bc/animation/constants.dart';
import 'package:new_bc/manager/firebase_controller.dart';
import 'package:new_bc/page/components/body.dart';
import 'package:new_bc/page/user/login.dart';
import 'package:new_bc/page/user/my_profile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../animation/FadeAnimation.dart';
import '../animation/size_config.dart';

class metaNextscreenui extends StatelessWidget {
  final String walletaddress;
  final profile = false;

  const metaNextscreenui({Key? key, required this.walletaddress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FadeAnimation(
              1,
              Text(
                "Integration successful",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 10,
          ),
          FadeAnimation(
              1.2,
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "계정 정보: ${walletaddress} ",
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
              )),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String walletaddress;
  final box = GetStorage();

  Future<String> getUserImage() async {
    var id = MyFire.box.read('wallet' ?? '');
    String imageURL = await FirebaseStorage.instance
        .ref()
        .child("UserPics/" + this.walletaddress + ".jpg")
        .getDownloadURL();

    return imageURL;
  }

  HomeScreen({Key? key, required this.walletaddress}) : super(key: key);
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(68.0), child: buildAppBar(context)),
      body: Container(color: Colors.white, child: Body()),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(kDefaultPadding)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Nav1(isActive: true, press: () {}),
                NavIcon(press: () {}),
                Nav3(press: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        //메뉴
        icon: Icon(Icons.menu, color: Colors.white70),
        onPressed: () {},
      ),
      actions: [
        //프로필
        FutureBuilder(
            //유저 이미지
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
              } else {
                return IconButton(
                    padding: new EdgeInsets.only(left: 15, top: 12, right: 12),
                    iconSize: 85,
                    icon: ClipOval(
                        child: Image.network(
                      snapshot.data,
                      fit: BoxFit.cover,
                      width: 45,
                      height: 70,
                    )),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfilePage(isEdit: true, isMain: true),
                        ),
                      );
                    });
              }
            }),
      ],
    );
  }
}

class Nav3 extends StatelessWidget {
  const Nav3({
    Key? key,
    this.isActive = false,
    required this.press,
  }) : super(key: key);

  final bool isActive;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      height: getProportionateScreenWidth(60),
      width: getProportionateScreenWidth(60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [if (isActive) kDefualtShadow],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Icon(
              size: 30,
              Icons.settings_outlined,
              color: Color.fromARGB(255, 91, 162, 255),
            ),
          ),
          Spacer(),
          Text("Settings",
              style: TextStyle(
                  color: Color.fromARGB(255, 91, 162, 255),
                  fontSize: 11,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}

class Nav1 extends StatelessWidget {
  const Nav1({
    Key? key,
    this.isActive = false,
    required this.press,
  }) : super(key: key);

  final bool isActive;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      height: getProportionateScreenWidth(60),
      width: getProportionateScreenWidth(60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [if (isActive) kDefualtShadow],
      ),
      child: Column(
        children: [
          isActive
              ? Icon(
                  size: 30,
                  Icons.home,
                  color: Color.fromARGB(255, 91, 162, 255),
                )
              : Icon(
                  size: 30,
                  Icons.home_outlined,
                  color: Color.fromARGB(255, 91, 162, 255),
                ),
          Spacer(),
          Text("Home",
              style: TextStyle(
                  color: Color.fromARGB(255, 91, 162, 255),
                  fontSize: 11,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}

class NavIcon extends StatelessWidget {
  const NavIcon({
    Key? key,
    this.isActive = false,
    required this.press,
  }) : super(key: key);

  final bool isActive;
  final GestureTapCallback press;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      height: getProportionateScreenWidth(60),
      width: getProportionateScreenWidth(60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [if (isActive) kDefualtShadow],
      ),
      child: Column(
        children: [
          Icon(
            size: 30,
            Icons.notifications_active_outlined,
            color: Color.fromARGB(255, 91, 162, 255),
          ),
          Spacer(),
          Text("Alert",
              style: TextStyle(
                  color: Color.fromARGB(255, 91, 162, 255),
                  fontSize: 11,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
