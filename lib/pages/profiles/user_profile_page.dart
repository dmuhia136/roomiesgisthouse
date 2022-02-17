import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/chats/chat_screen.dart';
import 'package:gisthouse/pages/clubs/new_club.dart';
import 'package:gisthouse/pages/clubs/view_club.dart';
import 'package:gisthouse/pages/onboarding/verificatiion.dart';
import 'package:gisthouse/pages/profiles/another_profile.dart';
import 'package:gisthouse/pages/profiles/settings_page.dart';
import 'package:gisthouse/pages/profiles/user_content.dart';
import 'package:gisthouse/pages/profiles/widgets/user_actions.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/services/dynamic_link_service.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

import '../../widgets/upgrade_account_sheet.dart';

class ProfilePage extends StatefulWidget {
  UserModel profile;
  final String userid;
  final bool isMe;
  final bool fromRoom;

  ProfilePage({this.profile, this.isMe, this.fromRoom, this.userid});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  UserModel userModel = Get
      .find<UserController>()
      .user;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  var emailToVerify = TextEditingController();
  bool _success;
  String _userEmail;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfileData();

    WidgetsBinding.instance.addObserver(this);
  }

  getProfileData() async {
    if(widget.profile == null){

      loading = true;
      setState(() {});

      var currentUser = await UserApi().getUserById(widget.userid);

        widget.profile = UserModel.fromJson(currentUser);
        loading = false;
        setState(() {});
    } else {
      loading = true;
      setState(() {});

      var profileUser = await UserApi().getUserById(widget.profile.uid);

        widget.profile = UserModel.fromJson(profileUser);
        loading = false;
        if(mounted)setState(() {});

    }

    // widget.profile.referrerid = 'p3tdjc7NbAZTLSkcXVHzfVGBqxE3';

  }

  @override
  void dispose() {
    // Remove the observer
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        // widget is resumed
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        break;
      case AppLifecycleState.paused:
        // widget is paused
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Widget buildForm() {
    return Column(
      children: [
        Container(
          width: 330,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Form(
                  child: TextFormField(
                    controller: _emailController,
                    autocorrect: false,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      hintStyle: TextStyle(
                        fontSize: 16,
                      ),
                      // border: InputBorder.none,
                      // focusedBorder: InputBorder.none,
                      // enabledBorder: InputBorder.none,
                      // errorBorder: InputBorder.none,
                      // disabledBorder: InputBorder.none,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: 330,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Form(
                  child: TextFormField(
                    controller: _passwordController,
                    autocorrect: false,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        fontSize: 16,
                      ),
                      // border: InputBorder.none,
                      // focusedBorder: InputBorder.none,
                      // enabledBorder: InputBorder.none,
                      // errorBorder: InputBorder.none,
                      // disabledBorder: InputBorder.none,
                    ),
                    obscureText: true,
                    enableSuggestions: false,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _success == null
                ? ''
                : (_success
                ? 'Successfully signed in ' + _userEmail
                : 'Sign in failed'),
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(

      child: loading == true
          ? Container(
        child: CupertinoActivityIndicator(),
      )
          : Scaffold(
        appBar: AppBar(
          backgroundColor: Style.LightBrown,
          automaticallyImplyLeading: false,
            elevation: 2,
          toolbarHeight: 80,

//app bar widgets
          title: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
//drop page icon
                InkWell(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      size: 40,
                      color: Colors.black,
                    )),
                Row(
                  children: [
                    if (widget.profile.uid == userModel.uid &&
                        (widget.profile.email == null ||
                            widget.profile.email.isEmpty))
//email icon
                      InkWell(
                        onTap: () => Get.to(() => Verificatio()),
                        child: Icon(
                          Icons.alternate_email,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    SizedBox(
                      width: 30,
                    ),
//share Icon
                    InkWell(
                      onTap: () {
                        final RenderBox box = context.findRenderObject();
                        DynamicLinkService()
                            .createGroupJoinLink(
                            widget.profile.username, "profile")
                            .then((value) async {
                          await Share.share(value,
                              subject: "Check " +
                                  widget.profile.getName() +
                                  " Profile",
                              sharePositionOrigin:
                              box.localToGlobal(Offset.zero) &
                              box.size);
                        });
                      },
                      child: Icon(
                        Icons.share,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
//settings Icons
                    SizedBox(width: 30,),
                    InkWell(
                      onTap: () =>
                          widget.profile.uid != Get.find<UserController>().user.uid
                              ? userActionSheet(context,
                                  userModel: userModel,
                                  profile: widget.profile,
                                  fromRoom: false)
                              : Get.to(() => SettingsPage(
                                    profile: userModel,
                                  )),
                      child: Icon(
                        Icons.settings,
                        color: Colors.black,
                        size: 35,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        backgroundColor: Style.LightBrown,
        body: ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: [
            //0726423179
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20
                  ),
                  child: UserContent(widget.profile,
                      isTwoLineDescription: false, isMe: widget.isMe),
                ),
                // SocialGrid(speaker),

                if (widget.profile != null)
                  Container(
                      height: widget.profile.referrerid != null ? 80 : 0,
                      child: _buildReferrer()),
                if (widget.profile != null)
                  Container(
                    child: myClubs(),
                  ),
                SizedBox(
                  height: 25,
                ),
                if (widget.profile != null &&
                    widget.profile.uid != userModel.uid)
//bottom part
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(

                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomButton(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 13, horizontal: 60),
                                  color: Colors.grey[300],
                                  txtcolor: Colors.black,
                                  child: const Text('Message',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontFamily: "LucidaGrande")),

                                  onPressed: () {
                                    Get.to(() =>
                                        ChatPage(
                                            chatusers: [widget.profile],
                                            messagetype: Database.getMessageChatType(
                                                widget.profile.uid)));
                                  },
                                ),
                              ),


                            ],
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {

                            if (Get
                                .find<UserController>()
                                .user
                                .coinsEnabled ==
                                true) {
                              Functions
                                  .depositAmount(
                                  context, "send", gccurrency,
                                  userModel: widget.profile,
                                  onButtonPressed: (type, amount) async {
                                    Navigator.pop(context);
                                    Database().sendMoney(
                                        widget.profile, amount, gccurrency);
                                  });
                            } else {
                              blockCheck();
                            }
                          },

                          child: Text("Gift GistCoin",
                            style: TextStyle (
                                color: Style.Blue,
                                fontSize: 18
                            ),
                          )

                      )
                    ],
                  ),
                // Spacer(),
                if (widget.profile != null &&
                    widget.profile.uid == userModel.uid &&
                    widget.profile.premiumMember() == false)
                  buildCurrentPlan(context),
                // Spacer(),
              ],
            )

          ],
        ),
      ),
    );
  }

  void blockCheck() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
            onWillPop: () async => false,
            // <-- Prevents dialog dismiss on press of back button.
            child: new CupertinoAlertDialog(
              title: new Text('Wallet Access Denied!'),
              content: new Text(
                  'You have been blocked from accessing your wallet. Contact Admin for more details'),
              actions: <Widget>[
                new CupertinoDialogAction(
                    child: const Text('Okay'),
                    onPressed: () async {
                      Navigator.pop(context);
                    }),
              ],
            )));
  }


  Widget _buildReferrer() {
    return FutureBuilder(
        future: Database.getUserProfile(widget.profile.referrerid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingWidget(context);
          }
          if (!snapshot.hasData) {
            return Container();
          }
          UserModel userModel = snapshot.data;
          return InkWell(
            onTap: () {
              //Navigator.pop(context);
              print('Go to referer');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnotherProfile(widget.profile.referrerid)),
              );


            },
            child: Column(
              children: [
                Divider(),
                Expanded(
                  child: Container(
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RoundImage(
                            url: userModel.smallimage,
                            txt: userModel.username,
                            width: 40,
                            height: 40,
                            txtsize: 12,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    "Joined " +
                                        DateFormat("MMM d, yyyy ").format(
                                            DateTime.fromMicrosecondsSinceEpoch(
                                                widget.profile.membersince)),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "LucidaGrande"),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Referred by ${userModel.username}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "LucidaGrande"),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  List<Club> club = [];

  Widget myClubs() {
    return FutureBuilder(
        future: Database.getMyClubs(widget.profile.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
          }
          if (!snapshot.hasData ||
              snapshot.data == null && widget.isMe == false) {
            if (widget.profile.uid == Get
                .find<UserController>()
                .user
                .uid) {
              club.add(Club(id: "0"));
            }
          }
          if (snapshot.hasData || club.length > 0) {
            if (snapshot.hasData) {
              club = snapshot.data;
              if (widget.profile.uid == Get
                  .find<UserController>()
                  .user
                  .uid) {
                club.add(Club(id: "0"));
              }
            }

            return club.length == 0
                ? Container()
                : Container(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(
                    height: 15,
                  ),
//member of
                  Text(
                    "Member of",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: "LucidaGrande"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 40,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: club
                                .map((e) =>
                            e.id == "0"
                                ? InkWell(
                              onTap: () {
                                if (userModel.clubs.length >= 30) {
                                  topTrayPopup(
                                      "You can only add 3 clubs");
                                } else {
                                  Get.to(() => NewClub());
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(15),
                                    color: Colors.grey[300]),
                                child: Center(
                                    child: Text(
                                      "+",
                                      style: TextStyle(fontSize: 20),
                                    )),
                              ),
                            )
                                : Container(
                              width: 40,
                              height: 40,
                              margin: EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () {
                                  Get.to(() =>
                                      ViewClub(
                                        club: e,
                                      ));
                                },
                                child: RoundImage(
                                  url: e.imageurl,
                                  width: 40,
                                  height: 40,
                                  borderRadius: 10,
                                  txt: e.title,
                                  txtsize: 13,
                                ),
                              ),
                            ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Widget buildCurrentPlan(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () {
          if (widget.profile.membership != 1)
            upgradeToPremium(context, widget.profile);
        },
        child: Container(
          alignment: FractionalOffset.bottomCenter,
          padding: EdgeInsets.only(bottom: 20),
          child: Card(
            color: Style.Blue,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    widget.profile.membership == 1
                        ? "Current Plan is Premium"
                        : "Upgrade to premium",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
