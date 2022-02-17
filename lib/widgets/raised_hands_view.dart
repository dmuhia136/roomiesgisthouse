
//raised hands bottom sheet widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/models/room_user.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/widgets/widgets.dart';

Widget raisedHandsView(
      StateSetter mystate,
      Room room,
      BuildContext context,
      List<RoomUser> raisedhandsusers
    ) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.hand_raised_fill,
                    size: 30.0,
                    color: Colors.grey,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Raised hands",
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "InterSemiBold"
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          room.getHandsRaisedByType(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontFamily: "InterRegular"),
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
                              title: Text("Raised hands available to.."),
                              actions: [
                                CupertinoActionSheetAction(
                                  child: const Text('Everyone'),
                                  onPressed: () async {
                                    mystate(() {});
                                    await Database.updateRoomData(
                                        room.roomid, {"handsraisedby": 1});
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoActionSheetAction(
                                  child:
                                  const Text('Followed by the Speakers'),
                                  onPressed: () async {
                                    await Database.updateRoomData(
                                        room.roomid, {"handsraisedby": 2});
                                    mystate(() {});
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoActionSheetAction(
                                  child: const Text('Nobody'),
                                  onPressed: () async {
                                    await Database.updateRoomData(
                                        room.roomid, {"handsraisedby": 3});
                                    mystate(() {});
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                              cancelButton: CupertinoActionSheetAction(
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
                    style: TextStyle(color: Colors.blueAccent),
                  )),
            ],
          ),
        ),
        raisedhandsusers.length == 0
            ? Container(
            margin: EdgeInsets.symmetric(vertical: 30),
            child: Center(
                child: Text(
                  "No raised hands yet",
                  style: TextStyle(fontSize: 21),
                )))
            : Text(""),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: raisedhandsusers.map((RoomUser user) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: ListTile(
                // leading: UserProfileImage(imageUrl: user.imageurl, size: 60, type:"header"),
                title: Text(user.username),
                trailing: GestureDetector(
                  onTap: () {
                    activateDeactivateUser(user,room,mystate,raisedhandsusers);
                    mystate(() {});
                  },
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: user.callmute == true ? Colors.grey : Colors.red,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                          bottomLeft: Radius.circular(25)),
                    ),
                    width: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
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
}

