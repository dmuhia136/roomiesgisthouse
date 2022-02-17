import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/dynamic_link_service.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:mailto/mailto.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

userActionSheet(BuildContext context, {UserModel profile, UserModel userModel, bool fromRoom, Room room, String userType}) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) =>
        CupertinoActionSheet(
            title: Text(profile.getName()),
            actions: [
              CupertinoActionSheetAction(
                child:
                const Text('Share Profile..', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  final RenderBox box = context.findRenderObject();
                  DynamicLinkService()
                      .createGroupJoinLink(profile.username, "profile")
                      .then((value) async {
                    await Share.share(value,
                        subject: "Share " + profile.getName() +
                            " Profile",
                        sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size);
                  });
                },
              ),
              if (profile.uid != userModel.uid) CupertinoActionSheetAction(
                child: Text(
                    userModel.blocked.contains(profile.uid) == true
                        ? 'Unblock'
                        : "Block",
                    style: TextStyle(color: Colors.red, fontSize: 16)),
                onPressed: () {
                  Navigator.pop(context);
                  // if (userModel.blocked.contains(profile.uid)) {
                  //   unBlockProfile(context,
                  //       myprofile: userModel, reportuser: profile);
                  // } else {
                  //   blockProfile(context,
                  //       myprofile: userModel, reportuser: profile);
                  // }
                },
              ),
              if (profile.uid != userModel.uid)
                CupertinoActionSheetAction(
                  child: Text("Report ${profile.username}",
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                  onPressed: () {
                    Navigator.pop(context);
                    reportProfile(context,profile);
                  },
                ),
              if (fromRoom == true &&
                  room.ownerid == userModel.uid && profile.uid != userModel.uid)
                CupertinoActionSheetAction(
                  child: const Text('Remove from room',
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                  onPressed: () {
                    Database.removeUserFromRoom(room, profile);
                  },
                ),
              if (fromRoom == true && room.ownerid == userModel.uid)
                CupertinoActionSheetAction(
                  child: const Text('End Room',
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    // Navigator.pop(context);
                    await Functions.leaveChannel(

                        room: room,
                        currentUser: userModel,
                        context: context,
                        usertype: userType,
                        quit: true);
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
            )),
  );
}

/*
      report profile
   */
reportProfile(BuildContext context, UserModel profile) {
  var reportcontroller = TextEditingController();

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Style.AccentBrown,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        )),
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
                initialChildSize: 0.9,
                expand: false,
                builder:
                    (BuildContext context,
                    ScrollController scrollController) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Why do you want to report ${profile
                              .username}?",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: new BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          height: 200,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            controller: reportcontroller,
                            maxLength: null,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                hintText:
                                "Describe why you want to report ${profile.username}",
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                fillColor: Colors.white),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CustomButton(
                          text: "Report Now",
                          color: Style.AccentBlue,
                          onPressed: () async {
                            if (reportcontroller.text.isNotEmpty) {
                              Navigator.pop(context);
                              final mailtoLink = Mailto(
                                to: [adminemail],
                                subject:
                                '${profile.username} profile reported',
                                body: reportcontroller.text,
                              );
                              await launch('$mailtoLink');
                            }
                          },
                        )
                      ],
                    ),
                  );
                });
          });
    },
  );
}
