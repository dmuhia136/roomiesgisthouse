import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/profiles/widgets/user_profile_image.dart';
import 'package:gisthouse/pages/room/room_screen.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/dynamic_link_service.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

Future<Widget> upcomingroomBottomSheet(BuildContext context, UpcomingRoom room,
    bool loading, bool keyboardup) async {
  List<Club> clubs;
  if (room.clubListIds != null && room.clubListIds.isNotEmpty) {
    clubs = Database().getClubsByIdsDetails(room.clubListIds);
  }
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Style.AccentBlue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
    ),
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter mystate) {
        return Container(
          color: Style.AccentBlue,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Functions.timeFutureSinceDate(
                                      timestamp: room.eventtime),
                                  style: TextStyle(
                                      fontSize: 18, color: Style.DarkBrown),
                                ),
                                room.roomid != null &&
                                        room.userid ==
                                            Get.find<UserController>().user.uid
                                    ? GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          createUpcomingRoomSheet(
                                              context, false, room);
                                        },
                                        child: Text(
                                          "Edit",
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 18),
                                        ),
                                      )
                                    : GestureDetector(
                                        child: Icon(
                                          CupertinoIcons.bell,
                                          color: room.tobenotifiedusers
                                                      .indexWhere((element) =>
                                                          element ==
                                                          Get.find<
                                                                  UserController>()
                                                              .user
                                                              .uid) ==
                                                  -1
                                              ? Colors.white
                                              : Colors.red,
                                        ),
                                        onTap: () async {
                                          Get.back();
                                          if (room.tobenotifiedusers.indexWhere(
                                                  (element) =>
                                              element ==
                                                  Get.find<UserController>()
                                                      .user
                                                      .uid) ==
                                              -1) {
                                            await Database()
                                                .addUsertoUpcomingRoom(room,
                                                fromhome: true);
                                            room.tobenotifiedusers.add(Get.find<UserController>().user.uid);
                                          } else {
                                            await Database()
                                                .removeUserFromUpcomingRoom(
                                                room);
                                            room.tobenotifiedusers.add(Get.find<UserController>().user.uid);

                                          }
                                          mystate(() {

                                          });
                                        },
                                      )
                              ],
                            ),
                            Text(
                              room.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                      fontSize: 18.0, color: Colors.white),
                            ),
                            if(room.clubListNames.isNotEmpty) CategoryRow(category: room.clubListNames, color:Style.indigo, ids: room.clubListIds,),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 20, left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            room.users.length == 0
                                ? Container()
                                : Container(
                                    height: 43,
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: room.users
                                            .map((e) => Container(
                                                  margin:
                                                      EdgeInsets.only(right: 5),
                                                  child: UserProfileImage(
                                                    user: e,
                                                    height: 40,
                                                    borderRadius: 18,
                                                    width: 43,
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                            SizedBox(
                              height: 5,
                            ),
                            Wrap(
                              children: [
                                Text(
                                  "W/",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white),
                                ),
                                ...room.users
                                    .map((e) => Text(
                                          "${e.firstname} ${e.lastname}, ",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.white),
                                        ))
                                    .toList(),
                                Text(
                                  room.description,
                                  style: TextStyle(
                                      fontSize: 16, color: Style.HintColor),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    mystate(() {
                                      loading = true;
                                    });
                                    final RenderBox box =
                                        context.findRenderObject();
                                    DynamicLinkService()
                                        .createGroupJoinLink(
                                            room.roomid, "upcomingroom")
                                        .then((value) async {
                                      await Share.share(value,
                                          subject: "Join " + room.title,
                                          sharePositionOrigin:
                                              box.localToGlobal(Offset.zero) &
                                                  box.size);
                                      mystate(() {
                                        loading = false;
                                      });
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        CupertinoIcons.share,
                                        size: 25,
                                        color: Colors.green,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Share",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    mystate(() {
                                      loading = true;
                                    });
                                    DynamicLinkService()
                                        .createGroupJoinLink(
                                            room.roomid, "upcomingroom")
                                        .then((value) async {
                                      Clipboard.setData(ClipboardData(
                                          text:
                                              "${room.title} \n${room.description} $value"));
                                      mystate(() {
                                        loading = false;
                                      });
                                      Get.snackbar(
                                          "", "Share Link Copied To Clipboard",
                                          snackPosition: SnackPosition.BOTTOM,
                                          borderRadius: 0,
                                          margin: EdgeInsets.all(0),
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                          messageText: Text.rich(TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    "Share Link Copied To Clipboard",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          )));
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        CupertinoIcons.doc_on_clipboard,
                                        size: 25,
                                        color: Colors.green,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Copy Link",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      //
                      if (Get.put(UserController()).user.uid == room.userid)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: CustomButton(
                              color: Style.AccentGreen,
                              text: "Start the room",
                              minimumWidth: double.infinity * 0.8,
                              onPressed: () async {
                                mystate(() {
                                  loading = true;
                                });

                                if (room.status == "ongoing") {
                                  topTrayPopup("Room is already started");
                                } else {
                                  // creating a room
                                  String roomid = room.roomid;


                                  var ref = await Database().createRoom(
                                      userData: Get.put(UserController()).user,
                                      topic: room.title,
                                      clubs: clubs,
                                      roomid: roomid,
                                      currency: "GIST",
                                      amount: room.amount,
                                      type: "scheduled",
                                      openToMembersOnly: room.openToMembersOnly,
                                      users: room.users,
                                      sponsors: room.sponsors,
                                      context: context,
                                      upcominroom: room);

                                    await Permission.microphone.request();

                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (rc) {
                                        return RoomScreen(
                                          roomid: ref,
                                          exists: false,
                                        );
                                      },
                                    );

                                }

                                mystate(() {
                                  loading = false;
                                });
                              }),
                        ),
                    ],
                  ),
                ),
        );
      });
    },
  );
}
