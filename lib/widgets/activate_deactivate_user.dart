
//add user to speaker
//remove user from being speaker
import 'package:flutter/material.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/models/room_user.dart';
import 'package:gisthouse/services/database.dart';

void activateDeactivateUser(RoomUser user, Room room, StateSetter setState, List<RoomUser> raisedhandsusers) {
  if (room.raisedhands.indexWhere((element) => element == user.uid) ==
      -1) {
    //user ha already removed his hand
    setState(() {});
  } else {

    // engine.setClientRole(ClientRole.Broadcaster);
    Database.updateroomuser(room.roomid, user.uid, data: {
      "usertype": "speaker"
    });

    Database.removeUserFromRaisedHands(userid: user.uid, roomid: room.roomid);
    setState(() {});
  }

}