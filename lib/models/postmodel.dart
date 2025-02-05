import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  String groupID;
  String writerID;
  String title;
  String text;
  String releaseTime;
  String picURL;
  int likes;
  int views;
  int dangerScore;
  bool activate;

  @override
  int get hashCode =>
      groupID.hashCode ^
      writerID.hashCode ^
      title.hashCode ^
      text.hashCode ^
      releaseTime.hashCode;

  @override
  Posts(
      {this.groupID = '',
      this.writerID = '',
      this.title = '',
      this.text = '',
      this.releaseTime = "",
      this.picURL = '',
      this.likes = 0,
      this.views = 0,
      this.dangerScore = 0,
      this.activate = true});

  Map<String, dynamic> toMap() {
    return {
      'grouID': groupID,
      'writerID': writerID,
      'title': title,
      'text': text,
      'release_time': releaseTime,
      'poster_url': picURL,
      'likes': likes,
      'views': views,
      'DangerScore': dangerScore,
      'activate': activate
    };
  }
}
