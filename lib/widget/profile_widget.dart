import 'dart:io';

import 'package:new_bc/page/user/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final bool isEdit;
  final bool isMe;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    this.isEdit = false,
    this.isMe = true,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Colors.blue;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          if (isMe)
            Positioned(
              bottom: 0,
              right: 4,
              child: buildEditIcon(color, context),
            ),
        ],
      ),
    );
  }

  Widget buildImage() {
    if (imagePath[0] != "h") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: FileImage(File(imagePath)),
            fit: BoxFit.cover,
            width: 160,
            height: 180,
            child: InkWell(onTap: onClicked),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: NetworkImage(imagePath),
            fit: BoxFit.cover,
            width: 160,
            height: 180,
            child: InkWell(onTap: onClicked),
          ),
        ),
      );
    }
  }

  Widget buildEditIcon(Color color, BuildContext context) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 2,
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(),
                ),
              );
            },
            icon: Icon(
              isEdit ? Icons.add_a_photo : Icons.edit,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
