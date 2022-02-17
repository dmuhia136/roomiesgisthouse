import 'dart:convert';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:gisthouse/controllers/user_controller.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database_api/util/db_base.dart';
import 'package:gisthouse/services/database_api/util/db_utils.dart';

class UserApi {
  getAllUsers() async {
    var users =
        await DbBase().databaseRequest(ALL_USERS, DbBase().getRequestType);
    return await jsonDecode(users);
  }

  getAllUsersAfter(String lastUserId) async {

    var body = {
      "id": lastUserId
    };

    var users =
    await DbBase().databaseRequest(ALL_USERS_AFTER, DbBase().getRequestType, body: body);
    return await jsonDecode(users);
  }

  getAllUsersWithLimit(String limit) async {
    var users = await DbBase()
        .databaseRequest(ALL_USERS_WITH_LIMIT + limit, DbBase().getRequestType);
    return await jsonDecode(users);
  }

  getUserById(String id) async {
    var user = await DbBase()
        .databaseRequest(USER_BY_ID + id, DbBase().getRequestType);
    return await jsonDecode(user);
  }

  getUserByPhone(String phone) async {

    var user = await DbBase()
        .databaseRequest(USER_BY_PHONE + phone, DbBase().getRequestType);
    return await jsonDecode(user);
  }

  getUserByCountry(String country) async {
    var user = await DbBase().databaseRequest(
        USER_BY_COUNTRY + country, DbBase().getRequestType,
        body: {"myid": Get.find<UserController>().user.uid});
    return await jsonDecode(user);
  }

  getUserByFirstname(String firstname) async {
    var user = await DbBase().databaseRequest(
        USER_BY_FIRSTNAME + firstname, DbBase().getRequestType);
    return await jsonDecode(user);
  }

  getUserByUsername(String username) async {
    var user = await DbBase()
        .databaseRequest(USER_BY_USERNAME + username, DbBase().getRequestType);
    return await jsonDecode(user);
  }

  searchUserByFirstname(String firstname) async {
    var user = await DbBase().databaseRequest(
        SEARCH_USER_BY_FIRSTNAME + firstname, DbBase().getRequestType);
    return await jsonDecode(user);
  }

  getUserFollowersToNotify(String id) async {
    var followers = await DbBase().databaseRequest(
        USER_FOLLOWERS_TO_NOTIFY + id, DbBase().getRequestType);
    return await jsonDecode(followers);
  }

  getUserFollowers(String id) async {
    var followers = await DbBase()
        .databaseRequest(USER_FOLLOWERS + id, DbBase().getRequestType);
    return await jsonDecode(followers);
  }

  getUserFollowersAfter(String id, String lastId) async {
    var body = {
      "lastid": lastId,
      "myid": id
    };
    var followers = await DbBase()
        .databaseRequest(USER_FOLLOWERS_AFTER, DbBase().getRequestType, body: body);
    return await jsonDecode(followers);
  }

  getUserFollowing(String id) async {
    var following = await DbBase()
        .databaseRequest(USER_FOLLOWING + id, DbBase().getRequestType);
    return await jsonDecode(following);
  }

  getUserFollowingAfter(String id, String lastId) async {
    var body = {
      "lastid": lastId,
      "myid": id
    };
    var following = await DbBase()
        .databaseRequest(USER_FOLLOWING_AFTER, DbBase().getRequestType, body: body);
    return await jsonDecode(following);
  }

  getUserMutualFollowers(String id) async {
    var mutualFollowers = await DbBase()
        .databaseRequest(USER_MUTUAL_FOLLOWER + id, DbBase().getRequestType);
    return await jsonDecode(mutualFollowers);
  }

  getOnlineFriends(String id) async {
    var onlineFriends = await DbBase()
        .databaseRequest(ONLINE_FRIENDS + id, DbBase().getRequestType);
    return await jsonDecode(onlineFriends);
  }

  saveUser(String id, Map<String, dynamic> body) async {
    try{
      await DbBase().databaseRequest(SAVE_USER + id, DbBase().postRequestType, body: body);
    } catch (e) {
    }
  }

  updateUser(Map<String, dynamic> body, String id) async {

    try{
      await DbBase().databaseRequest(UPDATE_USER + id, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  followUser(String userToFollowId) async {
    UserModel user = Get.find<UserController>().user;
    var body = {
      "myid": user.uid,
      "myfullname": user.getName(),
      "myimageurl": user.profileImage,
    };

    await DbBase().databaseRequest(
        FOLLOW_USER + userToFollowId, DbBase().patchRequestType,
        body: body);
  }

  unFollowUser(String userToUnFollowId) async {
    UserModel user = Get.find<UserController>().user;
    var body = {
      "myid": user.uid,
    };

    await DbBase().databaseRequest(
        UNFOLLOW_USER + userToUnFollowId, DbBase().patchRequestType,
        body: body);
  }

  addInterestForUser(String interest) async {
    var body = {"interest": interest};

    await DbBase().databaseRequest(
        ADD_INTEREST + Get.find<UserController>().user.uid,
        DbBase().patchRequestType,
        body: body);
  }

  removeInterestForUser(String interest) async {
    var body = {"interest": interest};

    await DbBase().databaseRequest(
        REMOVE_INTEREST + Get.find<UserController>().user.uid,
        DbBase().patchRequestType,
        body: body);
  }

  blockUser(String id) async {
    var body = {"uid": id};

    await DbBase().databaseRequest(
        BLOCK_USER + Get.find<UserController>().user.uid,
        DbBase().patchRequestType,
        body: body);
  }

  unBlockUser(String id) async {
    var body = {"uid": id};

    await DbBase().databaseRequest(
        UNBLOCK_USER + Get.find<UserController>().user.uid,
        DbBase().patchRequestType,
        body: body);
  }

  addPaidRoom(String roomId) async {
    try {
      var body = {"room": roomId};

      await DbBase().databaseRequest(
          ADD_PAID_ROOM + roomId, DbBase().patchRequestType,
          body: body);
    } catch (e) {
    }
  }

  deleteUser() async {
    await DbBase().databaseRequest(
        DELETE_USER + Get.find<UserController>().user.uid,
        DbBase().deleteRequestType);
  }
}
