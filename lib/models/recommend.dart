import 'package:new_bc/models/user.dart';
import 'package:flutter/material.dart';

class TravelSpot {
  final String name, image;
  final DateTime date;
  final List<User> users;

  TravelSpot({
    required this.users,
    required this.name,
    required this.image,
    required this.date,
  });
}

List<TravelSpot> recommendGroups = [
  TravelSpot(
    users: users..shuffle(),
    name: "Red Mountains",
    image: "assets/images/Red_Mountains.png",
    date: DateTime(2020, 10, 15),
  ),
  TravelSpot(
    users: users..shuffle(),
    name: "Megical World",
    image: "assets/images/Magical_World.png",
    date: DateTime(2020, 3, 10),
  ),
  TravelSpot(
    users: users..shuffle(),
    name: "Red Mountains",
    image: "assets/images/Red_Mountains.png",
    date: DateTime(2020, 10, 15),
  ),
];

List<User> users = [user1, user2, user3];

User user1 =
    User(name: "IU", imagePath: "assets/images/james.png", id: "1", about: "1");
User user2 = User(
    name: "John", imagePath: "assets/images/John.png", id: "1", about: "1");
User user3 =
    User(name: "다운", imagePath: "assets/images/marry.png", id: "1", about: "1");
User user4 = User(
    name: "Rosy", imagePath: "assets/images/rosy.png", id: "1", about: "1");
