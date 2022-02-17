
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';

Widget buildScheduleItem(UpcomingRoom room, {from = ""}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Container(
              child: Text(
                Functions.timeFutureSinceDate(dateString: room.publisheddate) +
                    " " +
                    room.timedisplay,
                style: TextStyle(
                  color: Style.DarkBrown,
                ),
              ),
            ),
          ),
          if(from != "clubview") GestureDetector(
            child: Icon(
              CupertinoIcons.bell,
              size: 35,
              color: room.users.indexWhere((element) =>
              element.uid ==
                  Get.find<UserController>().user.uid) !=
                  -1
                  ? Colors.red
                  : Colors.black,
            ),
            onTap: () async {
              if (room.users.indexWhere((element) =>
              element.uid == Get.find<UserController>().user.uid) ==
                  -1) {
                await Database().addUsertoUpcomingRoom(room,fromhome: true);
              }else{
                await Database().removeUserFromUpcomingRoom(room);
              }
            },
          )
        ],
      ),
      SizedBox(
        width: 10,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            room.title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: "InterSemiBold"),
          ),
          SizedBox(
            height: 3,
          ),
          if(from != "clubview") Row(
            children: [
              Text(
                'COMMUNITY CLUB'.toLowerCase(),
                style: TextStyle(
                  color: Style.AccentGrey,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                Icons.home,
                color: Style.AccentGreen,
                size: 15,
              )
            ],
          ),
          SizedBox(
            height: 2,
          ),
          room.users.length == 0
              ? Container()
              : Container(
            height: 43,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: room.users
                  .map((e) => GestureDetector(
                onTap: () async {
                  // await usersRef.doc(widget.room.userid).get().then((value) {
                  //
                  //   Get.to(() => UserProfileView(user: UserModel.fromJson(value)));
                  // });
                },
                child: Container(
                  height: 40,
                  width: 43,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        e.smallimage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
          SizedBox(
            height: 2,
          ),
          room.users.length == 0
              ? Container()
              : Container(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("w/ "),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: room.users
                        .map((e) => GestureDetector(
                      onTap: () async {
                        // await usersRef.doc(widget.room.userid).get().then((value) {
                        //
                        //   Get.to(() => UserProfileView(user: UserModel.fromJson(value)));
                        // });
                      },
                      child: Text(e.firstname+" "+e.lastname, style: TextStyle(fontStyle: FontStyle.italic),),
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    ],
  );
}