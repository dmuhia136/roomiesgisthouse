import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/clubs/wallet/club_wallet_page.dart';
import 'package:gisthouse/pages/home/select_interests.dart';
import 'package:gisthouse/pages/profiles/widgets/user_profile_image.dart';
import 'package:gisthouse/pages/room/followers_list.dart';
import 'package:gisthouse/pages/upcomingrooms/new_upcoming_room.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/club_api.dart';
import 'package:gisthouse/services/dynamic_link_service.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';

//ignore: must_be_immutable
class ViewClub extends StatefulWidget {
  Club club;
  String clubid;

  ViewClub({this.club,this.clubid});

  @override
  _ViewClubState createState() => _ViewClubState();
}

class _ViewClubState extends State<ViewClub>
    with SingleTickerProviderStateMixin {
  bool keyboardup = false;
  int _index = 0;
  ScrollController _scrollController;
  int loadMoreMsgs = 20; // at first it will load only 25
  bool loadingmore = false, moreusers = true, loading = false, mainloading = false;
  Map<List<UserModel>,dynamic> allData = {};
  List<UserModel>  _allUsers = [];

  final picker = ImagePicker();
  File _imageFile;
  StreamSubscription<DocumentSnapshot> clubliten;
  TabController _tabController;

  int tabindex = 0;

  var last;
  String clubid = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if(widget.club !=null){
      clubid = widget.club.id;
    }
    if(widget.clubid !=null){
      clubid = widget.clubid;
    }
    setState(() {
      mainloading = true;
    });
    getClub();


    getP();
  }

  getClub() async {
    setState(() {
      mainloading = true;
    });
    if(clubid != null) {
      widget.club = await ClubApi().getClubsById(clubid);
    }

    setState(() {
      mainloading = false;
    });

  }


  void getP() async{
    _scrollController = ScrollController()
      ..addListener(() async {
        if (_scrollController.position.atEdge) {
          if (_scrollController.position.pixels == 0){}
          else {
            getUsers(true);
          }
        }
      });
    getUsers(false);
  }

  getUsers(bool more) async {
      loading = true;
      setState(() {});

      if(loadingmore == false){

        List usersFromApi = await ClubApi().getClubMembers(widget.club.id);

      if(usersFromApi.length > 0) {
        _allUsers.clear();
        last = usersFromApi.last;
        usersFromApi.forEach((element) {
          _allUsers.add(UserModel.fromJson(element));
        });
        loading = false;
        setState(() {});
      }
    } else {
      if (moreusers == false) {
        return;
      }
      loadingmore = true;
      setState(() {});
      List usersFromApiAgain = await ClubApi().getClubMembersAfter(last['_id'], last['membersince']);

            if (usersFromApiAgain.length < loadMoreMsgs) {
              moreusers = false;
            } else {
              last = usersFromApiAgain.last;
            }

      usersFromApiAgain.forEach((element) {
              _allUsers.add(UserModel.fromJson(element.data()));
            });
            loadingmore = false;
            setState(() {});

    }
  }

  @override
  void dispose() {
    clubliten.cancel();
    super.dispose();
  }

  handleClick(c) {
    switch (c) {
      case "topics":
        Get.to(() => InterestsPick(
            title: "Choose Topics",
            subtitle:
                "Choose up to 3 topics to help others find and understand your club",
            club: widget.club));
        break;
      case "allowfolloers":
        Database.updateClub(
            clubid, {"allowfollowers": !widget.club.allowfollowers});
        Database.getusersInaClub(widget.club);
        break;
      case "start":
        Database.updateClub(clubid,
            {"membercanstartrooms": !widget.club.membercanstartrooms});
        break;
      case "viewwallet":
        Database.updateClub(clubid,
            {"allowmembersviewwallet": !widget.club.allowmembersviewwallet});
        break;
      case "hide":
        Database.updateClub(
            clubid, {"membersprivate": !widget.club.membersprivate});
        break;
      case "description":
        addBio();
        break;
      case "leave":
        ClubApi().leaveClub(widget.club.id, widget.club.ownerid);

        Database().deleteClub(widget.club.id);
        Get.back();
        break;
    }
  }

  List<List<String>> options = [
    ["topics", "Edit Club Topics"],
    // ["allowfolloers", "Don't Allow Followers"],
    ["start", "Let Members Start Rooms"],
    ["hide", "Hide Members List"],
    ["host", "Allow Members To Host Rooms"],
    ["viewwallet", "Allow Members To View Wallet"],
    ["description", "Edit Description"],
    ["leave", "Leave Club"],
  ];

  Widget _indicator(bool isActive) {
    return Container(
      height: 10,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 10 : 8.0,
        width: isActive ? 12 : 8.0,
        decoration: BoxDecoration(
          boxShadow: [
            isActive
                ? BoxShadow(
                    color: Color(0XFF2FB7B2).withOpacity(0.72),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : BoxShadow(
                    color: Colors.transparent,
                  )
          ],
          shape: BoxShape.circle,
          color: isActive ? Colors.blueGrey : Colors.grey,
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator(List<UpcomingRoom> rooms) {
    List<Widget> list = [];
    for (int i = 0; i < rooms.length; i++) {
      list.add(i == _index ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [CropAspectRatioPreset.square],
        compressQuality: 70,
        compressFormat: ImageCompressFormat.jpg,
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          rotateClockwiseButtonHidden: false,
          rotateButtonsHidden: false,
        ));
    if (croppedImage != null) {
      _imageFile = croppedImage;
      setState(() {
        loading = true;
      });

      Database().uploadClubImage(clubid,
          file: _imageFile, update: true, previousurl: widget.club.imageurl);
      setState(() {
        loading = false;
      });
    }
  }

  _getFromGallery(ImageSource imageSource) async {
    PickedFile pickedFile = await picker.getImage(
      source: imageSource,
    );
    _cropImage(pickedFile.path);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: false,
          title: const Text('Add a profile photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _getFromGallery(ImageSource.gallery);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Choose from galley"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _getFromGallery(ImageSource.camera);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Take photo"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      child: mainloading == true ? Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ) : Stack(
        children: [
          if (loadingmore)
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )),
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: Style.themeColor,
                appBar: AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black
                  ),
                  backgroundColor: Colors.transparent,
                  leading: InkWell(
                    onTap: () {
                      Get.back();
                    },
//back Icon
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 25,

                    ),
                  ),
                  title: Row(

                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.club !=null && widget.club.allowmembersviewwallet == true ||
                          widget.club !=null && widget.club.ownerid ==
                              Get.find<UserController>().user.uid)
//wallet icon
                        InkWell(
                          onTap: () {
                            Get.to(() => ClubWalletPage(club: widget.club));
                          },
                          child: Image.asset(
                            "assets/icons/walleticon.png",
                            width: 35,
                            color: Colors.black,
                          ),
                        ),
//share icon
                      IconButton(
                          icon: Icon(
                            Icons.share,
                            size: 30,

                          ),
                          onPressed: () {
                            final RenderBox box = context.findRenderObject();
                            DynamicLinkService()
                                .createGroupJoinLink(clubid, "club")
                                .then((value) async {
                              await Share.share(value,
                                  subject:
                                      "Share " + widget.club.title + " Club",
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) &
                                          box.size);
                            });
                          }),
                    ],
                  ),
                  actions: widget.club.ownerid !=
                          Get.find<UserController>().user.uid
                      ? null
                      : <Widget>[
                          PopupMenuButton<String>(
                            color: Colors.white,
                            onSelected: handleClick,
                            itemBuilder: (BuildContext context) {
                              return options.map((List choice) {
                                String text = choice[1];
                                String action = choice[0];
                                if (action == "start" &&
                                    widget.club.membercanstartrooms == true) {
                                  text = "Stop Members to start Rooms";
                                }

                                if (action == "allowfolloers" &&
                                    widget.club.allowfollowers == false) {
                                  text = "Allow Followers";
                                }

                                if (action == "hide" &&
                                    widget.club.membersprivate == true) {
                                  text = "Show Members List";
                                }

                                if (action == "host" &&
                                    widget.club.allowmemberstohostrooms ==
                                        true) {
                                  text = "Limit Members to Host Rooms";
                                }

                                return PopupMenuItem<String>(
                                  value: choice[0],
                                  child: Text(
                                    text,
                                    style: TextStyle(color: Style.AccentBrown),
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ],
                ),
                body: Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: ListView(
                    controller: _scrollController,
                    shrinkWrap: true,
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.club.ownerid ==
                              Get.find<UserController>().user.uid) {
                            _showMyDialog();
                          }
                        },
                        child: loading == true
                            ? Container(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Center(
//club image place holder
                                child: RoundImage(
                                  url: widget.club.imageurl,
                                  width: 100,
                                  height: 100,
                                  txt: widget.club.title,
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
//club name title
                            child: Text(
                              widget.club.title.toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
//members
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                          widget.club.id == MAIN_CLUB_ID ? "Headquarters":
                          "${widget.club.members.length} member${widget.club.members.length > 1 ? "s" : ""}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (widget.club.allowmemberstohostrooms ||
                          widget.club.ownerid ==
                              Get.find<UserController>().user.uid)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.to(
                                    () => NewUpcomingRoom(club: widget.club, clubList: [widget.club],));
                              },
//schedule a room
                              child: Container(
                                margin: EdgeInsets.only(top: 30),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Style.Blue),
                                child: Text(
                                  "Schedule a Room",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: "InterSemiBold"),
                                ),
                              ),
                            ),
//add members button
                            InkWell(
                              onTap: () {
                                Get.to(() => FollowersList(club: widget.club));
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 30),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white),
                                child: Text(
                                  "Add Members",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Style.black,
                                      fontFamily: "InterSemiBold"),
                                ),
                              ),
                            )
                          ],
                        ),
                      if(widget.club.id != MAIN_CLUB_ID)
                      if (widget.club.ownerid !=
                          Get.find<UserController>().user.uid)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            widget.club.members.contains(
                                        Get.find<UserController>().user.uid) ==
                                    true
                                ? Row(
                                    children: [
                                      InkWell(
                                        onTap: clubid == MAIN_CLUB_ID
                                            ? null
                                            : () {
                                                showModalBottomSheet(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      15.0)),
                                                    ),
                                                    context: context,
                                                    builder: (context) {
                                                      return InkWell(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          Database.leaveClub(
                                                              widget.club);

                                                          setState(() {
                                                            widget.club.members.remove(Get.find<UserController>().user.uid);

                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      30,
                                                                  vertical: 20),
                                                          child: Text(
                                                            "Leave Club",
                                                            style: TextStyle(
                                                                fontSize: 21),
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                        child: Container(
                                          margin: EdgeInsets.only(top: 30),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Style.indigo),
                                          child: Text(
                                            "Member",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily: "InterSemiBold"),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 40,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.to(() =>
                                              FollowersList(club: widget.club));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(top: 30),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Colors.white),
                                          child: Text(
                                            "Invite People",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontFamily: "InterSemiBold"),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
//join button
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        loading = true;
                                      });
                                      Database.acceptClubInvite(clubid);
                                      setState(() {
                                        loading = false;
                                        widget.club.members.add(Get.find<UserController>().user.uid);
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: 30),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 5),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Style.Blue),
                                      child: Text(
                                        "Join",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontFamily: "InterSemiBold"),
                                      ),
                                    ),
                                  ),
                            // if (widget.club.allowfollowers == true &&
                            //     widget.club.members.contains(
                            //             Get.find<UserController>().user.uid) ==
                            //         false &&
                            //     widget.club.members.contains(
                            //             Get.find<UserController>().user.uid) ==
                            //         false)
                            //   InkWell(
                            //     onTap: () {
                            //       setState(() {
                            //         loading = true;
                            //       });
                            //       if (widget.club.followers.contains(
                            //           Get.find<UserController>().user.uid)) {
                            //         Database.unFolloClub(widget.club);
                            //       } else {
                            //         Database.followClub(widget.club);
                            //       }
                            //
                            //       setState(() {
                            //         loading = false;
                            //       });
                            //     },
                            //     child: Container(
                            //       margin: EdgeInsets.only(top: 30),
                            //       padding: EdgeInsets.symmetric(
                            //           horizontal: 20, vertical: 5),
                            //       decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(30),
                            //           border: Border.all(
                            //             color: Style.indigo,
                            //             width: 2.0,
                            //           ),
                            //           color: Colors.white),
                            //       child: Text(
                            //         widget.club.followers.contains(
                            //                 Get.find<UserController>().user.uid)
                            //             ? "Unfollow"
                            //             : "Follow",
                            //         style: TextStyle(
                            //             fontSize: 18,
                            //             color: Style.indigo,
                            //             fontFamily: "InterSemiBold"),
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                      SizedBox(
                        height: 30,
                      ),
//up next
                      Text(
                        "Up next",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: FutureBuilder(
                            future: Database.getClubUpcomingRooms(widget.club),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data != null &&
                                  snapshot.data.length > 0) {
                                List<UpcomingRoom> rooms = snapshot.data;
                                return PageView.builder(
                                    itemCount: rooms.length,
                                    onPageChanged: (int index) =>
                                        setState(() => _index = index),
                                    itemBuilder: (_, i) {
                                      UpcomingRoom room = rooms[_index];

                                      return Transform.scale(
                                        scale: i == _index ? 1 : 0.9,
                                        child: InkWell(
                                            onTap: () {
                                              upcomingroomBottomSheet(
                                                  context, room, false, false);
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    (room.publisheddate != null
                                                        ? Functions
                                                            .timeFutureSinceDate(
                                                                timestamp: room
                                                                    .eventdate)
                                                        : ""),
                                                    style: TextStyle(
                                                      color: Style.DarkBrown,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  room.title,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontFamily:
                                                          "InterSemiBold"),
                                                ),
                                                Column(
                                                  children: [
                                                    room.users.length == 0
                                                        ? Container()
                                                        : Container(
                                                            height: 43,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 8),
                                                            child: ListView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              children: room
                                                                  .users
                                                                  .map((e) =>
                                                                      RoundImage(
                                                                        url: e
                                                                            .smallimage,
                                                                        txt: e
                                                                            .username,
                                                                        txtsize:
                                                                            12,
                                                                        width:
                                                                            45,
                                                                        height:
                                                                            45,
                                                                      ))
                                                                  .toList(),
                                                            ),
                                                          ),
                                                    room.users.length == 0
                                                        ? Container()
                                                        : Container(
                                                            child: Wrap(
                                                              children: room
                                                                  .users
                                                                  .map(
                                                                      (e) =>
                                                                          Text(
                                                                            e.firstname +
                                                                                " " +
                                                                                e.lastname +
                                                                                ", ",
                                                                            style:
                                                                                TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
                                                                          ))
                                                                  .toList(),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ],
                                            )),
                                      );
                                    });

                                // Wrap(
                                //   children: _buildPageIndicator(rooms).toList(),
                                // )
                              } else {
//dotted border
                                return DottedBorder(
                                    color: Colors.grey,
                                    strokeWidth: 1,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
//calendar icon
                                          Icon(
                                            CupertinoIcons.calendar_badge_minus,
                                            size: 28,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "This club has no scheduled rooms",
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.black54),
                                          )
                                        ],
                                      ),
                                    ),
                                    borderType: BorderType.RRect,
                                    radius: Radius.circular(20),
                                    dashPattern: [6, 3, 2, 3]);
                              }
                            }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: widget.club.topics.length > 0 ? 20 : 0,
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: widget.club.topics
                              .map((e) => Center(
                                    child: Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Text(
                                        e.title + ",",
                                        style: TextStyle(
                                            fontFamily: "InterSemiBold",
                                            color: Colors.black),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      if (widget.club.description.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "About",
                              style: TextStyle(color: Colors.black),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            descriptionHere(),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 5,
                      ),
                      if(widget.club.id != MAIN_CLUB_ID)
                      if (widget.club.membersprivate == false)
                        ClubMembersSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  tabs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // give the tab bar a height [can change hheight to preferred height]
        Expanded(
          child: Container(
            height: 35,
            child: TabBar(
              indicatorColor: Style.indigo,
              indicatorWeight: 3,
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              onTap: (index) {
                setState(() {
                  tabindex = index;
                });
              },
              tabs: [
                // first tab [you can add an icon using the icon property]
                Tab(
                  child: Text(
                    "Member",
                    style: TextStyle(
                        fontFamily: "InterSemiBold",
                        fontSize: 15,
                        color: Colors.black),
                  ),
                ),
                // first tab [you can add an icon using the icon property]
                Tab(
                  child: Text(
                    "Followers",
                    style: TextStyle(
                        fontFamily: "InterSemiBold",
                        fontSize: 15,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: TabBarView(
              controller: _tabController,
              children: [
                // first tab bar view widget
                Container(
                  height: 100,
                  margin: EdgeInsets.only(top: 10),
                  child: FutureBuilder(
                      future: Database.getusersInaClub(widget.club),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          List<UserModel> users = snapshot.data;
                          return ListView.separated(
                            separatorBuilder: (c, i) {
                              return Container(
                                height: 15,
                              );
                            },
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return singleItem(users[index]);
                            },
                          );
                        } else {
                          return Container();
                        }
                      }),
                ),
                // first tab bar view widget
                Container(
                  height: 100,
                  child: FutureBuilder(
                      future: Database.getClubFollowers(widget.club),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          List<UserModel> users = snapshot.data;
                          return ListView.separated(
                            separatorBuilder: (c, i) {
                              return Container(
                                height: 15,
                              );
                            },
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return singleItem(users[index]);
                            },
                          );
                        } else {
                          return Container();
                        }
                      }),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
// members names
  Widget singleItem(UserModel user) {
    return Container(
      child: Row(
        children: [
          UserProfileImage(
            user: user,
            txtsize: 12,
            txt: user.username,
            width: 45,
            height: 45,
            borderRadius: 20,
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text(
                    user.getName(),
                    textScaleFactor: 1,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Text(user.bio,
                    textScaleFactor: 1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          SizedBox(
            width: 16,
          ),
          if (Get.find<UserController>().user != null &&
              Get.find<UserController>().user.uid != user.uid)
            TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Style.Blue,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  Get.find<UserController>().user.following.contains(user.uid)
                      ? "Following"
                      : "Follow",
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: Style.Blue,
                  ),
                ),
              ),
              onPressed: () {
                if (Get.find<UserController>()
                    .user
                    .following
                    .contains(user.uid)) {
                  Database().unFolloUser(user.uid);
                } else {
                  Database().folloUser(user);
                }
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  addBio() {
    var biocontroller = TextEditingController();

    biocontroller.text = widget.club.description;

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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Update description for ${widget.club.title}",
                        style: TextStyle(fontSize: 21),
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
                          controller: biocontroller,
                          maxLength: null,
                          maxLines: 20,
                          decoration: InputDecoration(
                              hintStyle: TextStyle(
                                fontSize: 20,
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              fillColor: Colors.white),
                          keyboardType: TextInputType.text,
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
                        text: "Done",
                        color: Style.AccentBlue,
                        onPressed: () {
                          Navigator.pop(context);
                          Database.updateClub(clubid,
                              {"description": biocontroller.text});
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

  Widget descriptionHere() {
    return Text(widget.club.description, style: TextStyle(color: Colors.black));
  }

  ClubMembersSection() {
    return Column(
      children: [
        // if (widget.club.allowfollowers == true) tabs(),
        // if (widget.club.allowfollowers == false)
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.club.members.length} Members",
              style: TextStyle(color: Style.AccentGrey),
            ),
            SizedBox(
              height: 5,
            ),
            Divider(
              thickness: 1,
              color: Style.AccentBlue,
            ),
            SizedBox(
              height: 10,
            ),
            // if (widget.club.members.length < 20)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (c, i) {
                return Container(
                  height: 15,
                );
              },
              itemCount: _allUsers.length,
              itemBuilder: (context, index) {
                return singleItem(_allUsers[index]);
              },
            ),
          ],
        ),
      ],
    );
  }
}
