import 'dart:convert';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:gisthouse/controllers/user_controller.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/services/database_api/util/db_base.dart';

import 'util/db_utils.dart';

class OngoingRoomApi {
  getAllRooms() async {
    var rooms =
    await DbBase().databaseRequest(ALL_ROOMS, DbBase().getRequestType);
    return jsonDecode(rooms);
  }

  getRoomById(String id) async {
    var rooms = await DbBase()
        .databaseRequest(ROOM_BY_ID + id, DbBase().getRequestType);
    if(rooms.toString().isEmpty) {
      return null;
    } else{
      return await jsonDecode(rooms);
    }

  }

  getRoomsCombined(String uid, List<String> following) async {
    var rooms = await DbBase()
        .databaseRequest(ALL_ROOMS_COMBINED + uid, DbBase().getRequestType, body: {"following": following});

    return jsonDecode(rooms);
  }

  getPrivateRooms(String userId) async {
    var rooms = await DbBase()
        .databaseRequest(PRIVATE_ROOMS + userId, DbBase().getRequestType);
    return jsonDecode(rooms);
  }

  getPublicRooms() async {
    var rooms =
    await DbBase().databaseRequest(PUBLIC_ROOMS, DbBase().getRequestType);
    return jsonDecode(rooms);
  }

  getOpenClubRooms() async {
    var rooms = await DbBase()
        .databaseRequest(CLUB_ROOMS_OPEN, DbBase().getRequestType);
    return jsonDecode(rooms);
  }

  getClosedClubRooms(String userId) async {
    var rooms = await DbBase()
        .databaseRequest(CLUB_ROOMS_CLOSED + userId, DbBase().getRequestType);
    return jsonDecode(rooms);
  }

  getSocialRooms(followers) async {
    var rooms = await DbBase()
        .databaseRequest(SOCIAL_ROOMS, DbBase().getRequestType, body: {"followers": followers});
    return jsonDecode(rooms);
  }

  getRaisedHands(String id) async {
    var rooms =
    await DbBase().databaseRequest(RAISED_HANDS + id, DbBase().getRequestType);
    return await jsonDecode(rooms);
  }

  getRoomAllUsers(String roomId) async {
    var rooms = await DbBase()
        .databaseRequest(ROOM_ALL_USERS + roomId, DbBase().getRequestType);
    return await jsonDecode(rooms);
  }

  getRoomUserById(String roomId, String userId) async {
    var rooms = await DbBase()
        .databaseRequest(ROOM_USER_BY_ID + roomId, DbBase().getRequestType, body: {"uid": userId});
    return jsonDecode(rooms);
  }

  saveRoom(Map<String, dynamic> roomData, String roomId, {List<String> toNotify}) async {

    var body = {
      "room": roomData,
      "owner": Get.find<UserController>().user.toMap(),
      "notify": toNotify
    };

    try {
      await DbBase().databaseRequest(SAVE_ROOM + roomId, DbBase().postRequestType, body: body);
    } catch (e) {
      Functions.debug(e);
    }
  }

  updateRoom(Map<String, dynamic> body, String id) async {
    try {
      await DbBase()
          .databaseRequest(UPDATE_ROOM + id, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  addRaisedHands(String userId, String roomId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          ADD_RAISED_HANDS + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  removeRaisedHands(String userId, String roomId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          REMOVE_RAISED_HANDS + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  addUserToRoom(Map<String, dynamic> user, String roomId) async {
    try {
      await DbBase().databaseRequest(
          (ADD_USER_ROOM + roomId), DbBase().patchRequestType,
          body: user);
    } catch (e) {

    }
  }

  removeUserFromRoom(String userId, String roomId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          REMOVE_USER_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  updateUserInRoom(
      Map<String, dynamic> user, String roomId, String userId) async {
    try {
      await DbBase().databaseRequest(
          UPDATE_USER_ROOM + roomId + "/" + userId, DbBase().patchRequestType,
          body: user);
    } catch (e) {
    }
  }

  removeAllUsersInRoom(String roomId) async {
    try {
      await DbBase().databaseRequest(
          REMOVE_ALL_USER_ROOM + roomId, DbBase().patchRequestType);
    } catch (e) {
    }
  }

  addToRemovedUsersRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          ADD_TO_REMOVED_USERS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  removeFromRemovedUsersRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          REMOVE_FROM_REMOVED_USERS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  addToActiveModeratorsRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          ADD_ACTIVE_MODERATORS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  removeFromActiveModeratorsRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          REMOVE_ACTIVE_MODERATORS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  addToAllModeratorsRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          ADD_MODERATORS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  removeFromAllModeratorsRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          REMOVE_MODERATORS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  addToInvitedModeratorsRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          ADD_INVITED_MODERATORS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  removeFromInvitedModeratorsRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          REMOVE_INVITED_MODERATORS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  addToInvitedUsersRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          ADD_INVITED_USERS_ROOM + roomId, DbBase().patchRequestType,
          body: body);

      await removeRaisedHands(userId, roomId);
    } catch (e) {
    }
  }

  removeFromInvitedUsersRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          REMOVE_INVITED_USERS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  addToSpeakersRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          ADD_SPEAKERS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  removeFromSpeakersRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          REMOVE_SPEAKERS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  addToClubMembersRoom(String roomId, String userId) async {
    try {
      var body = {"uid": userId};

      await DbBase().databaseRequest(
          ADD_CLUB_MEMBERS_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  deleteRoom(String roomId) async {
    try {
      await DbBase()
          .databaseRequest(DELETE_ROOM + roomId, DbBase().deleteRequestType);
    } catch (e) {
    }
  }
}