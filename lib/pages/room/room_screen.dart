import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/anylinks/ui/link_view_horizontal.dart';
import 'package:gisthouse/anylinks/web_analyzer.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/models/room_user.dart';
import 'package:gisthouse/pages/chats/chats_screen.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/pages/profiles/widgets/user_profile_image.dart';
import 'package:gisthouse/pages/room/room_pinnedlink.dart';
import 'package:gisthouse/pages/room/search_room_users.dart';
import 'package:gisthouse/pages/room/widgets/room_profile.dart';
import 'package:gisthouse/pages/room/widgets/text_with_show_more.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/ongoingroom_api.dart';
import 'package:gisthouse/services/dynamic_link_service.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:gisthouse/util/firebase_refs.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/database.dart';
import '../../widgets/upgrade_account_sheet.dart';
import 'room_sponsors.dart';

RtcEngine engine;

/*
    class to manage rooms
    all room functionality is held here
 */
class RoomScreen extends StatefulWidget {
  final String roomid;
  final bool exists;
  final Function endroomcallback;

  const RoomScreen({Key key, this.roomid, this.exists, this.endroomcallback})
      : super(key: key);

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  UserModel myProfile = Get.put(UserController()).user;
  bool waitinguser = false, loading = false;
  Room room;
  String currentUserType = "", error = "";
  List<RoomUser> otherusers = [];
  List<RoomUser> raisedhandsusers = [];
  List<RoomUser> _tempListOfUsers = [];
  List<RoomUser> speakerusers = [];
  List<RoomUser> allusers = [];

  AnimationController _animationController;
  Animation _colorTween;
  int index = -2;
  var mycalluid = 0;
  bool reverse = false;
  StreamSubscription<DocumentSnapshot> roomlistener;
  StreamSubscription<QuerySnapshot> userslistener;
  final TextEditingController textController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _animationController.dispose();
    if (roomlistener != null) {
      roomlistener.cancel();
      //userslistener.cancel();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  sponsorCallBack(String sponsors) {
    Database.updateRoomData(room.roomid, {"sponsors": sponsors});
    setState(() {});
  }

  pinnedlinkCallback(String pinnedurl) {
    Database.updateRoomData(room.roomid, {"pinnedurl": pinnedurl});
    _url = "https://" + pinnedurl;
    _getInfo(_url);
    setState(() {});
  }

  void init() async {
    engine = await RtcEngine.create(APP_ID.trim());

    //wait for room to be generated
    setState(() {
      waitinguser = true;
    });
    //defining ring around the active user speaking
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _colorTween = ColorTween(begin: Colors.white, end: Colors.transparent)
        .animate(_animationController);
    getRoomDetails();
    _errorTitle = "Something went wrong!";
    _errorBody =
        "Oops! Unable to parse the url. We have sent feedback to our developers & we will try to fix this in our next release. Thanks!";
  }

  getRoomDetails() async {
    loading = true;
    var roomFromApi = await Database().getRoomDetails(widget.roomid);

    if (roomFromApi != null) {
      room = roomFromApi;
      if (room.activemoderators.length == 0) {
        Get.back();
        topTrayPopup("Room does not exists");
        Get.find<CurrentRoomController>().room = null;
      } else {
        roomUsersListeners();
        roomListeners();
        initialize();
      }
      setState(() {});
      loading = false;
    } else {
      Get.back();
      topTrayPopup("Room doesnt exists");
      Get.find<CurrentRoomController>().room = null;
    }
  }

  checkUserExistsInRoom() {
    return allusers.indexWhere((element) => element.uid == myProfile.uid) != -1;
  }

  removeUserFromRoomScreen(RtcEngine engine) {
    Get.back();
    //notify user when room has been deleted
    topTrayPopup("Room has ended");
    Functions.leaveEngine();
    Get.find<CurrentRoomController>().room = null;
  }

  //room listeners
  roomListeners() {
    //start listening for changes in the room
    roomlistener =
        roomsRef.doc(widget.roomid).snapshots().listen((event) async {
      //check if room exiss
      if (event.exists == false &&
          room.ownerid != myProfile.uid &&
          checkUserExistsInRoom()) {
        removeUserFromRoomScreen(engine);
      } else {
        //update room variables and re-generate room object
        try {
          // mute users
          room = Room.fromJson(event.data());
          room.roomid = event.id;
          Get.find<CurrentRoomController>().room = room;
          // POPULATE USERS WHO HAVE RAISED THEIR HANDS
          populateraisedHandsusers();
          //check if i have been invited
          populateUsersInvited();
          moderatorAlert();

          if (room.pinnedurl != null && room.pinnedurl.isNotEmpty) {
            _url = "https://" + room.pinnedurl;
            _getInfo("https://" + room.pinnedurl);
          }

          setState(() {});
        } catch (e) {}
      }
    });
  }

  void moderatorAlert() {
    if (room.invitedasmoderator.length > 0) {
      if (room.invitedasmoderator.contains(myProfile.uid)) {
        room.invitedasmoderator.remove(myProfile.uid);

        OngoingRoomApi().removeRaisedHands(myProfile.uid, room.roomid);

        OngoingRoomApi()
            .removeFromInvitedModeratorsRoom(room.roomid, myProfile.uid);

        OngoingRoomApi().addToAllModeratorsRoom(room.roomid, myProfile.uid);

        OngoingRoomApi().addToActiveModeratorsRoom(room.roomid, myProfile.uid);

        playInvitedAudio();
        Get.snackbar(
          "",
          "",
          snackPosition: SnackPosition.TOP,
          borderRadius: 0,
          titleText: Text(
            "👋 you are now a moderator",
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontFamily: "InterBold"),
          ),
          margin: EdgeInsets.all(0),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
    }
  }

  Future<void> populateUsersInvited() async {
    if (room.invitedusers.length > 0) {
      if (room.invitedusers.contains(myProfile.uid)) {
        playInvitedAudio();
        Get.snackbar("", "",
            snackPosition: SnackPosition.TOP,
            borderRadius: 0,
            titleText: Text(
              "👋 you have been invited as a speaker",
              style: TextStyle(
                  fontSize: 16, color: Colors.black, fontFamily: "InterBold"),
            ),
            margin: EdgeInsets.all(0),
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 365),
            messageText: Container(
              margin: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    color: Colors.white70,
                    text: "Maybe later?",
                    txtcolor: Colors.black,
                    fontSize: 13,
                    onPressed: () {
                      OngoingRoomApi().removeFromInvitedUsersRoom(
                          room.roomid, myProfile.uid);

                      Get.back();
                    },
                  ),
                  CustomButton(
                    color: Colors.white,
                    text: "Join as a speaker",
                    txtcolor: Colors.green,
                    fontSize: 13,
                    onPressed: () async {
                      Get.back();

                      OngoingRoomApi().removeFromInvitedUsersRoom(
                          room.roomid, myProfile.uid);
                      //join as a speaker
                      await Database.joinSpeakers(
                          userid: myProfile.uid,
                          roomid: room.roomid,
                          engine: engine);
                      Functions().sendNotificationToSpeakerFollowers(
                          myProfile, widget.roomid);
                    },
                  )
                ],
              ),
            ));
      }
    }
  }

  playInvitedAudio() {
    AssetsAudioPlayer audioPlayer =
        AssetsAudioPlayer(); // this will create a instance object of a class
    audioPlayer.open(
      Audio('assets/sounds/invited_to_speaker.mp3'),
      autoStart: true,
    );
  }

  //room users listeners
  roomUsersListeners() async {
    //start listening for changes in the room
    userslistener = roomsRef
        .doc(widget.roomid)
        .collection("users")
        .orderBy("addedtime", descending: false)
        .snapshots()
        .listen((event) async {
      if (event != null) {
        allusers = event.docs.map((e) => RoomUser.fromJson(e.data())).toList();
        //update room variables and re-generate room object
        try {
          speakerusers.clear();
          otherusers.clear();
          _tempListOfUsers = allusers;
          if (allusers.length > 0) {
            index =
                allusers.indexWhere((element) => element.uid == myProfile.uid);
            if (index != -1) {
              currentUserType = allusers[index].usertype;
              engine.muteLocalAudioStream(allusers[index].callmute);
              if (allusers[index].callmute == true) {
                engine.setClientRole(ClientRole.Audience);
              } else {
                engine.setClientRole(ClientRole.Broadcaster);
              }
            }

            Get.find<CurrentRoomController>().roomusers = allusers;
            //check if i have been remove
            removeFromRoomAlert();

            var speakers = allusers.where((row) =>
                (row.usertype == "host") ||
                row.usertype == "moderator" ||
                row.usertype == "speaker");
            speakerusers.addAll(speakers);
            var others = allusers.where((row) => (row.usertype == "others"));
            otherusers.addAll(others);
            setState(() {
              waitinguser = false;
            });

            //Arrange speakers
            List<RoomUser> arrangedSpeakers = speakerusers;
            for (var a in speakerusers) {
              if (a.usertype == "moderator" || a.usertype == "host") {
                var index = room.allmoderators
                    .indexWhere((element) => element == a.uid);
                if (index != -1) {
                  arrangedSpeakers
                      .removeWhere((element) => element.uid == a.uid);
                  arrangedSpeakers.insert(index, a);
                }
              }
            }

            for (var a in speakerusers) {
              if (a.usertype == "speaker") {
                var index =
                    room.speakers.indexWhere((element) => element == a.uid);
                if (speakerusers
                    .where((element) => element.uid == a.uid)
                    .isEmpty) {
                  arrangedSpeakers
                      .removeWhere((element) => element.uid == a.uid);
                  arrangedSpeakers.insert(index, a);
                }
              }
            }

            speakerusers = arrangedSpeakers;
            setState(() {});
          }
        } catch (e) {}
      }
    });
  }

  Future<void> removeFromRoomAlert() async {
    if (room.removedusers.length > 0) {
      if (room.removedusers.contains(myProfile.uid)) {
        Get.back();
        Get.snackbar("", "",
            snackPosition: SnackPosition.TOP,
            borderRadius: 0,
            titleText: Text(
              "👋 you have been removed from the room",
              style: TextStyle(
                  fontSize: 16, color: Colors.white, fontFamily: "InterBold"),
            ),
            margin: EdgeInsets.all(0),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5));

        await Functions.leaveEngine();

        await OngoingRoomApi()
            .removeFromRemovedUsersRoom(room.roomid, myProfile.uid);
      }
    }
  }

  /// Create Agora SDK instance and initialize
  Future<void> initialize() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
  }

  //init agora sdk
  Future<void> _initAgoraRtcEngine() async {
    try {
      await engine.enableAudio();
      await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
      await engine.enableAudioVolumeIndication(500, 3, true);
      await engine.setDefaultAudioRoutetoSpeakerphone(true);
      if (widget.exists == false) {
        await engine.setClientRole(ClientRole.Broadcaster);
        await engine.joinChannel(room.token, widget.roomid, null, 0);
      }
    } catch (e) {}
  }

  //when user icon is clicked
  searchUserClickCallBack(RoomUser user) {
    Get.back();
    Get.to(() => ProfilePage(userid: user.uid, fromRoom: true));
  }

  /// Add Agora event handlers
  void _addAgoraEventHandlers() {
    engine.setEventHandler(RtcEngineEventHandler(error: (code) async {
      //delete rooms that has token expire
      if (code.toString() == "ErrorCode.TokenExpired" && APP_ENV_DEV == true) {
        Functions.deleteRoom(
            room: room,
            currentuser: myProfile,
            context: context,
            roomlistener: roomlistener);
        error = code.toString();
      }
    }, joinChannelSuccess: (channel, uid, elapsed) async {
      mycalluid = uid;
      if (room.ownerid == myProfile.uid) {
        await Database().addUserToRoom(
            room: room, user: myProfile, host: true, calleruid: uid);
      } else {
        await Database()
            .addUserToRoom(room: room, user: myProfile, calleruid: uid);
        // mute user microphone if he is not the host
        engine.muteLocalAudioStream(true);
      }
      //enabling phone loud speaker
      await engine.setEnableSpeakerphone(true);
    }, leaveChannel: (stats) {
      Get.find<CurrentRoomController>().room = null;
    }, userOffline: (uid, elapsed) {
      final info = 'userOffline: $uid';
      if (uid == mycalluid) {
        topTrayPopup("you have a poor connection");
      }
    }, audioVolumeIndication:
        (List<AudioVolumeInfo> speakers, int totalVolume) {
      if (totalVolume > 0) {
        writeToDbRoomActive();
        // speakers.forEach((eleme) {
        //   //CHECK IF SOUND IS FROM THE CURRENT USER
        //   int index;
        //   if (eleme.uid == 0) {
        //     index = speakerusers
        //         .indexWhere((element) => element.uid == myProfile.uid);
        //   } else {
        //     index = speakerusers
        //         .indexWhere((element) => eleme.uid == element.callerid);
        //   }
        //   if (index != -1) {
        //     speakerusers[index].valume = totalVolume;
        //     if (_animationController.status == AnimationStatus.completed) {
        //       _animationController.reverse();
        //     } else {
        //       _animationController.forward();
        //     }
        //   }
        // });
      }
    }));
  }

  //If the last time the activeTime field was updated was more or equal to 10 mins ago, then update it
  writeToDbRoomActive() async {
    var now = DateTime.now();

    if (room.activeTime != null) {
      var lastUpdated = DateTime.fromMicrosecondsSinceEpoch(room.activeTime);
      var duration = now.difference(lastUpdated);

      if (duration.inMinutes > ACTIVE_ROOM_UPDATE) {
        updateActiveTime(now);
      }
    } else {
      updateActiveTime(now);
    }
  }

  updateActiveTime(now) async {
    RoomUser currentUser =
        allusers.firstWhere((element) => element.uid == myProfile.uid);

    if (currentUser != null && currentUser == allusers[0]) {
      await OngoingRoomApi()
          .updateRoom({'activeTime': now.microsecondsSinceEpoch}, room.roomid);
    }
  }

  //refresh completed
  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  arrangeSpeakers() {
    getRoomDetails();
  }

  getSpeakers() {
    List<RoomUser> speakers = [];
    allusers.forEach((element) {
      if (element.usertype == "host") {
        speakers.add(element);
      }
    });
    allusers.forEach((element) {
      if (element.usertype == "moderator") {
        speakers.add(element);
      }
    });
    allusers.forEach((element) {
      if (element.usertype == "speaker") {
        speakers.add(element);
        setState(() {});
      }
    });
    allusers.forEach((element) {
      if (element.usertype == "others") {
        speakers.add(element);
        setState(() {});
      }
    });
    return speakers;
  }

  //handle on refresh
  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();

    allusers.sort((a, b) => b.usertype.compareTo(a.usertype));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
//room container
    return Container(
      color: Style.LightBrown,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: loading == true || room == null
              ? loadingWidget(context)
              : Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 30,
                                color: Colors.black,
                              ),
//gist lounge
                              Text(
                                'Gist Lounge',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
//profile image
                        Spacer(),
                        UserProfileImage(
                          user: myProfile,
                          width: 40,
                          height: 40,
                          txtsize: 16,
                          borderRadius: 20,
                        ),
                      ],
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        child: Stack(
                          children: [
                            SmartRefresher(
                              enablePullDown: true,
                              controller: _refreshController,
                              onRefresh: _onRefresh,
                              onLoading: _onLoading,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(
                                  bottom: 80,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildTitle(
                                      room,
                                      context,
                                    ),
                                    if (room != null &&
                                        room.pinnedurl.isNotEmpty)
                                      buildPinnedurl(),
                                    if (room != null &&
                                        room.sponsors.isNotEmpty)
                                      buildSponsor(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    buildSpeakers(speakerusers),
                                    if (otherusers.length > 0)
                                      buildOthers(otherusers),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: buildBottom(context, room, setState)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
// DM icon
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: Container(
          margin: EdgeInsets.only(bottom: 150),
          child: FloatingActionButton(
            onPressed: () {
              _gotochat();
            },
            child: const Icon(
              CupertinoIcons.paperplane_fill,
              color: Colors.black,
              size: 30,
            ),
            backgroundColor: Colors.white,
          ),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: new Padding(
        //     padding: new EdgeInsets.only(right: 20.0),
        //     child: new Stack(
        //       alignment: FractionalOffset.center,
        //       overflow: Overflow.visible,
        //       children: <Widget>[
        //         getScoreButton(),
        //         getClapButton(),
        //       ],
        //     )
        // ),
        // bottomSheet: buildBottom(context, room),
      ),
    );
  }

  //bottom part container
  //bottomsheet widget to control the room privacy
  Widget buildBottom(BuildContext context, Room room, StateSetter state) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (room.roomtype == "private" && room.ownerid == myProfile.uid)
            Column(
              children: [
                Divider(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "This is a closed room",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      InkWell(
                        onTap: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoActionSheet(
                                      title: Text("Who else can join?"),
                                      actions: [
                                        CupertinoActionSheetAction(
                                          child: const Text('Everyone',
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 16)),
                                          onPressed: () {
                                            Database.updateRoomData(room.roomid,
                                                {"roomtype": "public"});
                                            Navigator.pop(context);
                                          },
                                        ),
                                        // CupertinoActionSheetAction(
                                        //   child: const Text(
                                        //       'Followed by the host',
                                        //       style: TextStyle(
                                        //           color: Colors.blue,
                                        //           fontSize: 16)),
                                        //   onPressed: () {
                                        //     Navigator.pop(context);
                                        //   },
                                        // ),
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        child: Text(
                                          'Cancel',
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[200]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 10),
                            child: Text("Open it Up"),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  Get.back();
                  await Functions.leaveChannel(
                      room: room,
                      currentUser: myProfile,
                      context: context,
                      roomlistener: roomlistener,
                      usertype: currentUserType,
                      quit: false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: Style.AccentGreen,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "EXIT GIST ROOM",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              buildBottomNav(
                  raisedhandsusers: raisedhandsusers,
                  room: room,
                  context: context,
                  users: allusers,
                  engine: engine,
                  myProfile: myProfile),
            ],
          )
        ],
      ),
    );
  }

  //room time widget
  Widget buildTitle(Room room, BuildContext buildContext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: RoomTitle(
            room,
            context,
          ),
        ),
        Row(
          children: [
            Container(
              child: IconButton(
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                        actions: [
                          CupertinoActionSheetAction(
                            child: const Text('Share Room'),
                            onPressed: () {
                              final RenderBox box = context.findRenderObject();
                              DynamicLinkService()
                                  .createGroupJoinLink(room.roomid)
                                  .then((value) async {
                                Navigator.pop(context);
                                await Share.share(value,
                                    subject: "Join " + room.title,
                                    sharePositionOrigin:
                                        box.localToGlobal(Offset.zero) &
                                            box.size);
                              });
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: const Text('Search Room'),
                            onPressed: () {
                              Navigator.pop(context);
                              Get.to(() => SearchRoomUsers(
                                    users: allusers,
                                  ));
                            },
                          ),
                          if (room.ownerid == myProfile.uid)
                            CupertinoActionSheetAction(
                                child: const Text('Add Sponsor'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (myProfile.premiumMember() == false) {
                                    showPremiumAlert(buildContext,
                                        msg:
                                            "You need to be a premium member to add a Sponsor to your Gistroom",
                                        fontsize: 20,
                                        userModel: myProfile);
                                    return;
                                  }
                                  Get.to(() => RoomSponsors(
                                      sponsorClickBack: sponsorCallBack));
                                }),
                          if (room.ownerid == myProfile.uid)
                            CupertinoActionSheetAction(
                                child: const Text('Add Pinned Link'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (myProfile.premiumMember() == false) {
                                    showPremiumAlert(buildContext,
                                        msg:
                                            "You need to be a premium member to add a Pinned Link to your Gistroom",
                                        fontsize: 20,
                                        userModel: myProfile);
                                    return;
                                  }
                                  addPinnedLink(context);
                                })
                        ],
                        cancelButton: currentUserType != "host"
                            ? null
                            : CupertinoActionSheetAction(
                                child: Text(
                                  'End Room',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  showLeaveRoomAlert("End");
                                },
                              )),
                  );
                },
                iconSize: 30,
//...Icon
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                ),
              ),
            ),
            if (room.roomtype == "Closed")
              IconButton(
                  onPressed: () {}, iconSize: 25, icon: Icon(Icons.lock)),
          ],
        )
      ],
    );
  }

  void addPinnedLink(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Style.AccentBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15.0)),
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/images/bg.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom / 4),
                child: RoomPinnedLink(
                    pinnedlinkCallback: pinnedlinkCallback,
                    link: room.pinnedurl),
              ),
            ),
          );
        });
  }

  //speakers widget
  Widget buildSpeakers(List<RoomUser> users) {
    users.sort((a, b) => a.usertype.compareTo(b.usertype));

//speakers
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      // physics: ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        // crossAxisSpacing: 3,
        // mainAxisSpacing: 16,
        childAspectRatio: 0.83,
      ),
      itemCount: users.length,
      itemBuilder: (gc, index) {
        return RoomProfile(
          thisprofileuser: users[index],
          currentuser:
              allusers.indexWhere((element) => element.uid == myProfile.uid) !=
                      -1
                  ? allusers[allusers
                      .indexWhere((element) => element.uid == myProfile.uid)]
                  : null,
          bordercolor:
              users[index].callmute == false ? Colors.grey : Colors.transparent,
          room: room,
          size: 70,
          allusers: allusers,
          opacity: users[index].callmute == false ? 0.8 : 1,
        );
      },
    );
  }

  //other uses widget
  Widget buildOthers(List<RoomUser> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Other Gistees in the Room',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ),
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          // physics: ScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 4,
            mainAxisSpacing: 16,
            childAspectRatio: 0.63,
          ),
          itemCount: users.length,
          itemBuilder: (gc, index) {
            return RoomProfile(
              thisprofileuser: users[index],
              currentuser: allusers.indexWhere(
                          (element) => element.uid == myProfile.uid) ==
                      -1
                  ? null
                  : allusers[allusers
                      .indexWhere((element) => element.uid == myProfile.uid)],
              bordercolor:
                  users[index].valume > 0 && users[index].callmute == false
                      ? _colorTween.value
                      : Colors.white,
              room: room,
              size: 70,
              allusers: allusers,
            );
          },
        ),
      ],
    );
  }

  _gotochat() {
    Get.to(() => ChatsScreen());
  }

  void showLeaveRoomAlert(String leaveOrEndRoom) {
    showDialog(
        context: context,
        builder: (context) {
          return new CupertinoAlertDialog(
            title: new Text(
                leaveOrEndRoom == 'leave' ? 'Leave room?' : 'End room?'),
            content: new Text(leaveOrEndRoom == 'leave'
                ? 'Are you sure you want to leave the room?'
                : 'Are you sure you want to close this room?'),
            actions: <Widget>[
              leaveOrEndRoom == 'leave'
                  ? new CupertinoDialogAction(
                      child: new Text('Leave'),
                      onPressed: () async {
                        Navigator.pop(context);
                        Get.back();
                        engine = await RtcEngine.create(APP_ID.trim());
                        await Functions.leaveChannel(
                            room: room,
                            currentUser: myProfile,
                            context: context,
                            roomlistener: roomlistener,
                            quit: false);
                      })
                  : new CupertinoDialogAction(
                      child: new Text('End'),
                      onPressed: () async {
                        Navigator.pop(context);
                        Functions.quitRoomandPop(
                            roomlistener: roomlistener, context: context);
                        roomlistener.cancel();
                        Database.deleteRoomInFirebase(room.roomid,
                            roomtype: room.roomtype, room: room);
                        Navigator.of(context, rootNavigator: true)
                            .pop("Cancel");
                      }),
              new CupertinoDialogAction(
                  child: const Text('Stay'),
                  onPressed: () async {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  void populateraisedHandsusers() {
    if (room.raisedhands.length > raisedhandsusers.length) {
      raisedhandsusers.addAll(allusers
          .where((element) => room.raisedhands.contains(element.uid))
          .toList());
      if (room.ownerid == myProfile.uid) {
        String raisehanduseruid = room.raisedhands.length == 1
            ? room.raisedhands[0]
            : room.raisedhands[room.raisedhands.length - 1];
        int raisedhandindex = raisedhandsusers
            .indexWhere((element) => element.uid == raisehanduseruid);

        Get.snackbar("", "",
            snackPosition: SnackPosition.TOP,
            borderRadius: 0,
            titleText: Text(
              "👋 ${raisedhandsusers[raisedhandindex].firstname + " " + raisedhandsusers[raisedhandindex].lastname} has something to say, Invite them as speaker?",
              style: TextStyle(
                  fontSize: 16, color: Colors.white, fontFamily: "InterBold"),
            ),
            margin: EdgeInsets.all(0),
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(days: 365),
            messageText: Container(
              margin: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    color: Colors.white70,
                    text: "Dismiss",
                    txtcolor: Colors.white,
                    fontSize: 16,
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  CustomButton(
                    color: Colors.white,
                    text: "Invite To Gist",
                    txtcolor: Colors.green,
                    fontSize: 16,
                    onPressed: () {
                      Get.back();

                      Functions().sendNotificationToSpeakerFollowers(
                          raisedhandsusers[raisedhandindex], widget.roomid);
                      activateDeactivateUser(raisedhandsusers[raisedhandindex],
                          room, setState, raisedhandsusers);
                    },
                  )
                ],
              ),
            ));
      }
    }
  }

  void _launchURL(url) async {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Go to Link'),
              onPressed: () async {
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  try {
                    await launch(url);
                  } catch (err) {
                    throw 'Could not launch $url. Error: $err';
                  }
                }
              },
            ),
            if (room.ownerid == myProfile.uid)
              CupertinoActionSheetAction(
                child: const Text('Edit Pinned Link'),
                onPressed: () {
                  addPinnedLink(context);
                },
              ),
          ],
          cancelButton: room.ownerid != myProfile.uid
              ? null
              : CupertinoActionSheetAction(
                  child: Text(
                    'Remove Link',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Get.back();
                    pinnedlinkCallback("");
                  },
                )),
    );
  }

  InfoBase _info;
  String _errorImage, _errorTitle, _errorBody, _url;
  bool _loadingpin = false;

  buildPinnedurl() {
    final WebInfo info = _info as WebInfo;
    double _height = ((MediaQuery.of(context).size.height) * 0.15);

    if (_loadingpin)
      Container(
        height: _height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        alignment: Alignment.center,
        child: Text('Loading Preview...'),
      );

    return _info != null
        ? _buildLinkContainer(
            _height,
            title:
                WebAnalyzer.isNotEmpty(info.title) ? info.title : _errorTitle,
            desc: WebAnalyzer.isNotEmpty(info.description)
                ? info.description
                : _errorBody,
            image: WebAnalyzer.isNotEmpty(info.image)
                ? info.image
                : WebAnalyzer.isNotEmpty(info.icon)
                    ? info.icon
                    : _errorImage,
            isIcon: WebAnalyzer.isNotEmpty(info.image) ? false : true,
          )
        : Container();
  }

  Future<void> _getInfo(_url) async {
    _loadingpin = true;
    if (_url.startsWith("http") || _url.startsWith("https")) {
      _info = await WebAnalyzer.getInfo(_url,
          cache: Duration(hours: 1), multimedia: true);
      setState(() {
        _loadingpin = false;
      });
    } else {}
  }

  Widget _buildLinkContainer(
    double _height, {
    String title = '',
    String desc = '',
    String image = '',
    bool isIcon = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 3, color: Colors.grey)],
      ),
      height: _height,
      child: LinkViewHorizontal(
        key: widget.key ?? Key(_url.toString()),
        url: _url,
        title: title,
        showMultiMedia: true,
        description: desc,
        imageUri: image,
        onTap: (c) {
          _launchURL(_url);
        },
        isIcon: isIcon,
        bgColor: Colors.white,
        radius: 12,
      ),
    );
  }

  buildSponsor() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Room Sponsored by: ",
        style: TextStyle(color: Color(0XFFF7B500)),
      ),
      TextWithShowMore(room.sponsors, Color(0XFFF7B500)),
    ]);
  }
}
