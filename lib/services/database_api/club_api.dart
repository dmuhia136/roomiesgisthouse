import 'dart:convert';

import 'package:get/get.dart';
import 'package:gisthouse/controllers/user_controller.dart';
import 'package:gisthouse/models/club.dart';
import 'package:gisthouse/models/models.dart';

import 'util/db_base.dart';
import 'util/db_utils.dart';

class ClubApi {

  getAllClubs() async {

   return await jsonDecode( await DbBase().databaseRequest(ALL_CLUBS, DbBase().getRequestType));
  }

  getClubsAfterAnother(Club lastClub) async {
    var body = {
      "id": lastClub.id,
      "title": lastClub.title
    };
    return await jsonDecode( await DbBase()
        .databaseRequest(ALL_CLUBS_AFTER, DbBase().getRequestType, body: body));

  }

  getClubsById(String id) async {

    var clubs = await DbBase()
        .databaseRequest(CLUB_BY_ID + id, DbBase().getRequestType);
    return Club.fromJson(await jsonDecode(clubs));
  }

  getClubsByTitle(String title) async {

    var clubs = await DbBase()
        .databaseRequest(CLUB_BY_TITLE + title, DbBase().getRequestType);
    return clubs;
  }

  searchClubsByTitle(String title) async {

    var clubs = await DbBase()
        .databaseRequest(SEARCH_CLUB_BY_TITLE + title, DbBase().getRequestType);
    return await jsonDecode(clubs);
  }

  userClubs(String uid) async {
    var clubs = await DbBase()
        .databaseRequest(CLUB_USER_MEMBER + uid, DbBase().getRequestType);
    return jsonDecode(clubs);
  }

  getClubMembers(String id) async {
    var clubs = await DbBase()
        .databaseRequest(CLUB_MEMBERS + id, DbBase().getRequestType);
    return await jsonDecode(clubs);
  }

  getClubMembersAfter(String id, int memberSince) async {

    var body = {
      "id": id,
      "membersince": memberSince
    };
    var clubs = await DbBase()
        .databaseRequest(CLUB_MEMBERS_AFTER, DbBase().getRequestType, body: body);
    return await jsonDecode(clubs);
  }

  getClubFollowers(String id) async {
    try {
      var clubs = await DbBase()
          .databaseRequest(CLUB_FOLLOWERS + id, DbBase().getRequestType);
      return clubs;
    } catch (e) {
    }
  }

  saveClub(Map<String, dynamic> body, String userId) async {

    var savedClubId = await DbBase()
        .databaseRequest(SAVE_CLUB, DbBase().postRequestType, body: body);

    return savedClubId;

  }

  updateClub(Map<String, dynamic> body, String id) async {
    try {
      await DbBase()
          .databaseRequest(UPDATE_CLUB + id, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  inviteToClub(Club club, UserModel invitedUser) async {
    try {

      var body = {
        "clubid": club.id,
        "clubame": club.title,
        "usertoken": invitedUser.firebasetoken,
        "invitername": Get.find<UserController>().user.firstname,
        "inviterimageurl": Get.find<UserController>().user.profileImage
      };

      await DbBase()
          .databaseRequest(INVITE_USER_CLUB + invitedUser.uid, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  acceptInviteClub(String clubId, String userId) async {
    try {

      var body = {
        "uid": userId
      };

      await DbBase()
          .databaseRequest(ACCEPT_INVITE_USER_CLUB + clubId, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  joinClub(String clubId, String userId) async {
    try {

      var body = {
        "uid": userId
      };

      await DbBase()
          .databaseRequest(JOIN_CLUB + clubId, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  joinAsOwnerOfClub(String clubId, String userId) async {
    try {

      var body = {
        "userId": userId
      };

      await DbBase()
          .databaseRequest(JOIN_AS_OWNER_CLUB + clubId, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  followClub(String clubId, String userId) async {
    try {

      var body = {
        "uid": userId
      };

      await DbBase()
          .databaseRequest(FOLLOW_CLUB + clubId, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  unFollowClub(String clubId, String userId) async {
    try {

      var body = {
        "uid": userId
      };

      await DbBase()
          .databaseRequest(UNFOLLOW_CLUB + clubId, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  leaveClub(String clubId, String userId) async {
    try {

      var body = {
        "uid": userId
      };

      await DbBase()
          .databaseRequest(LEAVE_CLUB + clubId, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  addTopicClub(String clubId, Map<String, dynamic> body) async {
    try {
      await DbBase()
          .databaseRequest(ADD_TOPIC_CLUB + clubId, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  removeTopicClub(String clubId, Map<String, dynamic> body) async {
    try {
      await DbBase()
          .databaseRequest(REMOVE_TOPIC_CLUB + clubId, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  addRoomForClub(String clubId, String roomId) async {
    try {

      var body = {
        "roomid": roomId
      };

      await DbBase()
          .databaseRequest(ADD_ROOM_CLUB + clubId, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  removeRoomForClub(String clubId, String roomId) async {
    try {

      var body = {
        "roomid": roomId
      };

      await DbBase()
          .databaseRequest(REMOVE_ROOM_CLUB + clubId, DbBase().patchRequestType, body: body);
    } catch (e) {
    }
  }

  deleteClub(String clubId) async {
    try {

      await DbBase()
          .databaseRequest(DELETE_CLUB + clubId, DbBase().deleteRequestType);
    } catch (e) {
    }
  }

}
