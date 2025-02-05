import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String? group_name;
  String? group_release_time;
  String? group_poster_url;
  int? members;

  GroupModel(this.group_name, this.group_release_time, this.group_poster_url,
      this.members);
}

// ignore: non_constant_identifier_names
List<GroupModel> main_group_list = [
  GroupModel("Developers", "2022.12.14", "assets/images/Magical_World.png", 4),
  GroupModel("SSLab", "2019.07.12", "assets/images/m_world.png", 20),
  GroupModel(
      "YouTubers", "2018.03.01", "assets/images/Magical_World.png", 50002),
  GroupModel("Swifties", "2022.02.02", "assets/images/m_world.png", 465),
];

class Comment {
  String name;
  String text;
  String ImageUrl;

  Comment(this.name, this.text, this.ImageUrl);
}

List<Comment> comments = [
  Comment("다운", "와 사진이 너무 귀여워용", "assets/images/m_world.png"),
  Comment("현주", "퍼가요", "assets/images/Magical_World.png"),
  Comment("John", "nice!!!!!!", "assets/images/m_world.png"),
  Comment("다운", "와 사진이 너무 귀여워용", "assets/images/Magical_World.png"),
];

class Group {
  String id;
  String name;
  String intro;
  Timestamp release_time;
  String poster_url;
  int members;

  Group(
      {this.id = '',
      this.name = '',
      this.intro = '',
      Timestamp? release_time,
      this.poster_url = '',
      this.members = 0})
      : release_time = release_time ?? Timestamp(0, 0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'intro': intro,
      'release_time': release_time,
      'poster_url': poster_url,
      'members': members
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
        id: map['id'],
        name: map['name'],
        intro: map['intro'],
        release_time: map['release_time'] ?? Timestamp(0, 0),
        poster_url: map['poster_url'],
        members: map['members']);
  }
}
