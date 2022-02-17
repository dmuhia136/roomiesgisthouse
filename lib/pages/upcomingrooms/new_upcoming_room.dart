import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/clubs/select_hsost_club.dart';
import 'package:gisthouse/pages/room/add_co_host.dart';
import 'package:gisthouse/pages/upcomingrooms/upcoming_roomsreen.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/club_api.dart';
import 'package:gisthouse/services/database_api/upcoming_api.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:intl/intl.dart';

import '../room/followers_match_grid_sheet.dart';

//ignore: must_be_immutable
class NewUpcomingRoom extends StatefulWidget {
  UpcomingRoom roomm;
  Club club;
  List<Club> clubList = [];
  String from;

  NewUpcomingRoom({this.roomm, this.from, this.club, this.clubList});

  @override
  _NewUpcomingRoomState createState() => _NewUpcomingRoomState();
}

class _NewUpcomingRoomState extends State<NewUpcomingRoom> {
  List<UserModel> hosts = [Get.find<UserController>().user];
  List<UserModel> roomUsers = [];

  List<Club> club = [];
  List<String> clubListNames = [];
  List<String> clubListIds = [];

  // List<Sponsors> sponsorslist = [];

  var sponsornamecontroller = TextEditingController();
  var paidRoomAmountcontroller = TextEditingController();

  String sponsorslist = "";

  int timeseconds;

  int timeInMillis;
  bool openToMembersOnly = false;
  bool paidRoom = false;
  bool privateRoom = false;


  callback(List<UserModel> users, UpcomingRoom room, StateSetter state, send) {

    users.forEach((element) {
      if(!roomUsers.contains(element))
        roomUsers.add(element);
    });

    hosts = roomUsers;

    state(() {});
  }

  userClickCallBack(UserModel user) {
    if (!hosts.contains(user)) hosts.add(user);
    setState(() {});
  }

  void addCoHost(BuildContext context, StateSetter setState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )),
      builder: (context) {
        return AddCoHostScreen(clickCallback: userClickCallBack);
      },
    ).whenComplete(() {
    });
  }

  setselectedclub(List<Club> cluby) {
    club = cluby;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    clubInit();
  }

  void clubInit() async {
    if (widget.roomm != null) {
      eventcontroller.text = widget.roomm.title;
      descriptioncontroller.text = widget.roomm
          .description; // DateTime.fromMillisecondsSinceEpoch(roomm.eventtime).hour.toString()+":"+DateTime.fromMillisecondsSinceEpoch(roomm.eventtime).minute.toString();
      publish = true;
      sponsorslist = widget.roomm.sponsors;
      hosts = widget.roomm.users;
      timeInMillis = widget.roomm.eventdate;
      timeseconds = widget.roomm.eventtime;
      openToMembersOnly = widget.roomm.openToMembersOnly;
      sponsornamecontroller.text = widget.roomm.sponsors;
      paidRoomAmountcontroller.text = widget.roomm.amount > 0 ? widget.roomm.amount.toString() : "";
      paidRoom = widget.roomm.amount > 0 ? true : false;
      privateRoom = widget.roomm.users.length > 1 ? true : false;
      roomUsers = widget.roomm.users;

      if (widget.roomm.clubListIds != null &&
          widget.roomm.clubListIds.isNotEmpty) {
        widget.roomm.clubListIds.forEach((element) async {
          var c = await Database().getClubByIdDetails(element);
          club.add(c);
          setState(() {});
        });
      }
    }
    if (widget.clubList != null) {
      club = widget.clubList;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.themeColor,
      body: Container(
        padding:
            const EdgeInsets.only(top: 30, right: 20, left: 20, bottom: 20),
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
//cancle button
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(fontSize: 20, color: Style.AccentGreen),
                            ),
                          ),
//New event title
                          Text(
                            "NEW EVENT",
                            style: TextStyle(fontSize: 21,
                            color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (eventcontroller.text.isEmpty) {
                                topTrayPopup("enter event title");
                                return;
                              }
                              setState(() => {loading = true});

                              DateTime now = DateTime.now();
                              if (timeInMillis == null) {
                                timeInMillis = now.millisecondsSinceEpoch;
                              }
                              if (timeseconds == null) {
                                timeseconds = DateTime.now()
                                    .add(Duration(hours: 2))
                                    .millisecondsSinceEpoch;
                              }

                              var date = DateFormat("yyyy-MM-dd").format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      timeInMillis));

                              var time = DateFormat("HH:mm").format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      timeseconds));
                              DateTime combinedDate = DateTime.parse(
                                  date.toString() + " " + time.toString());

                              club.forEach((element) {
                                clubListIds.add(element.id);
                                clubListNames.add(element.title);
                              });


                              hosts.forEach((element) {
                                if(roomUsers.indexWhere((element) => element.uid == element.uid) == -1) {
                                  roomUsers.add(element);
                                }
                              });

                              paidRoomAmountcontroller.text = paidRoomAmountcontroller.text == "" ? "0" : paidRoomAmountcontroller.text;
                              if (widget.roomm != null) {
                                var data = {
                                  "title": eventcontroller.text,
                                  "start_date":combinedDate.millisecondsSinceEpoch,
                                  "eventdatetimestamp":
                                      combinedDate.millisecondsSinceEpoch,
                                  "eventtimetimestamp":
                                      combinedDate.millisecondsSinceEpoch,
                                  "clubid": "",
                                  "clubname": "",
                                  "clubListIds": clubListIds,
                                  "clubListNames": clubListNames,
                                  "users": roomUsers
                                      .map((i) => i.toMap(newitem: false))
                                      .toList(),
                                  "description": descriptioncontroller.text,
                                  "userid": Get.find<UserController>().user.uid,
                                  "status": "pending",
                                  "published_date": DateTime.now().millisecondsSinceEpoch,
                                  "sponsors": sponsornamecontroller.text,
                                  "openToMembersOnly": openToMembersOnly,
                                  "amount": double.parse(paidRoomAmountcontroller.text),
                                  "private": roomUsers.length > 1 ? true : false,
                                };
                                Database.updateUpcomingEvent(
                                    widget.roomm.roomid, data);

                                //update club with the room attached to it
                                if (club != null) {
                                  club.forEach((element) {
                                    ClubApi().addRoomForClub(element.id, widget.roomm.roomid);
                                  });
                                }
                              } else {
                                Database().addUpcomingEvent(
                                    eventcontroller.text,
                                    combinedDate,
                                    combinedDate.millisecondsSinceEpoch,
                                    combinedDate.millisecondsSinceEpoch,
                                    descriptioncontroller.text,
                                    roomUsers,
                                    sponsornamecontroller.text,
                                    null,
                                    clubListIds,
                                    clubListNames,
                                    double.parse(paidRoomAmountcontroller.text),
                                    openToMembersOnly: openToMembersOnly,
                                private: roomUsers.length > 1 ? true : false);
                              }
                              Navigator.pop(context);
                              Navigator.pop(context);
                              timeInMillis = null;
                              timeseconds = null;
                              descriptioncontroller.text = "";
                              eventcontroller.text = "";
                              publish = false;

                              setState(() => {loading = false});
                            },
                            child: Text(
                              widget.roomm != null ? "Save" : "Publish",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.green),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
//event name textfield
                              child: TextFormField(
                                controller: eventcontroller,
                                maxLength: null,
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        fontSize: 16, color: Colors.black54),
                                    hintText: "Event Name",

                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none),
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                            Divider(color: Colors.grey),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
//with
                                  Text(
                                    "With: ",
                                    style: (TextStyle(
                                        fontSize: 18, color: Colors.black)),
                                  ),
                                  Flexible(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      itemBuilder: (lc, index) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      RoundImage(
                                                        url: hosts[index]
                                                            .smallimage,
                                                        txt: hosts[index]
                                                            .firstname,
                                                        txtsize: 10,
                                                        width: 30,
                                                        height: 30,
                                                        borderRadius: 15,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        hosts[index].getName(),
                                                        style: (TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black)),
                                                      ),
                                                    ],
                                                  ),
                                                  if (Get.find<UserController>()
                                                          .user
                                                          .uid !=
                                                      hosts[index].uid)
                                                    InkWell(
                                                        onTap: () {
                                                          hosts.removeAt(index);
                                                          setState(() {});
                                                        },
                                                        child: Icon(
                                                            Icons.cancel,
                                                            color: Colors.black))
                                                ],
                                              ),
                                            ),
                                            if (hosts.length - 1 != index)
                                              Divider(color: Colors.grey)
                                          ],
                                        );
                                      },
                                      itemCount: hosts.length,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: Colors.grey),
                            InkWell(
                              onTap: () {
                                addCoHost(context, setState);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 15, top: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Add a Co-host or Guest",
                                      style: (TextStyle(
                                          fontSize: 16,
                                          color: Colors.black)),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right_rounded,
                                      size: 30,
                                      color: Colors.black54,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(color: Colors.grey),
                            // InkWell(
                            //   onTap: () {
                            //     Get.to(() => RoomSponsors(
                            //         sponsorClickBack: sponsorCallBack));
                            //   },
                            //   child: Padding(
                            //     padding:
                            //         const EdgeInsets.only(bottom: 15, top: 10),
                            //     child: Row(
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         Text(
                            //           "Room Sponsor",
                            //           style: (TextStyle(fontSize: 16)),
                            //         ),
                            //         Icon(
                            //           Icons.keyboard_arrow_right_rounded,
                            //           size: 30,
                            //           color: Colors.grey,
                            //         )
                            //       ],
                            //     ),
                            //   ),
                            // ),
//enter room sponsor name
                            TextFormField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                // labelText: 'Sponsor name',
                                hintStyle: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                                hintText: 'Enter room sponsor name',
                              ),
                              controller: sponsornamecontroller,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 20,
                    ),
//paid room
                    Container(
                      decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                          children: [
                            Get.find<UserController>().user.coinsEnabled == true ?
                            Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Paid room?",
                                style: (TextStyle(
                                    fontSize: 18, color: Colors.black))
                              ),
                              Switch(
                                value: paidRoom,
                                onChanged: (value) {
                                  paidRoom = value;
                                  privateRoom = false;
                                  hosts = [];
                                  hosts.add(Get.find<UserController>().user);
                                  paidRoomAmountcontroller.text = "";
                                  setState(() {});
                                },
                                activeTrackColor: Colors.lightGreenAccent,
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ) : Container(),
                        paidRoom == true
                        ? Column(
                          children: [
                            Divider(),
                            Container(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  // labelText: 'Sponsor name',
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: Style.AccentBrown),
                                  hintText: '0.0',
                                    prefixIcon: Icon(
                                  Icons.account_balance_wallet_sharp,
                                  color: Colors.black54,
                                )
                                ),
                                controller: paidRoomAmountcontroller,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        )
                            : Container(),
                      ]),
                    ),
                    SizedBox(
                      height: 20,
                    ),
//private container
                    Container(
                      decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Private room?",
                                    style: (TextStyle(
                                        fontSize: 18, color: Colors.black)),
                                  ),
                                  Switch(
                                    value: privateRoom,
                                    onChanged: (value) {
                                      privateRoom = value;
                                      if(privateRoom == false) {
                                        hosts = [];
                                        hosts.add(Get.find<UserController>().user);
                                      }
                                      paidRoom = false;
                                      roomUsers = [];
                                      roomUsers.add(Get.find<UserController>().user);
                                      setState(() {});
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                            privateRoom == true
                                ? Column(
                              children: [
                                Divider(),
                                Container(
                                  child: InkWell(
                                    child: Container(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Choose people ",
                                              style: (TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black)),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                roomUsers.isNotEmpty
                                                    ? roomUsers.length.toString()
                                                    : "None",
                                                style: (TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                )),
                                                softWrap: true,
                                              ),
                                              Icon(
                                                Icons.keyboard_arrow_right_rounded,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      showModalBottomSheet(
                                          backgroundColor: Style.AccentBlue,
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.vertical(top: Radius.circular(15.0)),
                                          ),
                                          context: context,
                                          builder: (context) {
                                            //3
                                            return StatefulBuilder(builder:
                                                (BuildContext context, StateSetter customState) {
                                              return DraggableScrollableSheet(

                                                  expand: false,
                                                  builder: (BuildContext context,
                                                      ScrollController scrollController) {
                                                    return Container(
                                                      color: Style.themeColor,
                                                        padding: EdgeInsets.only(top: 20),
                                                        child: FollowerMatchGridPage(
                                                            callback: callback,
                                                            title: "With...",

                                                            fromroom: false,
                                                            state: setState,
                                                            customState: customState));
                                                  });
                                            });
                                          });
                                    },
                                  ),
                                ),
                              ],
                            )
                                : Container(),
                          ]),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      margin: EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                showdatecalendarpicker =
                                    !showdatecalendarpicker;
                                showtimecalendarpicker = false;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontFamily: "RobotoLight",
                                        color: Colors.black),
                                  ),
                                  Text(
                                      timeInMillis == null
                                          ? "Today"
                                          : DateFormat("dd-MM-yyyy")
                                              .format(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      timeInMillis))
                                              .toString(),
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontFamily: "RobotoLight",
                                          color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Divider(),
                          SizedBox(
                            height: 5,
                          ),
                          showdatecalendarpicker
                              ? Container(
                                  height: 300,
                                  child: CupertinoDatePicker(
                                    initialDateTime: widget.roomm != null
                                        ? DateTime.fromMillisecondsSinceEpoch(
                                            widget.roomm.eventdate)
                                        : DateTime.now()
                                            .add(Duration(hours: 2)),
                                    use24hFormat: false,
                                    onDateTimeChanged: (val) {
                                      timeInMillis = val.millisecondsSinceEpoch;
                                      setState(() {});
                                    },
                                    mode: CupertinoDatePickerMode.date,
                                  ),
                                )
                              : Container(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                showtimecalendarpicker =
                                    !showtimecalendarpicker;
                                showdatecalendarpicker = false;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Time",
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontFamily: "RobotoLight",
                                        color: Colors.black),
                                  ),
                                  Text(
                                      timeseconds == null
                                          ? DateFormat("hh:mma")
                                              .format(DateTime.now()
                                                  .add(Duration(hours: 2)))
                                              .toString()
                                          : DateFormat("hh:mma")
                                              .format(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      timeseconds))
                                              .toString(),
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontFamily: "RobotoLight",
                                          color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                          showtimecalendarpicker
                              ? Container(
                                  height: 300,
                                  child: CupertinoDatePicker(
                                    initialDateTime: widget.roomm != null
                                        ? DateTime.fromMillisecondsSinceEpoch(
                                            widget.roomm.eventtime)
                                        : DateTime.now()
                                            .add(Duration(hours: 2)),
                                    use24hFormat: false,
                                    onDateTimeChanged: (val) {
                                      timeseconds = val.millisecondsSinceEpoch;
                                      setState(() {});
                                    },
                                    mode: CupertinoDatePickerMode.time,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      elevation: 2,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(15.0)),
                                  ),
                                  context: context,
                                  builder: (context) {
                                    //3
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return SelectHostClub(
                                          selectedClubs: club,
                                          setSelectedClubs: setselectedclub);
                                    });
                                  });
                            },
                            child: Container(

                              padding:
                                  EdgeInsets.only(left: 20, right: 20, top: 15),
                              width: double.infinity,
//host club
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Host Club ",
                                      style: (TextStyle(
                                          fontSize: 18,
                                          color: Colors.black)),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        club != null && club.isNotEmpty
                                            ? club.length.toString()
                                            : "None",
                                        style: (TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        )),
                                        softWrap: true,
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_right_rounded,
                                        size: 30,
                                        color: Style.HintColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(),
                          if (club != null && club.isNotEmpty)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Open to Members Only",
                                    style: (TextStyle(
                                        fontSize: 18,
                                        color: Style.AccentBrown)),
                                  ),
                                  Switch(
                                    value: openToMembersOnly,
                                    onChanged: (value) {
                                      openToMembersOnly = value;
                                      setState(() {});
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      height: 200,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: descriptioncontroller,
                        maxLines: null,
                        decoration: InputDecoration(
                            hintStyle: TextStyle(
                              fontSize: 20,
                            ),
                            hintText: 'Description',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            fillColor: Colors.white),
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    widget.roomm == null
                        ? Container()
                        : InkWell(
                            onTap: () {
                              var alert = new CupertinoAlertDialog(
                                title: new Text('Are you sure?'),
                                content: new Text(
                                    'deleting this event will remove it from upcoming for all users'),
                                actions: <Widget>[
                                  new CupertinoDialogAction(
                                      child: const Text('Delete Event'),
                                      isDestructiveAction: true,
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        setState(() => {loading = true});
                                        await UpcomingRoomApi().deleteUpcoming(widget.roomm.roomid);
                                        loading = false;
                                        setState(() => {});
                                      }),
                                  new CupertinoDialogAction(
                                      child: const Text('Never Mind'),
                                      isDefaultAction: true,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                ],
                              );
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return alert;
                                  });
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
                                      "Delete Event",
                                      style: (TextStyle(
                                          fontSize: 16, color: Colors.red)),
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
    );
  }
}
