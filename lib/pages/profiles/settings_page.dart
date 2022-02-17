import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/onboarding/deactivate_account.dart';
import 'package:gisthouse/pages/onboarding/verificatiion.dart';
import 'package:gisthouse/services/authenticate.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/firebase_refs.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/round_button.dart';
import 'package:gisthouse/widgets/round_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home/select_interests.dart';

//ignore: must_be_immutable
class SettingsPage extends StatefulWidget {
  UserModel profile;

  SettingsPage({this.profile});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pause = false;
  UserModel profile = Get.find<UserController>().user;
  StreamSubscription<DocumentSnapshot> userlistener;
  TextEditingController twitterController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController linkedInController = TextEditingController();

  String socialLinkError = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsersFromApi();
  }

  getUsersFromApi() async {
    var user = await UserApi().getUserById(profile.uid);

    profile = UserModel.fromJson(user);
    pause = profile.pausenotifications;
    twitterController.text = profile.twitter;
    instagramController.text = profile.instagram;
    facebookController.text = profile.facebook;
    linkedInController.text = profile.linkedIn;

    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
//    userlistener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.themeColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(right: 20.0, left: 20.0, bottom: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Stack(
                  children: [
//Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.keyboard_arrow_left, color: Colors.black,
                          size:  40.0,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "Settings",
                              style: TextStyle(fontSize: 25, color: Colors.black,
                              letterSpacing: 0.7
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          accountSheet();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
//profile details
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 20),
                                  child: RoundImage(
                                    url: widget.profile.smallimage,
                                    txtsize: 20,
                                    txt: widget.profile.firstname,
                                    width: 50,
                                    height: 50,
                                    borderRadius: 15,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.profile.getName(),
                                      style: (TextStyle(
                                          fontSize: 16,
                                          color: Colors.black)),
                                    ),
                                    Text(
                                      widget.profile.username,
                                      style: (TextStyle(
                                          fontSize: 13,
                                          color: Colors.black)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 30,
                              color: Colors.black54,
                            )
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   height: 8,
                      // ),
                      // Divider(),
                      // SizedBox(
                      //   height: 8,
                      // ),
                      // InkWell(
                      //   onTap: () {
                      //           Get.to(() => Verificatio());
                      //         },
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Column(
                      //         mainAxisAlignment: MainAxisAlignment.start,
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //             widget.profile.email == null ? 'Add email' : widget.profile.email,
                      //             style: (TextStyle(
                      //                 fontSize: 16, color: Style.AccentBrown)),
                      //           ),
                      //           // Text(
                      //           //   widget.profile.emailverified == true
                      //           //       ? "Verified"
                      //           //       : "Unverifed, Verify Now",
                      //           //   style: (TextStyle(
                      //           //       fontSize: 13,
                      //           //       color: widget.profile.emailverified == true
                      //           //           ? Colors.green
                      //           //           : Colors.red)),
                      //           // )
                      //         ],
                      //       ),
                      //       // Icon(
                      //       //   Icons.keyboard_arrow_right_rounded,
                      //       //   size: 30,
                      //       //   color: Colors.grey,
                      //       // )
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
//Twitter Inkwell
                      InkWell(
                        onTap: () {
                          setSocialLink('twitter');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Twitter",
                              style: (TextStyle(
                                  fontSize: 16, color: Colors.black)),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 30,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
//Instagram inkwell
                      InkWell(
                        onTap: () {
                          setSocialLink('instagram');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Instagram",
                              style: (TextStyle(
                                  fontSize: 16, color: Colors.black)),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 30,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey
                      ),
//facebook inkwell
                      InkWell(
                        onTap: () {
                          setSocialLink('facebook');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Facebook",
                              style: (TextStyle(
                                  fontSize: 16, color: Colors.black)),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 30,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey
                      ),
//LinkedIn Inkwell
                      InkWell(
                        onTap: () {
                          setSocialLink('linkedin');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "LinkedIn",
                              style: (TextStyle(
                                  fontSize: 16, color: Colors.black)),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 30,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                /*SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Pause Notifications",
                            style: (TextStyle(
                                fontSize: 16, color: Style.AccentBrown)),
                          ),
                          CupertinoSwitch(
                            value: profile.pausenotifications,
                            onChanged: (value) {
                              setState(() {
                                pause = !pause;
                                profile.pausenotifications = pause;
                              });
                              if (pause == true) {
                                notificationActionSheet();
                              } else {
                                Database.updateProfileData(profile.uid, {
                                  "pausenotifications": false,
                                });
                              }
                            },
                          )
                        ],
                      ),
                      // Divider(),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       "Send Fewer Notifications",
                      //       style: (TextStyle(fontSize: 16)),
                      //     ),
                      //     CupertinoSwitch(
                      //       value: profile.sendfewernotifications,
                      //       onChanged: (value) {
                      //         profile.sendfewernotifications = value;
                      //         Database.updateProfileData(profile.uid, {
                      //           "sendfewernotifications": value
                      //         });
                      //       },
                      //     )
                      //   ],
                      // ),
                      Divider(),
                      InkWell(
                        onTap: () {
                          notificationSettingsBottomSheet();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Notification Settings",
                              style: (TextStyle(
                                  fontSize: 16, color: Style.AccentBrown)),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      profile.membership == 1
                          ? InkWell(
                              onTap: () {
                                notificationSettingsBottomSheet();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Auto renew upgrade?",
                                    style: (TextStyle(
                                        fontSize: 16, color: Style.AccentBrown)),
                                  ),
                                  Switch(
                                    value: profile.renewUpgrade,
                                    onChanged: (value) {
                                      profile.renewUpgrade = value;
                                      Database.updateProfileData(
                                          profile.uid, {"renewUpgrade": value});
                                      Get.find<UserController>()
                                          .user
                                          .renewUpgrade = value;
                                      setState(() {});
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),*/
                SizedBox(
                  height: 30,
                ),
//Interests Inkwell
                InkWell(
                  onTap: () {
                    Get.to(() => InterestsPick());
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Interests",
                          style:
                              (TextStyle(fontSize: 16, color: Colors.black)),
                        ),
                        Row(
                          children: [
                            Text(
                              Get.find<UserController>()
                                  .user
                                  .interests
                                  .length
                                  .toString(),
                              style: (TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              )),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 30,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
// final container
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white),
                  child: Column(
                    children: [
//whats new inkwell
                      InkWell(
                        onTap: () async {
                          if (await canLaunch("https://gisthouse.com/whatsnew"))
                            await launch("https://gisthouse.com/whatsnew");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "What's New",
                                style: (TextStyle(
                                    fontSize: 16, color: Colors.black)),
                              ),
                              Icon(
                                CupertinoIcons.arrow_up_right,
                                size: 20,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey
                      ),
//FAQ/ Contact Inkwell
                      InkWell(
                        onTap: () async {
                          if (await canLaunch("http://www.gisthouse.com/faq"))
                            await launch("http://www.gisthouse.com/faq");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "FAQ / Contact Us",
                                style: (TextStyle(
                                    fontSize: 16, color: Colors.black)),
                              ),
                              Icon(
                                CupertinoIcons.arrow_up_right,
                                size: 20,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey
                      ),
//Community guidelines Inkwell
                      InkWell(
                        onTap: () async {
                          if (await canLaunch(
                              "https://gisthouse.com/guidelines/"))
                            await launch("https://gisthouse.com/guidelines/");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Community Guidelines",
                                style: (TextStyle(
                                    fontSize: 16, color: Colors.black)),
                              ),
                              Icon(
                                CupertinoIcons.arrow_up_right,
                                size: 20,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      InkWell(
                        onTap: () async {
                          if (await canLaunch(
                              "https://gisthouse.com/terms-and-conditions"))
                            await launch(
                                "https://gisthouse.com/terms-and-conditions");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Terms of Service",
                                style: (TextStyle(
                                    fontSize: 16, color: Colors.black)),
                              ),
                              Icon(
                                CupertinoIcons.arrow_up_right,
                                size: 20,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey
                      ),
//privacy policy inkwell
                      InkWell(
                        onTap: () async {
                          if (await canLaunch(
                              "https://gisthouse.com/privacy-policy"))
                            await launch("https://gisthouse.com/privacy-policy");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Privacy Policy",
                                style: (TextStyle(
                                    fontSize: 16, color: Colors.black)),
                              ),
                              Icon(
                                CupertinoIcons.arrow_up_right,
                                size: 20,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
//Log out inkwell
                InkWell(
                  onTap: () {
                    AuthService().signOut();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Log out",
                            style: (TextStyle(fontSize: 18, color: Colors.red,
                            letterSpacing: 0.7
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

/*
    notification settings bottom sheet
 */
  notificationActionSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
          title: Text('Pause Notifications'),
          actions: [
            CupertinoActionSheetAction(
              child: const Text('For an Hour', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Database.updateProfileData(profile.uid, {
                  "pausedtime": DateTime.now().microsecondsSinceEpoch,
                  "pausenotifications": true,
                  "pausedtype": "hour"
                });
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Until this Evening',
                  style: TextStyle(fontSize: 16)),
              onPressed: () {
                var timeNow = DateTime.now().hour;
                Database.updateProfileData(profile.uid, {
                  "pausedtime": DateTime.now().microsecondsSinceEpoch,
                  "pausenotifications": true,
                  "pausedtype": "evening"
                });
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child:
                  const Text('Until Morning', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Database.updateProfileData(profile.uid, {
                  "pausedseconds": 3600 * 24,
                  "pausedtime": DateTime.now().microsecondsSinceEpoch,
                  "pausenotifications": true,
                  "pausedtype": "morning"
                });
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('For a Week', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Database.updateProfileData(profile.uid, {
                  "pausedtime": DateTime.now().microsecondsSinceEpoch,
                  "pausenotifications": true,
                  "pausedtype": "week"
                });
                Navigator.pop(context);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(
              'Cancel',
            ),
            onPressed: () {
              setState(() {
                pause = !pause;
              });
              Navigator.pop(context);
            },
          )),
    ).whenComplete(() {
      setState(() {
        pause = profile.pausenotifications;
      });
    });
  }

  /*
      connect to social accounts
   */
  accountSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Style.themeColor,

      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SafeArea(
            child: DraggableScrollableSheet(
                initialChildSize: 0.96,
                expand: false,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: Icon(Icons.arrow_back_ios,
                                  size: 40, color: Colors.black),
                            ),
                            Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                              "Account",
                              style: TextStyle(fontSize: 23, color: Colors.black,
                              letterSpacing: 0.5
                              ),
                            ),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        // Container(
                        //   padding:
                        //       EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        //   width: double.infinity,
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(10.0),
                        //       color: Colors.white),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Text(
                        //           "Connect Twitter",
                        //           style: (TextStyle(fontSize: 16, color: Style.AccentBrown)),
                        //         ),
                        //         Divider(),
                        //         Text(
                        //           "Connect Instagram",
                        //           style: (TextStyle(fontSize: 16, color: Style.AccentBrown)),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: 30,
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => DeactivateAccount());
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Deactivate Account",
                                    style: (TextStyle(
                                        fontSize: 18, color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                      letterSpacing: 0.7
                                    )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          );
        });
      },
    );
  }

  setSocialLink(String type) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Style.themeColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
              initialChildSize: 0.93,
              expand: false,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: Icon(Icons.arrow_back_ios,
                                size: 30, color: Colors.black),
                          ),
                          Center(
                              child: Text(
                            type,
                            style: TextStyle(fontSize: 21, color: Colors.black),
                          )),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Column(
                        children: [
//textfield
                          TextFormField(
                            controller: type == 'twitter'
                                ? twitterController
                                : type == 'instagram'
                                    ? instagramController
                                    : type == 'facebook'
                                        ? facebookController
                                        : linkedInController,
                            autocorrect: false,
                            decoration: InputDecoration(
                              fillColor: Colors.grey[300],
                              filled: true,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: 'Paste a link to your account',
                              hintStyle: TextStyle(
                                fontSize: 18,
                              ),
                              errorText: socialLinkError,
                            ),
                            keyboardType: TextInputType.url,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            height: 100,
                          ),
                          CustomButton(
                              text: "SAVE",
                              color: Style.Blue,
                              onPressed: () async {
                                var savedItem = type == 'twitter'
                                    ? twitterController.text
                                    : type == 'instagram'
                                    ? instagramController.text
                                    : type == 'facebook'
                                    ? facebookController.text
                                    : linkedInController.text;

                                if(Uri.parse(savedItem).host != '' ) {

                                  await UserApi().updateUser({type: savedItem}, widget.profile.uid);
                                  Functions.debug(savedItem + type + widget.profile.uid);
                                  Navigator.pop(context);
                                  type == 'twitter'
                                      ? twitterController.text = ""
                                      : type == 'instagram'
                                      ? instagramController.text = ""
                                      : type == 'facebook'
                                      ? facebookController.text = ""
                                      : linkedInController.text = "";
                                  socialLinkError = "";
                                  setState((){});
                                } else
                                  {
                                    socialLinkError = "Link not correct";
                                    setState((){});

                                  }
                              })
                        ],
                      ),

                    ],
                  ),
                );
              });
        });
      },
    );
  }

  checkIfLinkIsCorrect(link){
    if(Uri.parse(link).isAbsolute){
      return "Link incorrect";
    }
  }

  /*
    room notification settings

   */

  notificationSettingsBottomSheet() {
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
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: Icon(Icons.arrow_back_ios,
                                size: 30, color: Colors.grey),
                          ),
                          Expanded(
                            child: Center(
                                child: Text(
                              "NOTIFICATION SETTINGS",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Room Notifications",
                                          style: (TextStyle(
                                              fontSize: 16,
                                              color: Style.AccentBrown)),
                                        ),
                                        Text(
                                          "When followers speak, start rooms etc",
                                          style: (TextStyle(
                                              fontSize: 12,
                                              color: Style.AccentBrown)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: profile.subroomtopic,
                                    onChanged: (value) {
                                      if (value == true) {
                                        FirebaseMessaging.instance
                                            .subscribeToTopic(roomtopic);
                                      } else {
                                        FirebaseMessaging.instance
                                            .unsubscribeFromTopic(roomtopic);
                                      }
                                      setState(() {
                                        profile.subroomtopic = value;
                                      });
                                      Database.updateProfileData(
                                          profile.uid, {"subroomtopic": value});
                                    },
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Trend Notifications",
                                          style: (TextStyle(
                                              fontSize: 16,
                                              color: Style.AccentBrown)),
                                        ),
                                        Text(
                                          "Intersting Rooms, clubs etc",
                                          style: (TextStyle(
                                              fontSize: 12,
                                              color: Style.AccentBrown)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: profile.subtrend,
                                    onChanged: (value) {
                                      if (value == true) {
                                        FirebaseMessaging.instance
                                            .subscribeToTopic(trendingtopic);
                                      } else {
                                        FirebaseMessaging.instance
                                            .unsubscribeFromTopic(
                                                trendingtopic);
                                      }
                                      setState(() {
                                        profile.subtrend = value;
                                      });
                                      Database.updateProfileData(
                                          profile.uid, {"subtrend": value});
                                    },
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Other Notifications",
                                          style: (TextStyle(
                                              fontSize: 16,
                                              color: Style.AccentBrown)),
                                        ),
                                        Text(
                                          "New followers speak, events,clubs etc ",
                                          style: (TextStyle(
                                              fontSize: 12,
                                              color: Style.AccentBrown)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: profile.subothernot,
                                    onChanged: (value) {
                                      if (value == true) {
                                        FirebaseMessaging.instance
                                            .subscribeToTopic(otherstopic);
                                      } else {
                                        FirebaseMessaging.instance
                                            .unsubscribeFromTopic(otherstopic);
                                      }
                                      setState(() {
                                        profile.subothernot = value;
                                      });
                                      Database.updateProfileData(
                                          profile.uid, {"subothernot": value});
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
      },
    );
  }
}
