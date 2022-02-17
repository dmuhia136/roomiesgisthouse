import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/clubs/view_club.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/pages/room/lounge_screen.dart';
import 'package:gisthouse/pages/room/room_screen.dart';
import 'package:gisthouse/pages/upcomingrooms/upcoming_roomsreen.dart';
import 'package:gisthouse/services/database_api/club_api.dart';
import 'package:gisthouse/services/database_api/ongoingroom_api.dart';
import 'package:gisthouse/services/database_api/upcoming_api.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_api/user_api.dart';

class DynamicLinkService {
  /*
    generate sharing dynamic link
   */
  Future<String> createGroupJoinLink(String groupId, [type]) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: deeplinkuriPrefix,
      link: Uri.parse(_createLink(groupId, type)),
      androidParameters: AndroidParameters(
        packageName: packagename,
      ),
      // NOT ALL ARE REQUIRED ===== HERE AS AN EXAMPLE =====
      iosParameters: IosParameters(
        bundleId: packagename,
        minimumVersion: '3.3',
        appStoreId: '1529768550',
      ),
    );
    final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
    return dynamicUrl.shortUrl.toString();
  }

  /*
      when link is clicked, this function handles the link and redirects user to the app if its installed
      or if its not installed its redirected to the website link attached to firebase dynamic links
   */
  Future handleDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    _handleDeepLink(data);

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          _handleDeepLink(dynamicLink);
        },
        onError: (OnLinkErrorException e) async {});
  }

  /*
      handle dynamic link redirection logic
   */
  Future<void> _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      if (FirebaseAuth.instance.currentUser == null &&
          deepLink.queryParameters['referer'] != null &&
          deepLink.queryParameters['referer'].isNotEmpty) {
        var refererId = deepLink.queryParameters['referer'];
        Get
            .find<OnboardingController>()
            .referrerid = refererId;
        //Save to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("referrerId", refererId);
        Get.back();
        return;
      }

      if (FirebaseAuth.instance.currentUser == null &&
          deepLink.queryParameters['type'] != "invite") {
        Get.back();
        return;
      }
      var groupid = deepLink.queryParameters['groupid'];
      Functions.debug(groupid);
      //check if the shared link is an upcoming room
      if (deepLink.queryParameters['type'] == "upcomingroom") {
        var roomFromApi = await OngoingRoomApi().getRoomById(groupid);
        if (roomFromApi != null) {
          Get.to(() => RoomScreen(roomid: groupid));
        } else {
          var upRoom = await UpcomingRoomApi().getUpcomingById(groupid);
          if (upRoom != null) {
            UpcomingRoom room = UpcomingRoom.fromJson(upRoom);
            Get.to(() => UpcomingRoomScreen(room: room));
          }
        }
      }
      //check if the shared link is an upcoming room
      else if (deepLink.queryParameters['type'] == "profile") {
        var user = await UserApi().getUserByUsername(groupid);
        var userModel = UserModel.fromJson(user);

        if (userModel != null) {
          Get.to(
                () =>
                ProfilePage(
                  profile: userModel,
                  fromRoom: false,
                ),
          );
        }
      }
      //check if the shared link is an club
      else if (deepLink.queryParameters['type'] == "club") {
        var value = ClubApi().getClubsById(groupid);
        Get.to(
              () => ViewClub(club: value),
        );
      } //Check if the shared link is a referral
      else if (deepLink.queryParameters['type'] == "invite") {
        var refererId = deepLink.queryParameters['referer'];
        Get
            .find<OnboardingController>()
            .referrerid = refererId;

        //Save to SharedPreferences
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString("referrerId", refererId);
      } else {
        var groupid = deepLink.queryParameters['groupid'];
        var roomFromApi = await OngoingRoomApi().getRoomById(groupid);

        if (roomFromApi != null) {
          Room room = Room.fromJson(roomFromApi);
          joinexistingroom(
              room: room,
              currentUser: Get
                  .find<UserController>()
                  .user,
              paidroom: room.amount > 0,
              context: GlobalKey<ScaffoldState>().currentContext);
          // if(room.amount > 0){
          //
          // }else{
          //   //leave any existing room
          //   await Database().leaveActiveRoom();
          //   //add user to a room
          //   await Database().addUserToRoom(
          //       room: room, user: Get.find<UserController>().user);
          //   Get.to(() => RoomScreen(
          //     roomid: groupid,
          //   ));
          // }

        }
      }
    }
  }



  saveReferrer(String referrerId) {
    //  zGet.find<OnboardingController>().referrerid = referrerId;
  }

  _createLink(String groupId, String type) {
    String link;
    String uid = Get.find<UserController>().user.uid;
    if (type == "invite") {
      link = '$websitedomain/?groupid=$groupId&type=$type&referer=$uid';
    } else {
      link = '$websitedomain/?groupid=$groupId&type=$type&referer=$uid';
    }
    return link;
  }
}
