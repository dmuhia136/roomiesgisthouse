import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/models/room.dart';
import 'package:gisthouse/models/room_user.dart';
import 'package:gisthouse/pages/chats/chats_screen.dart';
import 'package:gisthouse/pages/home/home_page.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/pages/room/paid_room_screen.dart';
import 'package:gisthouse/pages/room/room_screen.dart';
import 'package:gisthouse/pages/room/widgets/create_rooms_bottom_sheet.dart';
import 'package:gisthouse/pages/room/widgets/room_card.dart';
import 'package:gisthouse/pages/room/widgets/schedule_card_old.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/ongoingroom_api.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/services/dynamic_link_service.dart';
import 'package:gisthouse/util/firebase_refs.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/noitem_widget.dart';
import 'package:gisthouse/widgets/round_button.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../util/firebase_refs.dart';

class RommiesScreen extends StatefulWidget {
  @override
  _RommiesScreenState createState() => _RommiesScreenState();
}

joinRoom(BuildContext context, UserModel currentUser,
    {String roomid, exists = false, String roomIdToLeave}) async {
//exit the room the user was in

  if (roomIdToLeave != null && roomIdToLeave.isNotEmpty) {
    await Functions.leaveChannel(
        quit: false,
        roomid: roomIdToLeave,
        currentUser: currentUser,
        context: context);
  }

  Get.to(() => RoomScreen(
        roomid: roomid,
        exists: exists,
      ));
}

Future<void> joinexistingroom(
    {String roomid,
    Room room,
    BuildContext context,
    UserModel currentUser,
    bool paidroom = false}) async {
  String rID = "";
  if (roomid != null && roomid.isNotEmpty) {
    rID = roomid;
  } else if (room != null) {
    rID = room.roomid;
    paidroom =
        room.amount > 0 && currentUser.paidrooms.contains(room.roomid) == false;
  }

  String currentUserrID = "";
  if (currentUser.activeroom != null && currentUser.activeroom.isNotEmpty) {
    currentUserrID = currentUser.activeroom;
  }
  if (rID == currentUserrID) {
    // OPEN ROOM SCREEN
    joinRoom(context, currentUser, roomid: rID, exists: true);
  } else if (rID != currentUserrID) {
    //ENTERING ROOM FOR THE FIRST TIME
    if (currentUser == null && currentUser.username.isEmpty) {
      topTrayPopup("Error entering this room at this time, try again later");
    } else {

      Room room = await Database().getRoomDetails(rID);
      //CHECK IF USER HAS PAID FOR THIS ROOM, IF NOT PROMPT FOR PAYMENT
      if (room != null &&
          room.amount > 0 &&
          !currentUser.paidrooms.contains(rID)) {
        Get.to(() => PaidRoomScreen(room: room));
        // Sheet.openDrag(context, BuyATicketSheet(room, false));
      } else {
        await joinRoom(context, currentUser,
            roomid: rID, roomIdToLeave: currentUserrID);
      }
    }
  }
}

class _RommiesScreenState extends State<RommiesScreen>
    with WidgetsBindingObserver {
  //refresh initialize
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  //current user object
  UserModel myProfile = Get.find<UserController>().user;
  final globalScaffoldKey = GlobalKey<ScaffoldState>();
  final globalScaffoldKey1 = GlobalKey<ScaffoldState>();

  StreamSubscription<DocumentSnapshot> listener;
  StreamSubscription<QuerySnapshot> inboxlistener;
  List<Room> rooms = [];
  List<RoomUser> raisedHandsUsers = [];
  CurrentRoomController controller = Get.put(CurrentRoomController());

  int notifications = 0;

  //initialize varaibles
  String roomtype = "open";
  bool loading = false, loadingrooms = false;
  bool currentlyJoiningRoom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Data.addInterests();

    getUserFromApi();

    inboxlistener = messagenotificationsRef
        .where("unreadusers", arrayContainsAny: [myProfile.uid])
        .snapshots()
        .listen((event) {
          notifications = event.docs.length;
          if(mounted)setState(() {});
        });
    multistreams();
  }

  getUserFromApi() async {
    var user = await UserApi().getUserById(myProfile.uid);
    myProfile = UserModel.fromJson(user);
    Get.find<UserController>().user = myProfile;
    setState(() {});
  }

  multistreams() async{
    setState(() {
      loadingrooms = true;
    });
    rooms.clear();

    List data = [];

    data.addAll(await getCombinedRooms());

    if (data != null) {
      rooms.addAll(data.map((e) => Room.fromJson(e)).toList());
      rooms.sort((a, b) => b.createdtime.compareTo(a.createdtime));
      setState(() {
        loadingrooms = false;
      });
    }
  }

  getCombinedRooms() async {
    return await OngoingRoomApi().getRoomsCombined(myProfile.uid, myProfile.following);

  }

  // Future<List<QueryDocumentSnapshot>> getMySocialRooms() async {
  //   return await roomsRef
  //       .where("roomtype", isEqualTo: "social")
  //       .orderBy("created_time", descending: true)
  //       .where("ownerid", isEqualTo: Get.find<UserController>().user.uid)
  //       .get()
  //       .then((value) => value.docs);
  // }

  // Future<Stream> getRooms() async {
  //   setState(() {
  //     loadingrooms = true;
  //   });
  //   rooms.clear();
  //   // await roomsRef
  //   //     .where("roomtype", isEqualTo: "club")
  //   //     .where("openToMembersOnly", isEqualTo: false)
  //   //     .orderBy("created_time", descending: true)
  //   //     .get()
  //   //     .then((value) {
  //   //   value.docs.forEach((element) {
  //   //     rooms.add(Room.fromJson(element));
  //   //   });
  //   // });
  //   //
  //   // await roomsRef
  //   //     .where("roomtype", isEqualTo: "club")
  //   //     .where("openToMembersOnly", isEqualTo: true)
  //   //     .where("clubmembers", arrayContainsAny: [myProfile.uid])
  //   //     .orderBy("created_time", descending: true)
  //   //     .get()
  //   //     .then((value) {
  //   //       Functions.debug(myProfile.uid);
  //   //       value.docs.forEach((element) {
  //   //         rooms.add(Room.fromJson(element));
  //   //       });
  //   //     });
  //
  //   // await roomsRef
  //   //     .where("roomtype", isEqualTo: "public")
  //   //     .orderBy("created_time", descending: true)
  //   //     .get()
  //   //     .then((value) {
  //   //   value.docs.forEach((element) {
  //   //     rooms.add(Room.fromJson(element));
  //   //   });
  //   // });
  //
  //   // await roomsRef
  //   //     .where("roomtype", isEqualTo: "private")
  //   //     .orderBy("created_time", descending: true)
  //   //     .where("invitedfriends", arrayContainsAny: [myProfile.uid])
  //   //     .get()
  //   //     .then((value) {
  //   //       value.docs.forEach((element) {
  //   //         rooms.add(Room.fromJson(element));
  //   //       });
  //   //     });
  //
  //   // if (Get.find<UserController>().user.followers.length > 0) {
  //   //   Get.find<UserController>().user.followers.forEach((element1) async {
  //   //     await roomsRef
  //   //         .where("roomtype", isEqualTo: "social")
  //   //         .orderBy("created_time", descending: true)
  //   //         .where("ownerid", isEqualTo: element1)
  //   //         .get()
  //   //         .then((value) {
  //   //       value.docs.forEach((element) {
  //   //         rooms.add(Room.fromJson(element));
  //   //       });
  //   //     });
  //   //   });
  //   // }
  //   rooms.sort((a, b) => b.createdtime.compareTo(a.createdtime));
  //
  //   setState(() {
  //     loadingrooms = false;
  //   });
  // }

  Future<void> registerNewRoom(
      {roomtype,
      topic,
      List<UserModel> users,
      Club club,
      double amount,
      String currency}) async {
    try {
      setState(() {
        loading = true;
      });

      var ref = await Database().createRoom(
          userData: myProfile,
          topic: topic,
          type: roomtype,
          users: users,
          sponsors: "",
          clubs: club != null ? [club] : [],
          context: context,
          amount: amount,
          currency: amount != null && amount != 0 ? currency : "");
      joinRoom(context, myProfile,
          roomid: ref, roomIdToLeave: myProfile.activeroom);

      setState(() {
        loading = false;
      });
    } catch (e) {
      topTrayPopup("Error happened when creating this room, try again");

      setState(() {
        loading = false;
      });
    }
  }

  @mustCallSuper
  @protected
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future handleStartUpLogic() async {
    await DynamicLinkService().handleDynamicLinks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
  }

  //handle on refresh
  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
    multistreams();
  }

  //refresh completed
  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalScaffoldKey,
      backgroundColor: Colors.transparent,
      body: Container(
        margin: EdgeInsets.only(top: 30),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // buildScheduleCard(),
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SmartRefresher(
                        key: globalScaffoldKey1,
                        enablePullDown: true,
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: 80,
                            left: 20,
                            right: 20,
                          ),
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            Room room = rooms[index];
                            return FutureBuilder(
                                future: Database.getroomUsers(room.roomid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container();
                                  }
                                  if (!snapshot.hasData) {
                                    return Container();
                                  }
                                  List users = snapshot.data;
                                  if (users.length == 0) {
                                    return Container();
                                  } else {
                                    return buildRoomCard(room, users);
                                  }
                                });
                          },
                        ),
                      ),
                      if (loadingrooms)
                        Center(
                          child: noDataWidget(
                              "Please Wait For Live GistRooms to be Displayed",
                              fontfamily: "InterSemiBold",
                              fontsize: 20,

                              colors: Colors.black),
                        ),
                      if (rooms.length == 0 && loadingrooms == false)
                        Center(
                          child: noDataWidget("No Rooms yet",
                              fontfamily: "InterSemiBold",
                              fontsize: 23,

                              colors: Colors.black),
                        ),
                      buildStartRoomButton(),
                    ],
                  ),
                ),
              ],
            ),
            if (loading == true) loadingWidget(context),
          ],
        ),
      ),
    );
  }

  Widget buildScheduleCard() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: ScheduleCardOld(),
    );
  }

  Widget buildRoomCard(Room room, List users) {
    return GestureDetector(
      onTap: () {
        loading = true;
        setState(() {
        });
        joinexistingroom(room: room, currentUser: myProfile, context: context);
        loading = false;
        setState(() {

        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: RoomCard(room: room, users: users, homepage: true),
      ),
    );
  }

  Widget buildGradientContainer() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Style.LightBrown.withOpacity(0.2),
          Style.LightBrown,
        ],
      )),
    );
  }

  Widget buildStartRoomButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
//available chat icon
        Stack(
          children: [
            Positioned(
              left: 30,
              child: Stack(
                children: [
                  InkWell(
                      onTap: () {
                        pageController.animateToPage(0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                      child: Icon(
                        CupertinoIcons.circle_grid_3x3,
                        size: 30,
                      )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Style.AccentGreen),
                    ),
                  )
                ],
              ),
              top: 15,
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
//Button
                child: CustomButton(
                    radius: 40,
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 25),
                    onPressed: () {
                      showBottomSheet();
                    },
                    txtcolor: Colors.white,
                    color: Style.AccentGreen,
                    text: '+ Start a room'),
              ),
            ),
            Positioned(
              right: 30,
              child: Stack(
                children: [
                  InkWell(
                      onTap: () {
                        Get.to(() => ChatsScreen());
                      },
                      child: Image.asset(
                        "assets/icons/sidechat.png",
                        width: 30,
                        color: Colors.black
                        ,
                      )),
                  if (notifications > 0)
                    Positioned(
                      top: 0,
                      left: 5,
                      child: Container(
                        height: 15,
                        width: 15,
                        child: Center(
                            child: Text(
                          notifications.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        )),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.red),
                      ),
                    )
                ],
              ),
              top: 15,
            )
          ],
        ),
        GetX<CurrentRoomController>(builder: (_) {
          Room activeroom = _.room;
          List<RoomUser> users = _.roomusers;

          if (activeroom == null || activeroom.roomid == null)
            return Container();

          // List<RoomUser> users = Database.getroomUsers(activeroom.roomid);
          // List<RoomUser> raisedhandsusers = Database.getRaisedHandsUsers(activeroom.roomid);

//bottom part room details
          return InkWell(
            onTap: () => joinRoom(context, myProfile,
                roomid: activeroom.roomid, exists: true),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0XFF3F3A6B),
                    offset: Offset(0, 1),
                  )
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        users.length > 1
                            ? Container(
                                child: InkWell(
                                  onTap: () {
                                    Get.to(
                                      () => ProfilePage(
                                        userid: users[1].uid,
                                        fromRoom: false,
                                        isMe: users[1].uid ==
                                            Get.find<UserController>().user.uid,
                                      ),
                                    );
                                  },
                                  child: RoundImage(
                                    url: users[1].imageurl,
                                    txt: users[1].username,
                                    width: 45,
                                    height: 45,
                                    borderRadius: 20,
                                  ),
                                ),
                              )
                            : Container(),
                        Container(
                          margin: EdgeInsets.only(left: 42),
                          child: InkWell(
                            onTap: () {
                              Get.to(
                                () => ProfilePage(
                                  userid: users[0].uid,
                                  fromRoom: false,
                                  isMe: users[0].uid ==
                                      Get.find<UserController>().user.uid,
                                ),
                              );
                            },
                            child: RoundImage(
                              url: users[0].imageurl,
                              txt: users[0].username,
                              width: 45,
                              height: 45,
                              borderRadius: 20,
                            ),
                          ),
                        ),
                        users.length > 2
                            ? RoundImage(
                                margin: EdgeInsets.only(left: 84),
                                width: 45,
                                height: 45,
                                borderRadius: 20,
                                url: "",
                                txt: "+" + (users.length - 2).toString(),

                              )
                            : Container(),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Functions.leaveChannel(
                        setState: setState,
                          room: activeroom,
                          currentUser: myProfile,
                          context: context,
                          quit: false);

                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '✌🏾',
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  buildBottomNav(
                      raisedhandsusers: getAllRaisedHands(activeroom),
                      room: activeroom,
                      context: context,
                      users: users,
                      state: setState,
                      myProfile: myProfile),
                ],
              ),
            ),
          );
        })
      ],
    );
  }

  getRaisedHands(Room room) async {
    raisedHandsUsers.clear();

    List roomRaisedHands = await OngoingRoomApi().getRaisedHands(room.roomid);


    roomRaisedHands.forEach((id) async {
      RoomUser user = RoomUser.fromJson(await OngoingRoomApi().getRoomUserById(room.roomid, id));
      raisedHandsUsers.add(user);
    });

    return raisedHandsUsers;
  }

  getAllRaisedHands(Room room) {
    getRaisedHands(room);
    return raisedHandsUsers;
  }

  showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Wrap(
            children: [
              LobbyBottomSheet(
                onChange: (String txt) {},
                onButtonTap: (roomtype, topic, List<UserModel> users, Club club,
                    double amount, String typeofpayment) async {
                  Navigator.pop(context);
                  registerNewRoom(
                      roomtype: roomtype,
                      topic: topic,
                      users: users,
                      club: club,
                      amount: amount,
                      currency: typeofpayment);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
