import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/profiles/widgets/user_profile_image.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:intl/intl.dart';

class UpcomingRoomCard extends StatefulWidget {
  final UpcomingRoom room;

  const UpcomingRoomCard({
    Key key,
    @required this.room,
  }) : super(key: key);

  @override
  _UpcomingRoomCardState createState() => _UpcomingRoomCardState();
}

class _UpcomingRoomCardState extends State<UpcomingRoomCard> {
  bool loading = false;
   allWordsCapitilize (String str) {
     return str = str.splitMapJoin(RegExp(r'\w+'),onMatch: (m)=> '${m.group(0)}'.substring(0,1).toUpperCase() +'${m.group(0)}'.substring(1).toLowerCase() ,onNonMatch: (n)=> ' ');
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        upcomingroomBottomSheet(context, widget.room, loading, false);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat("h:mm a").format(
                      DateTime.fromMillisecondsSinceEpoch(
                          widget.room.eventtime)),
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: "InterBold"),
                ),
                widget.room.userid != Get.find<UserController>().user.uid
                    ? GestureDetector(
                        child: Icon(
                          CupertinoIcons.bell,
                          size: 35,
                          color: widget.room.tobenotifiedusers.indexWhere(
                                      (element) =>
                                          element ==
                                          Get.find<UserController>()
                                              .user
                                              .uid) !=
                                  -1
                              ? Colors.red
                              : Colors.black,
                        ),
                        onTap: () async {
                          if (widget.room.tobenotifiedusers.indexWhere(
                                  (element) =>
                                      element ==
                                      Get.find<UserController>().user.uid) ==
                              -1) {
                            await Database().addUsertoUpcomingRoom(widget.room);
                            widget.room.tobenotifiedusers.add(Get.find<UserController>().user.uid);
                          } else {
                            await Database()
                                .removeUserFromUpcomingRoom(widget.room);
                            widget.room.tobenotifiedusers.removeWhere((item) =>
                            item == Get.find<UserController>().user.uid);

                          }
                          setState(() {

                          });
                        },
                      )
                    : Container(),
              ],
            ),
            Text(allWordsCapitilize(widget.room.title),
                style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "InterBold",
                    color: Style.AccentBrown)),
            widget.room.clubListNames.isNotEmpty
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.02,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: widget.room.clubListNames
                            .map(
                              (e) => Row(
                                children: [
                                  Text(
                                    e,
                                    style: TextStyle(
                                        color: Style.AccentGrey,
                                        fontSize: 12,
                                        fontFamily: "InterBold"),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Icon(
                                    Icons.home,
                                    color: Style.AccentGreen,
                                    size: 16,
                                  ),
                                  Text(
                                    ", ",
                                    style: TextStyle(
                                        color: Style.AccentGrey,
                                        fontSize: 12,
                                        fontFamily: "InterBold"),
                                  ),
                                ],
                              ),
                            )
                            .toList()),
                  )
                //     :
                // widget.room.clubname.isNotEmpty
                //     ?
                // Row(
                //         children: [
                //           Text(
                //             "From " + widget.room.clubname,
                //             style: TextStyle(
                //                 color: Style.AccentGrey,
                //                 fontSize: 12,
                //                 fontFamily: "InterBold"),
                //           ),
                //           SizedBox(
                //             width: 5,
                //           ),
                //           Icon(
                //             Icons.home,
                //             color: Style.AccentGreen,
                //             size: 18,
                //           )
                //         ],
                //       )
                : Container(),
            SizedBox(
              height: 5,
            ),
            widget.room.users.length == 0
                ? Container()
                : Container(
                    height: 43,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: widget.room.users
                          .map((e) => Container(
                                margin: EdgeInsets.only(right: 5),
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
            SizedBox(
              height: 5,
            ),
            Wrap(
              children: [
                Text(
                  "W/",
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Style.AccentBrown),
                ),
                ...widget.room.users
                    .map((e) => Text(
                          "${e.firstname} ${e.lastname}, ",
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Style.AccentBrown),
                        ))
                    .toList(),
              ],
            ),
            Text(
              widget.room.description,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: "InterLight",
                  color: Style.AccentBrown),
            )
          ],
        ),
      ),
    );
  }
}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}