
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/room/add_co_host.dart';
import 'package:gisthouse/pages/upcomingrooms/new_upcoming_room.dart';
import 'package:gisthouse/pages/upcomingrooms/upcoming_roomsreen.dart';
import 'package:gisthouse/util/utils.dart';


List<UserModel> hosts = [Get.find<UserController>().user];
userClickCallBack(UserModel user) {
  if (!hosts.contains(user)) hosts.add(user);
}
void addCoHost(BuildContext context, StateSetter mystate) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        )),
    builder: (context) {
      return AddCoHostScreen(
          clickCallback: userClickCallBack, mystate: mystate);
    },
  ).whenComplete(() {
  });
}

Future<Widget> createUpcomingRoomSheet(BuildContext context,bool keyboardup,
    [UpcomingRoom roomm]) async {
  if (roomm != null) {
    eventcontroller.text = roomm.title;
    descriptioncontroller.text = roomm.description;
  }


  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Style.LightGrey,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
    ),
    builder: (context) {
      return NewUpcomingRoom(roomm: roomm,);
    },
  );
}