//search people to ping to join the room
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/Notifications/push_nofitications.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/room/followers_match_grid_sheet.dart';
import 'package:gisthouse/util/style.dart';

class PingUsers extends StatefulWidget {
  Room room;
  final StateSetter customState;

  PingUsers({this.room,this.customState});

  @override
  _PingUsersState createState() => _PingUsersState();
}

class _PingUsersState extends State<PingUsers> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/images/bg.png",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Style.LightBrown,
          iconTheme: IconThemeData  (
            color: Colors.black
          ),
          elevation: 5,
        ),
        body: FollowerMatchGridPage(
          callback: pingCallback,
          title: "Invite friends to Gist",
          fromroom: true,
          room: widget.room,
          customState: widget.customState,
        ),
      ),
    );
  }
}

//user click listener on the ping user bottom sheet
pingCallback(UserModel user, Room room, StateSetter state, bool send) {
  // Get.back();
  if (send) {
    String title = Get.find<UserController>().user.getName() +
        " pinged you to join their GistRoom" +
        room.title;
    PushNotificationsManager().callOnFcmApiSendPushNotifications(
        [user.firebasetoken],
        "GistHouse Room Invite",
        title,
        "RoomScreen",
        room.roomid,
        paidroom: room.amount > 0);
  }
}
