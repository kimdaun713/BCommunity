import 'package:new_bc/main.dart';
import 'package:new_bc/models/group.dart';
import 'package:new_bc/page/group/add_group.dart';
import 'package:new_bc/page/home.dart';
import 'package:new_bc/page/group/my_group.dart';
import 'package:new_bc/page/group/search.dart';
import 'package:flutter/material.dart';
import '../../animation/constants.dart';
import '../../animation/size_config.dart';
import '../../models/recommend.dart';
import '../../models/user.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Column(
        children: [
          HomeHeader(),
          SizedBox(
            height: 43,
          ),
          RecommGroup(),
          SizedBox(height: 40),
          SectionTitle(title: "Favorite", press: () {}),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(kDefaultPadding),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(24)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [kDefualtShadow],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(
                  main_group_list.length,
                  (index) => JoinCard(group: main_group_list[index]),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Image.asset(
            'assets/aiback.jpg',
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}

class JoinCard extends StatelessWidget {
  const JoinCard({
    Key? key,
    required this.group,
  }) : super(key: key);

  final GroupModel group;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            group.group_poster_url!,
            height: getProportionateScreenWidth(55),
            width: getProportionateScreenWidth(55),
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(group.group_name!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ))
      ],
    );
  }
}

class RecommGroup extends StatelessWidget {
  const RecommGroup({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(kDefaultPadding)),
          child: Row(
            children: [
              Text(
                "Popular",
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditGroup(),
                    ),
                  );
                },
                child: Icon(
                  Icons.group_add,
                  color: Color.fromARGB(255, 39, 149, 252),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        SingleChildScrollView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(
                main_group_list.length,
                (index) => Padding(
                  padding:
                      EdgeInsets.only(left: getProportionateScreenWidth(20)),
                  child: GroupCard(
                    groupModel: main_group_list[index],
                    press: () {},
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class GroupCard extends StatelessWidget {
  const GroupCard({
    Key? key,
    required this.groupModel,
    required this.press,
  }) : super(key: key);

  final GroupModel groupModel;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(137),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.29,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                image: DecorationImage(
                  image: AssetImage(groupModel.group_poster_url!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            width: getProportionateScreenWidth(137),
            padding: EdgeInsets.all(
              getProportionateScreenWidth(kDefaultPadding),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [kDefualtShadow],
            ),
            child: Column(
              children: [
                Text(
                  groupModel.group_name!,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 10,
                ),
                RegistUser(users: users),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class RegistUser extends StatelessWidget {
  const RegistUser({
    Key? key,
    required this.users,
  }) : super(key: key);

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    int totalUser = 0;
    return SizedBox(
      width: double.infinity,
      height: getProportionateScreenWidth(30),
      child: Stack(
        children: [
          ...List.generate(
            users.length,
            (index) {
              totalUser++;
              return Positioned(
                left: (22 * index).toDouble(),
                child: bulidUser(index),
              );
            },
          ),
          Positioned(
            left: (22 * totalUser).toDouble(),
            child: SizedBox(
              height: getProportionateScreenWidth(28),
              width: getProportionateScreenWidth(28),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {},
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ClipOval bulidUser(int index) {
    return ClipOval(
      child: Image.asset(
        users[index].imagePath,
        height: getProportionateScreenWidth(28),
        width: getProportionateScreenWidth(28),
        fit: BoxFit.cover,
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.title,
    required this.press,
  }) : super(key: key);

  final String title;
  final GestureTapCallback press;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(kDefaultPadding)),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MyGroupPage()),
              );
            },
            child: Text("Show All",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 101, 160).withOpacity(0.7),
                )),
          ),
        ],
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Image.asset(
          "assets/images/home_bg.png",
          height: getProportionateScreenWidth(280),
          fit: BoxFit.cover,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getProportionateScreenHeight(4)),
            Text(
              "B-Community",
              style: TextStyle(
                fontSize: getProportionateScreenWidth(40),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 0.5,
              ),
            ),
            Text(
              'Blockchain based Community App',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        Positioned(
          bottom: getProportionateScreenWidth(-25),
          child: SearchField(),
        ),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  static final TextEditingController _searchController =
      TextEditingController();
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getProportionateScreenWidth(313),
      height: getProportionateScreenWidth(50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Color.fromARGB(255, 72, 145, 255)),
        boxShadow: [
          BoxShadow(
            offset: Offset(3, 3),
            blurRadius: 10,
            color: Colors.black.withOpacity(0.16),
            spreadRadius: -2,
          )
        ],
      ),
      child: TextField(
        onChanged: (value) {},
        decoration: InputDecoration(
          hintText: "Search for groups!",
          hintStyle: TextStyle(
            fontSize: getProportionateScreenWidth(13),
            color: Color.fromARGB(255, 136, 152, 172),
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              String searchValue = _searchController.text;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchPage(),
                ),
              );
            },
            child: Icon(Icons.search, color: Color.fromARGB(255, 6, 118, 209)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(kDefaultPadding),
            vertical: getProportionateScreenHeight(kDefaultPadding / 2),
          ),
        ),
      ),
    );
  }
}
