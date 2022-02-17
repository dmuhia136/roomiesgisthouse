import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/models/room_user.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/pages/profiles/user_profile_sheet.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/round_image.dart';

import '../../../widgets/widgets.dart';

class RoomProfile extends StatefulWidget {
  final RoomUser thisprofileuser;
  final RoomUser currentuser;
  final List<RoomUser> allusers;
  final AnimationController animationController;
  final Room room;
  final double size;
  final Color bordercolor;
  final double opacity;


  const RoomProfile(
      {Key key,
      this.thisprofileuser,
      this.allusers,
      this.animationController,
      this.currentuser,
      this.room,
      this.size,
      this.bordercolor = const Color(0xFFFFFFFF),
        this.opacity = 1})
      : super(key: key);

  @override
  _RoomProfileState createState() => _RoomProfileState();
}

class _RoomProfileState extends State<RoomProfile> {
  bool short = true;

  Function listener(shor, set) {
    short = !shor;
    set(() {});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            InkWell(
              onTap: () => Sheet.open(
                  context,
                  UserProfileSheet(
                    isMe: widget.thisprofileuser.uid ==
                        Get.find<UserController>().user.uid,
                    thisprofileuser: widget.thisprofileuser,
                    currentuser: widget.currentuser,
                    openPage: () {
                      return Sheet.open(
                          context,
                          ProfilePage(
                              userid: widget.thisprofileuser.uid,
                              isMe: widget.currentuser.uid ==
                                  Get.find<UserController>().user.uid));
                    },
                    room: widget.room,
                    allusers: widget.allusers
                  )),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: widget.bordercolor ?? Color(0xFFFFFFFF),
                      width:
                          widget.thisprofileuser.usertype == "others" ? 0 : 5),
                  borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(widget.size / 2 - widget.size / 30),
                      topRight:
                          Radius.circular(widget.size / 2 - widget.size / 30),
                      bottomRight:
                          Radius.circular(widget.size / 2 - widget.size / 30),
                      bottomLeft:
                          Radius.circular(widget.size / 2 - widget.size / 30)),
                ),
                child: RoundImage(
                  url: widget.thisprofileuser.imageurl,
                  txt: widget.thisprofileuser.firstname,
                  width: widget.size,
                  height: widget.size,
                  txtsize: 21,
                  borderRadius: 30,
                  opacity: widget.opacity,
                ),
              ),
            ),
            // buildNewBadge(widget.user.isNewUser),
            if (widget.thisprofileuser.usertype != "others")
              buildMuteBadge(widget.thisprofileuser.callmute),
            if (widget.thisprofileuser.usertype == "host")
              buildModeratorBadge(false),

            if (widget.thisprofileuser.usertype == "moderator")
              buildModeratorBadge(true)
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Center(
          child: Text(
            widget.thisprofileuser.firstname,
            style: TextStyle(color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget buildModeratorBadge(bool isModerator) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: isModerator ? Style.AccentRed : Style.AccentGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Icon(
        Icons.star,
        color: Colors.white,
        size: 12,
      ),
    );
  }

  Widget buildMuteBadge(bool isMute) {
    return Positioned(
      right: 0,
      top: 0,
      child: isMute
          ? Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  // shape: BoxShape.circle,
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(
                CupertinoIcons.speaker_slash,
                size: 15,
                color: Colors.red,
              ),
            )
          : Container(),
    );
  }

  Widget buildNewBadge(bool isNewUser) {
    return Positioned(
      left: 0,
      bottom: 0,
      child: isNewUser
          ? Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Text(
                '🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          : Container(),
    );
  }
}
