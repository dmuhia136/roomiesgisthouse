import 'dart:convert';

import 'package:gisthouse/services/database_api/util/db_base.dart';

import 'util/db_utils.dart';

class UpcomingRoomApi {
  getAllUpcoming() async {
    var upcoming =
    await DbBase().databaseRequest(ALL_UPCOMING, DbBase().getRequestType);
    return await jsonDecode(upcoming);
  }

  getAllUpcomingWithLimit(String limit) async {
    var upcoming =
    await DbBase().databaseRequest(ALL_UPCOMING_WITH_LIMIT + limit, DbBase().getRequestType);
    return await jsonDecode(upcoming);
  }

  getUpcomingById(String id) async {
    var upcoming = await DbBase()
        .databaseRequest(UPCOMING_BY_ID + id, DbBase().getRequestType);
    return await jsonDecode(upcoming);
  }

  getUpcomingForUser(String id) async {
    var upcoming = await DbBase()
        .databaseRequest(UPCOMING_FOR_USER + id, DbBase().getRequestType);
    return await jsonDecode(upcoming);
  }

  getUpcomingForUserWithLimit(String id, String limit) async {
    var upcoming = await DbBase().databaseRequest(
        UPCOMING_FOR_USER_LIMIT + id + "/" + limit, DbBase().getRequestType);
    return await jsonDecode(upcoming);
  }

  getUpcomingForClub(String id) async {
    var upcoming = await DbBase()
        .databaseRequest(UPCOMING_FOR_CLUB + id, DbBase().getRequestType);
    return await jsonDecode(upcoming);
  }

  getUpcomingForClubWithLimit(String id, String limit) async {
    var upcoming = await DbBase().databaseRequest(
        UPCOMING_FOR_CLUB_LIMIT + id + "/" + limit, DbBase().getRequestType);
    return await jsonDecode(upcoming);
  }

  saveUpcoming(Map<String, dynamic> body) async {

    var savedRoom = await DbBase()
        .databaseRequest(SAVE_UPCOMING, DbBase().postRequestType, body: body);
    return savedRoom;
  }

  updateUpcoming(Map<String, dynamic> body, String id) async {
    try {
      await DbBase().databaseRequest(
          UPDATE_UPCOMING + id, DbBase().patchRequestType,
          body: body);

    } catch (e) {
    }
  }

  addNotifiedUpcoming(String toBeNotifiedId, String roomId) async {
    try {
      var body = {"uid": toBeNotifiedId};

      await DbBase().databaseRequest(
          ADD_NOTIFIED_UPCOMING + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  removeNotifiedUpcoming(String toBeNotifiedId, String id) async {
    try {
      var body = {"uid": toBeNotifiedId};

      await DbBase().databaseRequest(
          REMOVE_NOTIFIED_UPCOMING + id, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  deleteUpcoming(String id) async {
    try {
      await DbBase()
          .databaseRequest(DELETE_UPCOMING + id, DbBase().deleteRequestType);
    } catch (e) {
    }
  }
}
