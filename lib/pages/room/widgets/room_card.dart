import 'package:flutter/rendering.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/models/room.dart';
import 'package:gisthouse/models/room_user.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/round_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gisthouse/widgets/widgets.dart';

import '../../../util/style.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final List users;
  final bool homepage;

  const RoomCard({Key key, this.room, this.users, this.homepage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: Offset(0, 1),
            )
          ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [

                if (room.sponsors.isNotEmpty)Container(
                      child: Text(
                        "Sponsored".toUpperCase(),
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Style.AccentBlue)),
                if (homepage == true) buildRoomInfo(users),

                if (room.amount > 0)Container(
                    child: Text(
                      "Premium".toUpperCase(),
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    margin: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Style.AccentBlue)),
              ],
            ),

            // roomTitle(room),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     // if(room.title.isNotEmpty)Flexible(
            //     //   child: roomTitle(room),
            //     // ),
            //     roomTitle(room),
            //     if (room.roomtype == "closed")
            //       IconButton(
            //           onPressed: () {}, iconSize: 20, icon: Icon(Icons.lock)),
            //     if (room.roomtype == "social")
            //       IconButton(
            //           onPressed: () {}, iconSize: 20, icon: Icon(CupertinoIcons.circle_grid_hex_fill)),
            //     if (room.roomtype == "paid")
            //       IconButton(
            //           onPressed: () {}, iconSize: 20, icon: Icon(CupertinoIcons.briefcase_fill)),
            //       // Ticket(room.amount, room.currency),
            //   ],
            // ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 35,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: users
                    .map((e) => e.username == null
                        ? Container()
                        : RoundImage(
                            margin: EdgeInsets.only(right: 10),
                            txt: e.firstname,
                            url: e.imageurl,
                            txtsize: 10,
                            width: 35,
                            height: 35,
                          ))
                    .toList(),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            RoomTitle(room, context,homepage: homepage),
            // if(homepage ==true) Row(
            //   children: [
            //     roomTitle(room,context),
            //     buildRoomInfo(users),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildRoomInfo(List<RoomUser> users) {
    return Row(
      children: [
        Text(
          '${users.where((element) => element.usertype == "others").length}',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        Icon(
          Icons.supervisor_account,
          color: Colors.black87,
          size: 14,
        ),
        Text(
          '  /  ',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 10,
          ),
        ),
        Text(
          '${users.where((element) => element.usertype == "speaker" || element.usertype == "moderator" || element.usertype == "host").length}',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        Icon(
          CupertinoIcons.chat_bubble_text,
          color: Colors.black87,
          size: 14,
        ),
      ],
    );
  }
}
