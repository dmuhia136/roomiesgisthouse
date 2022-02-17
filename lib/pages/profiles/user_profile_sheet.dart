import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/models/room_user.dart';
import 'package:gisthouse/pages/chats/chat_screen.dart';
import 'package:gisthouse/pages/profiles/following_followers.dart';
import 'package:gisthouse/pages/profiles/view_big_image.dart';
import 'package:gisthouse/pages/profiles/widgets/user_actions.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/ongoingroom_api.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/frosted_container.dart';
import 'package:gisthouse/widgets/widgets.dart';

class UserProfileSheet extends StatefulWidget {
  List<RoomUser> allusers;
  RoomUser thisprofileuser;
  String thisprofileuseruid;
  RoomUser currentuser;
  final bool isMe;
  final Room room;
  final Function() openPage;

  UserProfileSheet(
      {this.currentuser,
      this.thisprofileuseruid,
      this.thisprofileuser,
      this.allusers,
      this.openPage,
      this.room,
      this.isMe});

  @override
  _UserProfileSheetState createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends State<UserProfileSheet> {
  UserModel thisprofileuser;
  UserModel currentuser;
  bool loading = true;
  int currentuserindex;

  addBio(BuildContext context) {
    var biocontroller = TextEditingController();

    biocontroller.text = thisprofileuser.bio;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Style.LightBrown,
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
                  padding: EdgeInsets.only(right: 20, left: 20, top: 30),
                  child: Column(
                    children: [
                      Text(
                        "Update your bio",
                        style: TextStyle(fontSize: 21, color: Colors.black,
                          letterSpacing: 0.6
                        ),
                      ),
                      SizedBox(
                        height: 30,
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
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
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
                        color: Style.Blue,
                        onPressed: () {
                          Navigator.pop(context);
                          Database.updateProfileData(
                              thisprofileuser.uid, {"bio": biocontroller.text});
                          Get.find<UserController>().user.bio =
                              biocontroller.text;
                          setState(() {});
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.allusers != null) {
      currentuserindex = widget.allusers
          .indexWhere((element) => element.uid == widget.thisprofileuser.uid);
      setState(() {});
    }
    getCurrentUserData();
  }

  getCurrentUserData() async {
    thisprofileuser = await Database.getUserProfile(
        widget.thisprofileuser == null
            ? widget.thisprofileuseruid
            : widget.thisprofileuser.uid);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    UserModel userModel = Get.find<UserController>().user;
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: loading == true
          ? Container(
              color: Style.LightBrown,
              child: CupertinoActivityIndicator(),
            )
          : Container(
              decoration: BoxDecoration(
                  color: Style.LightBrown,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )),
              child: Stack(
                children: [
                  FrostedContainer(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                              onTap: () {
                                userActionSheet(context,
                                    userModel: userModel,
                                    profile: thisprofileuser,
                                    userType: widget.thisprofileuser.usertype,
                                    room: widget.room,
                                    fromRoom: true);
                              },
                              child: Icon(Icons.more_horiz)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              children: [
                                InkWell(
                                  onTap: () {
                                    viewUserBigPhoto(
                                        context, thisprofileuser.smallimage);
                                  },
                                  child: RoundImage(
                                    url: thisprofileuser.smallimage,
                                    txtsize: 35,
                                    txt: thisprofileuser.firstname,
                                    width: 90,
                                    height: 90,
                                    borderRadius: 70,
                                  ),
                                ),
                                if (widget.isMe == false &&
                                    widget.currentuser != null &&
                                    (widget.currentuser.usertype ==
                                            "moderator" ||
                                        widget.currentuser.usertype ==
                                            "host") &&
                                    (widget.thisprofileuser.usertype ==
                                            "moderator" ||
                                        widget.thisprofileuser.usertype ==
                                            "host" ||
                                        widget.thisprofileuser.usertype ==
                                            "speaker"))
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        Database.callMuteUnmute(widget.room,
                                            currentuserindex, widget.allusers);
                                        widget.allusers[currentuserindex]
                                                .callmute =
                                            !widget.allusers[currentuserindex]
                                                .callmute;
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0XFF00FFB0),
                                        ),
                                        child: widget.allusers[currentuserindex]
                                                    .callmute ==
                                                true
                                            ? const Icon(
                                                CupertinoIcons.mic_off,
                                                size: 20.0,
                                                color: Colors.black,
                                              )
                                            : const Icon(
                                                CupertinoIcons.mic_fill,
                                                size: 20.0,
                                                color: Colors.black,
                                              ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Get.back();
                                Get.to(() => FollowingFollowers(
                                    type: "followers",
                                    userid: thisprofileuser.uid));
                              },
                              child: Column(
                                children: [
                                  Text(
                                    thisprofileuser.following.length.toString(),
                                    style: TextStyle(
                                        fontFamily: "LucidaGrande",
                                        fontSize: 23),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Following",
                                    style: TextStyle(
                                        fontFamily: "LucidaGrande",
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.back();
                                Get.to(() => FollowingFollowers(
                                    type: "following",
                                    userid: thisprofileuser.uid));
                              },
                              child: Column(
                                children: [
                                  Text(
                                    thisprofileuser.followers.length.toString(),
                                    style: TextStyle(
                                        fontFamily: "LucidaGrande",
                                        fontSize: 23),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Followers",
                                    style: TextStyle(
                                        fontFamily: "LucidaGrande",
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          thisprofileuser.getName(),
                          style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              fontFamily: "LucidaGrande",
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.thisprofileuser.uid == userModel.uid &&
                                thisprofileuser.bio.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: InkWell(
                                  onTap: () {
                                    addBio(context);
                                  },
                                  child: Text(
                                    thisprofileuser.bio.isEmpty
                                        ? "Add a bio"
                                        : thisprofileuser.bio,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: thisprofileuser.bio.isEmpty
                                            ? Colors.blue
                                            : Colors.white),
                                  ),
                                ),
                              ),
                            if (thisprofileuser.bio.isNotEmpty)
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: InkWell(
                                    onTap: () {
                                      if (widget.isMe) addBio(context);
                                    },
                                    child: Text(
                                      thisprofileuser.bio,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontFamily: "LucidaGrande",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (!widget.isMe)
                              InkWell(
                                onTap: () {
                                  if (userModel.following
                                      .contains(widget.thisprofileuser.uid)) {
                                    userModel.following
                                        .remove(widget.thisprofileuser.uid);
                                    setState(() {});

                                    Database().unFolloUser(
                                        widget.thisprofileuser.uid);
                                  } else {
                                    userModel.following
                                        .add(widget.thisprofileuser.uid);
                                    setState(() {});
                                    Database().folloUser(thisprofileuser);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 17, vertical: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Style.Blue, width: 2),
                                      borderRadius: BorderRadius.circular(20),
                                      color: userModel.blocked.contains(
                                              widget.thisprofileuser.uid)
                                          ? Colors.yellow
                                          : Colors.transparent),
                                  child: Text(
                                    userModel.following.contains(
                                                widget.thisprofileuser.uid) ==
                                            true
                                        ? "UnFollow"
                                        : "follow",
                                    style: TextStyle(color: Style.Blue),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 24),
                        if (!widget.isMe)
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                if (widget.currentuser != null &&
                                    (widget.currentuser.usertype ==
                                            "moderator" ||
                                        widget.currentuser.usertype == "host"))
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      if (widget.thisprofileuser.usertype ==
                                          "others")
                                        Container(
                                          margin: EdgeInsets.only(bottom: 20),
                                          child: CustomButton(
                                            minimumWidth: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.grey[300],
                                            text: "Invite To Gist",
                                            txtcolor: Colors.black87,
                                            fontSize: 13,
                                            onPressed: () async {
                                              Navigator.pop(context);

                                              await OngoingRoomApi()
                                                  .addToInvitedUsersRoom(
                                                      widget.room.roomid,
                                                      widget
                                                          .thisprofileuser.uid);
                                            },
                                          ),
                                        ),
                                      if (widget.thisprofileuser.usertype ==
                                              "moderator" ||
                                          widget.thisprofileuser.usertype ==
                                              "speaker")
                                        Container(
                                          margin: EdgeInsets.only(bottom: 20),
                                          child: CustomButton(
                                            minimumWidth: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.grey[200],
                                            text: "Move to Audience",
                                            txtcolor: Colors.black,
                                            fontSize: 13,
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await Database.makeAudience(
                                                  userid: widget
                                                      .thisprofileuser.uid,
                                                  room: widget.room);
                                            },
                                          ),
                                        ),
                                      // if (widget.fromRoom == true)
                                      if (widget.thisprofileuser.usertype ==
                                              "speaker" &&
                                          widget.currentuser.usertype == "host")
                                        Container(
                                          margin: EdgeInsets.only(bottom: 20),
                                          child: CustomButton(
                                            minimumWidth: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.grey[200],
                                            text: "Make GistMod",
                                            txtcolor: Colors.black,
                                            fontSize: 13,
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              //join as a speaker
                                              await Database.joinasModerators(
                                                  userid: widget
                                                      .thisprofileuser.uid,
                                                  room: widget.room);
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
//message button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (widget.isMe == false)
                              MaterialButton(
                                onPressed: () {
                                  Get.back();
                                  Get.to(() => ChatPage(
                                        chatusers: [thisprofileuser],
                                        messagetype:
                                            Database.getMessageChatType(
                                                thisprofileuser.uid),
                                      ));
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                color: Colors.grey[300],
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.message_rounded,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Message")
                                  ],
                                ),
                                textColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                              ),
                            SizedBox(width: 15),
                            Expanded(
                              child: MaterialButton(
                                elevation: 0,
                                onPressed: widget.openPage,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                color: Colors.grey[300],
                                child: Text("View full profile"),
                                textColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
