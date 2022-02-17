import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/room/room_screen.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/follower_item.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widgets/widgets.dart';
import '../profiles/user_profile_page.dart';

class FollowerPage extends StatefulWidget {
  @override
  _FollowerPageState createState() => _FollowerPageState();
}

class _FollowerPageState extends State<FollowerPage> {
  UserModel myProfile = Get.find<UserController>().user;
  bool loading = false;
  final globalScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalScaffoldKey,
      backgroundColor: Style.themeColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
        ),
        child: loading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  buildAvailableChatTitle(),
                  SizedBox(
                    height: 15,
                  ),
                  buildAvailableChatList(context),
                ],
              ),
      ),
    );
  }
// Available to chat
  Widget buildAvailableChatTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'AVAILABLE TO CHAT',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Style.BlackFade),
          ),
          SizedBox(
            width: 15.0,
          ),

          Expanded(
            child: Container(
              height: 1,
              color: Style.BlackFade,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvailableChatList(BuildContext context) {
    return FutureBuilder(
        future: Database.getMyOnlineFriends(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return Text("Technical Error");
          }
          if(snapshot.connectionState == ConnectionState.waiting){
            return loadingWidget(context);
          }
          if (snapshot.data == null) {
            return noDataWidget(
                "We list users whom you follow each other and are online that you can chat with here",
                fontsize: 16);
          }
          List<UserModel> users = snapshot.data;
          return ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (lc, i) {
              return SizedBox(
                height: 15,
              );
            },
            physics: ScrollPhysics(),
            itemBuilder: (lc, index) {
              return FollowerItem(
                user: users[index],
                onProfileTap: () {
                  Get.to(() => ProfilePage(
                        profile: users[index],
                        fromRoom: false,
                      ));
                },
                onRoomButtonTap: () async {
                  setState(() {
                    loading = true;
                  });

                  // creating a room
                  var ref = await Database().createRoom(
                      userData: Get.put(UserController()).user,
                      topic: "",
                      type: "private",
                      context: context,
                      users: [users[index]]);


                    await Permission.microphone.request();
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: globalScaffoldKey.currentContext,
                      builder: (rc) {
                        return RoomScreen(
                          roomid: ref,
                        );
                      },
                    );


                  // if (mounted)
                  setState(() {
                    loading = false;
                  });
                },
              );
            },
            itemCount: users.length,
          );
        });
  }
}
