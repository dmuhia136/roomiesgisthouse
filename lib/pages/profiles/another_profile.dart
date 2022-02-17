import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:gisthouse/controllers/user_controller.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';

class AnotherProfile extends StatefulWidget{

  String id;


  AnotherProfile(this.id);

  @override
  _AnotherProfile createState() => _AnotherProfile();
}

class _AnotherProfile extends State<AnotherProfile> {
  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      userid: widget.id,
      fromRoom: true,
      isMe:
      widget.id == Get.find<UserController>().user.uid,
    );
  }

}