import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/widgets.dart';

class FollowerMatchGridPage extends StatefulWidget {
  final Function callback;
  final String title;
  final bool fromroom;
  final StateSetter state;
  final StateSetter customState;
  final room;

  FollowerMatchGridPage(
      {this.customState,
      this.state,
      this.callback,
      this.title,
      this.fromroom,
      this.room});

  @override
  _FollowerMatchGridPageState createState() => _FollowerMatchGridPageState();
}

class _FollowerMatchGridPageState extends State<FollowerMatchGridPage> {
  UserModel myProfile = Get.find<UserController>().user;
  bool loading = false;
  final globalScaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = new TextEditingController();
  List<UserModel> allusers = [];
  List<UserModel> roomallusers = [];
  List<UserModel> pinggedusers = [];

  userclickCallBack(UserModel user) {
    bool send = false;
    if (roomallusers.indexWhere((element) => element.uid == user.uid) == -1) {
      send = true;
      roomallusers.add(user);
    } else if (roomallusers.indexWhere((element) => element.uid == user.uid) !=
        -1) {
      send = false;
      roomallusers.removeAt(
          roomallusers.indexWhere((element) => element.uid == user.uid));
    }
    if (widget.fromroom == true) {
      widget.callback(user, widget.room, widget.customState,send);
    } else {
      widget.callback(roomallusers, widget.room, widget.state,send);
    }
    // widget.customState(() {});
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return buildAvailableChatList(context);
  }

  List<UserModel> _buildSearchList(String userSearchTerm) {
    List<UserModel> _searchList = [];

    if (userSearchTerm.isEmpty) {
      return allusers;
    }
    for (int i = 0; i < allusers.length; i++) {
      String name = allusers[i].getName();
      if (name.toLowerCase().contains(userSearchTerm.toLowerCase())) {
        _searchList.add(allusers[i]);
      }
    }
    return _searchList;
  }

  Widget buildAvailableChatList(BuildContext context) {
    return Container(
      color: Style.themeColor,
      child: Column(

        children: [
          Container(

            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "DONE",
                      style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                    ))
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8)),
              child: TextFormField(
                  style: TextStyle(color: Colors.black),
                  controller: textController,
                  decoration: InputDecoration(
                      hintText: "Search",
                      labelStyle: TextStyle(color: Style.HintColor),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Style.HintColor,
                      ),
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Style.HintColor)),
                  onChanged: (value) {
                    setState(() {});
                  })),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: FutureBuilder(
                  future: Database.getmyFollowers(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Center(
                          child: noDataWidget(
                              "No users whom you follow each others"));
                    }
                    if (snapshot.data.length == 0) {
                      return Center(
                          child: Text("No users who you follow each others"));
                    }
                    allusers = snapshot.data;
                    return GridView.builder(
                      itemCount: _buildSearchList(textController.text).length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (BuildContext context, int index) {
                        return userWidgetWithInfo(
                            user: _buildSearchList(textController.text)[index],
                            selected: roomallusers.indexWhere((element) =>
                                        element.uid ==
                                        _buildSearchList(
                                                textController.text)[index]
                                            .uid) !=
                                    -1
                                ? true
                                : false,
                            clickCallBack: userclickCallBack);
                        // }
                      },
                    );
                  }),
            ),
          ),
          // Container(
          //   margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Image.asset("assets/icons/tweet.png"),
          //       InkWell(
          //         child: Image.asset("assets/icons/share.png"),
          //         onTap: () {
          //           final RenderBox box = context.findRenderObject();
          //           DynamicLinkService()
          //               .createGroupJoinLink(widget.room.roomid)
          //               .then((value) async {
          //             Navigator.pop(context);
          //             await Share.share(value,
          //                 subject: "Join " + widget.room.title,
          //                 sharePositionOrigin:
          //                     box.localToGlobal(Offset.zero) & box.size);
          //           });
          //         },
          //       ),
          //       InkWell(
          //         child: Image.asset("assets/icons/copylink.png"),
          //         onTap: () {
          //           DynamicLinkService()
          //               .createGroupJoinLink(widget.room.roomid, "upcomingroom")
          //               .then((value) async {
          //             Clipboard.setData(ClipboardData(text: value));
          //
          //             Get.snackbar("", "Share Link Copied To Clipboard",
          //                 snackPosition: SnackPosition.BOTTOM,
          //                 borderRadius: 0,
          //                 margin: EdgeInsets.all(0),
          //                 backgroundColor: Colors.red,
          //                 colorText: Colors.white,
          //                 messageText: Text.rich(TextSpan(
          //                   children: [
          //                     TextSpan(
          //                       text: "Share Link Copied To Clipboard",
          //                       style: TextStyle(
          //                         color: Colors.white,
          //                         fontSize: 16.0,
          //                         fontWeight: FontWeight.w500,
          //                       ),
          //                     ),
          //                   ],
          //                 )));
          //           });
          //         },
          //       )
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
