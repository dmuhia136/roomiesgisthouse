import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/home/follower_page.dart';
import 'package:gisthouse/pages/home/screen_holder.dart';
import 'package:gisthouse/pages/home/search_view.dart';
import 'package:gisthouse/pages/onboarding/invite_only.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/pages/room/lounge_screen.dart';
import 'package:gisthouse/services/authenticate.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/services/dynamic_link_service.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  bool joinroom;
  bool paidroom;
  String roomid;
  Room room;

  HomePage({this.joinroom, this.paidroom, this.room, this.roomid});

  @override
  _HomePageState createState() => _HomePageState();
}

PageController pageController = PageController(
  initialPage: 1,
  keepPage: true,
);

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  var screenFromNotification;
  AppLifecycleState _lastLifecycleState;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Database.updateProfileData(Get.find<UserController>().user.uid, {
      "online": true,
    });
    // updatesCheck();

    enableAudio();

    // clubRef.get().then((value){
    //   List<Club> clubs = value.docs.map((e) => Club.fromJson(e)).toList();
    //   clubs.forEach((club) {
    //     club.members.forEach((member) {
    //       Database.updateProfileData(member, {
    //         "joinedclubs": FieldValue.arrayUnion([club.id])
    //       });
    //     });
    //   });
    // });

    //change followers and following from user object to sub collection
    // changeFollowersandFollowingtoSub();
  }

  enableAudio() async {
    try {
      await Permission.microphone.request();
    } catch (e) {}
  }

  Future handleStartUpLogic() async {
    // call handle dynamic links
    await DynamicLinkService().handleDynamicLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    _lastLifecycleState = state;
    // Database.checkVerified(Get.find<UserController>().user);
    if (state == AppLifecycleState.resumed) {
      Database.updateProfileData(Get.find<UserController>().user.uid, {
        "online": true,
      });
      handleStartUpLogic();
    }
    if (state == AppLifecycleState.paused) {
      Database.updateProfileData(Get.find<UserController>().user.uid, {
        "online": false,
        "lastAccessTime": DateTime.now().microsecondsSinceEpoch,
      });
    }
    if (Get.find<UserController>().user.deviceid == null ||
        Get.find<UserController>().user.deviceid == "") {
      Database.updateProfileData(Get.find<UserController>().user.uid, {
        "deviceid": Get.find<UserController>().user.deviceid == null ||
                Get.find<UserController>().user.deviceid == ""
            ? await Database.getDeviceDetails()
            : Get.find<UserController>().user.deviceid,
      });
    }
  }

  updatesCheck() async {
    //if account has an issue, logout automatically
    if (FirebaseAuth.instance.currentUser != null) {
      var userFromApi =
          await UserApi().getUserById(FirebaseAuth.instance.currentUser.uid);

      if (userFromApi['firstname'] == null) {
        AuthService().signOut();
      } else {
        UserModel userModel = UserModel.fromJson(userFromApi);
        if (userModel.enabled == false) {
          Get.offAll(InviteOnly());
        }
        if (userModel.deviceid != null &&
            userModel.deviceid.isNotEmpty &&
            userModel.deviceid != await Database.getDeviceDetails()) {
          AuthService().signOut();
        }
      }
    }

    settingsRef.snapshots().listen((event) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String code = packageInfo.buildNumber;
      if (int.parse(code) == event.docs[0].data()["version"]) {
        Database.updateProfileData(FirebaseAuth.instance.currentUser.uid,
            {"appversion": "${int.parse(code)}"});
      }
      if (event.docs.length > 0) {
        if (event.docs[0].data()["alerttypeaws"] == "infoaws") {
          var alert = new CupertinoAlertDialog(
            title: new Text('Sorry'),
            content: new Text(
              event.docs[0].data()["alertinfomsgaws"],
              style: TextStyle(fontSize: 18),
            ),
          );
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  // <-- Prevents dialog dismiss on press of back button.
                  child: alert));
        } else if (event.docs[0].data()["alerttype"] == "info") {
          var alert = new CupertinoAlertDialog(
            title: new Text(''),
            content: new Text(
              event.docs[0].data()["alertinfomsg"],
              style: TextStyle(fontSize: 18),
            ),
          );
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  // <-- Prevents dialog dismiss on press of back button.
                  child: alert));
        } else if (event.docs[0].data()["alerttype"] == "update") {
          if (int.parse(code) < event.docs[0].data()["version"] &&
              Platform.isAndroid) {
            var alert = new CupertinoAlertDialog(
              title: new Text('Update!'),
              content: new Text(event.docs[0].data()["alertupdatemsg"]),
              actions: <Widget>[
                new CupertinoDialogAction(
                    child: const Text('Update Now'),
                    onPressed: () async {
                      Navigator.pop(context);

                      String url = "";
                      if (Platform.isAndroid) {
                        // Android-specific code
                        url = playstoreUrl;
                      } else if (Platform.isIOS) {
                        // iOS-specific code
                      }
                      if (await canLaunch(url))
                        await launch(url);
                      else
                        // can't launch url, there is some error
                        throw "Could not launch $url";
                      // Navigator.pop(context);
                    }),
                if (event.docs[0].data()["forced"] == false)
                  new CupertinoDialogAction(
                      child: const Text('Maybe Later'),
                      isDefaultAction: true,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
              ],
            );

            showDialog(
                barrierDismissible: !event.docs[0].data()["forced"],
                context: context,
                builder: (context) => WillPopScope(
                    onWillPop: () async => false,
                    // <-- Prevents dialog dismiss on press of back button.
                    child: alert));
          }
        }
      }
    });
    //Check if user is blocked from the application
    if (Get.find<UserController>().user.enabled == false) {
      blockCheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetX<UserController>(initState: (_) async {
      Get.find<UserController>().user =
          await Database.getUserProfile(FirebaseAuth.instance.currentUser.uid);
    }, builder: (_) {
      if (_.user == null) {
        return Scaffold(
          body: Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }
      return ScreenHolder(
        color: Style.themeColor,
        scaffoldKey: _scaffoldKey,
        body: Container(
          decoration: BoxDecoration(color: Style.LightBrown),
          child: Column(
            children: [
              SizedBox(
                height: 45,
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                child: HomeAppBar(
                  profile: _.user,
                  onProfileTab: () {
                    Get.to(() => ProfilePage(
                          profile: _.user,
                          fromRoom: false,
                          isMe:
                              _.user.uid == Get.find<UserController>().user.uid,
                        ));
                  },
                ),
              ),
//home page search bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.to(() => SearchView());
                      },
                      child: Container(
                          margin: EdgeInsets.only(left: 15, top: 20, right: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 3.0),
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Get.to(() => SearchView());
                                    },
                                    icon: Icon(Icons.search,
                                        color: Style.BlackFade
                                    )),
                                Text("Find people and clubs",
                                style: TextStyle(fontSize: 18.0,
                                color: Style.BlackFade
                                ),
                                ),
                              ],
                            ),
                          )
//
//                         TextField(
//                             style: TextStyle(
//                               fontSize: 16.0,
//                               color: Colors.black,
//                             ),
//                             decoration: InputDecoration(
//                                 contentPadding:
//                                     EdgeInsets.fromLTRB(8.0, 13.0, 8.0, 8.0),
//
// //search Icon
//                                 prefixIcon:
//                                     Icon(Icons.search, color: Colors.black54),
//                                 hintText: "Find People and Clubs",
//                                 border: InputBorder.none,
//                                 focusedBorder: InputBorder.none,
//                                 enabledBorder: InputBorder.none,
//                                 hintStyle: TextStyle(color: Colors.black54))),
                          ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: PageView(
                  controller: pageController,
                  children: [
                    //followers page
                    FollowerPage(),
                    //rooms list page
                    RommiesScreen()
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void blockCheck() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
            onWillPop: () async => false,
            // <-- Prevents dialog dismiss on press of back button.
            child: new CupertinoAlertDialog(
              title: new Text('Blocked!'),
              content: new Text(
                  'You have been blocked from the application.Contact admin for more details'),
            )));
  }
}
