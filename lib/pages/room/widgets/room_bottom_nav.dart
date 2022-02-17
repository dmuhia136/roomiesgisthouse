//bottom widget of the room screen
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/raise_my_hand.dart';
import 'package:gisthouse/widgets/widgets.dart';

Widget buildBottomNav(
    {Room room,
    BuildContext context,
    UserModel myProfile,
    List raisedhandsusers,
    List users,
    RtcEngine engine,
    StateSetter state}) {
  if (room == null) return Container();
  int index = users.indexWhere((element) => element.uid == myProfile.uid);
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
//add icon
      GestureDetector(
        onTap: () {
          Get.to(() => PingUsers(room: room,customState: state,));
        },
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
              // shape: BoxShape.circle,
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8)),
          child: Icon(CupertinoIcons.add, size: 25),
        ),
      ),
      SizedBox(
        width: 10,
      ),
      room != null && myProfile.uid == room.ownerid ||
              users.indexWhere((element) =>
                      element.uid == myProfile.uid &&
                      element.usertype == "moderator") !=
                  -1
          ? GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
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

                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.hand_raised_fill,
                                          size: 30.0,
                                          color: Colors.grey,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "Raised hands",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontFamily:
                                                        "InterSemiBold"),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: Text(
                                                room.getHandsRaisedByType(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: "InterRegular"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                        onTap: () {
                                          showCupertinoModalPopup(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoActionSheet(
                                                    title: Text(
                                                        "Raised hands available to.."),
                                                    actions: [
                                                      CupertinoActionSheetAction(
                                                        child: const Text(
                                                            'Everyone'),
                                                        onPressed: () async {
                                                          mystate(() {});
                                                          await Database
                                                              .updateRoomData(
                                                                  room.roomid, {
                                                            "handsraisedby": 1
                                                          });
                                                          mystate(() {});
                                                          state(() => {});
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        child: const Text(
                                                            'Followed by the Speakers'),
                                                        onPressed: () async {
                                                          await Database
                                                              .updateRoomData(
                                                                  room.roomid, {
                                                            "handsraisedby": 2
                                                          });
                                                          mystate(() {});
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      CupertinoActionSheetAction(
                                                        child: const Text(
                                                            'Nobody'),
                                                        onPressed: () async {
                                                          await Database
                                                              .updateRoomData(
                                                                  room.roomid, {
                                                            "handsraisedby": 3
                                                          });
                                                          mystate(() {});
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                    cancelButton:
                                                        CupertinoActionSheetAction(
                                                      child: Text(
                                                        'Cancel',
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ));
                                              });
                                        },
                                        child: Text(
                                          "Edit",
                                          style: TextStyle(
                                              color: Colors.blueAccent),
                                        )),
                                  ],
                                ),
                              ),
                              raisedhandsusers.length == 0
                                  ? Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 30),
                                      child: Center(
                                          child: Text(
                                        "No raised hands yet",
                                        style: TextStyle(fontSize: 21),
                                      )))
                                  : Text(""),
                              ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: raisedhandsusers.map((user) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 20),
                                    child: ListTile(
                                      // leading: UserProfileImage(imageUrl: user.imageurl, size: 60, type:"header"),
                                      title: Text(user.username),
                                      trailing: GestureDetector(
                                        onTap: () {
                                          activateDeactivateUser(user, room,
                                              mystate, raisedhandsusers);
                                          raisedhandsusers.remove(user);
                                          Functions().sendNotificationToSpeakerFollowers(user, room.roomid);
                                          mystate(() {});
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: user.callmute == true
                                                ? Colors.grey
                                                : Colors.red,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(25),
                                                topRight: Radius.circular(25),
                                                bottomRight:
                                                    Radius.circular(25),
                                                bottomLeft:
                                                    Radius.circular(25)),
                                          ),
                                          width: 80,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Icon(
                                                CupertinoIcons.check_mark,
                                                size: 23.0,
                                                color: Colors.white,
                                              ),
                                              const Icon(
                                                CupertinoIcons.mic_solid,
                                                size: 23.0,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      });
                    });
              },
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.news,
                      size: 30.0,
                      color: Colors.black,
                    ),
                    room.raisedhands.length > 0
                        ? Positioned(
                            right: 0.6,
                            top: 0.8,
                            child: Container(
                              height: 18.0,
                              width: 18.0,
                              child: Center(
                                child: Text(
                                  "${room.raisedhands.length}",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                            ),
                          )
                        : Text(""),
                  ],
                ),
              ),
            )
          : Text(""),
      SizedBox(
        width: 10,
      ),

      //If the user is not a speaker or moderator,
      // and everyone or people who are followed by the speakers are allowed to raise hands,
      // show the raise hands icon
      // if not, don't show it
      if (users.indexWhere((element) => element.uid == myProfile.uid) != -1 &&
          users[users.indexWhere((element) => element.uid == myProfile.uid)]
                  .usertype ==
              "others")
        //If everyone is allowed to raise hands
        room.handsraisedby == 1
            ? GestureDetector(
                onTap: () {
                  // if(room.raisedhands == 1 || myProfile){
                  raiseMyHandView(context, room, myProfile);
                  // }
                },
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    CupertinoIcons.hand_raised,
                    size: 28,
                  ),
                ),
              )
            //If people who are followed by the speakers are allowed to raise hands
            : room.handsraisedby == 2 &&
                    Database().followedBySpeakersCheck(users) == true
                ? GestureDetector(
                    onTap: () {
                      // if(room.raisedhands == 1 || myProfile){
                      raiseMyHandView(context, room, myProfile);
                      // }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                          // shape: BoxShape.circle,
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        CupertinoIcons.hand_raised,
                        size: 28,
                      ),
                    ),
                  )
                : Text(""),
      index != -2 && index != -1 && users[index].usertype != "others"
          ? GestureDetector(
              onTap: () {
                //initiate raising a hand
                Database.callMuteUnmute(room, index, users);

                users[index].callmute = !users[index].callmute;

                state(() => {});
              },
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: users[index].callmute == true
                    ? const Icon(CupertinoIcons.mic_off, size: 25.0)
                    : const Icon(
                        CupertinoIcons.mic_fill,
                        size: 25.0,
                        color: Colors.black,
                      ),
              ),
            )
          : Text(""),
    ],
  );
}
