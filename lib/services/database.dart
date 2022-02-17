import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import 'package:gisthouse/Notifications/push_nofitications.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/InboxItem.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/models/room_user.dart';
import 'package:gisthouse/pages/home/select_interests.dart';
import 'package:gisthouse/pages/onboarding/invite_only.dart';
import 'package:gisthouse/pages/onboarding/welcome_page.dart';
import 'package:gisthouse/pages/room/room_screen.dart';
import 'package:gisthouse/pages/upcomingrooms/upcoming_roomsreen.dart';
import 'package:gisthouse/services/authenticate.dart';
import 'package:gisthouse/services/cloud_functions.dart';
import 'package:gisthouse/services/database_api/activity_api.dart';
import 'package:gisthouse/services/database_api/club_api.dart';
import 'package:gisthouse/services/database_api/ongoingroom_api.dart';
import 'package:gisthouse/services/database_api/transaction_api.dart';
import 'package:gisthouse/services/database_api/upcoming_api.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:gisthouse/util/firebase_refs.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Notifications/push_nofitications.dart';
import '../util/firebase_refs.dart';
import 'database_api/auth_api.dart';

class Database {

  //get profile user data
  static  getUserProfile(String id) async {

    try {
      await AuthAPI().getToken();
    }catch(e){
      Functions.debug(e);
    }


    var user = await UserApi().getUserById(id);

    if(user == null) {
      return null;
    }

      return UserModel.fromJson(user);
  }

  //get profile user data
  Future<UserModel> getUserProfileByPhone(String phone) async {

    var user = await UserApi().getUserByPhone(phone);

      if (user != null) {
        UserModel userModel = UserModel.fromJson(user);
        return userModel;
      }
      return null;

  }

  //upload image to firebase store and then returns image url
  uploadImage(String id, {bool update = false}) async {
    UserModel user = Get.find<OnboardingController>().onboardingUser;
    if (user.imagefile != null) {
      String fileName = basename(user.imagefile.path);
      Reference firebaseSt = FirebaseStorage.instance.ref().child(
          'profile/${FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser.uid + "_" + fileName : fileName}');
      UploadTask uploadTask = firebaseSt.putFile(user.imagefile);

      await uploadTask.whenComplete(() async {
        String storagePath = await firebaseSt.getDownloadURL();
        user.smallimage = storagePath;
        user.profileImage = storagePath;
        if (update == true) {
          updateProfileData(FirebaseAuth.instance.currentUser.uid,
              {"imageurl": storagePath, "profileImage": storagePath});
          Get.find<UserController>().user.profileImage = storagePath;

        }
      });

      try {
        // Functions.debug('update ${Get.find<UserController>().user.imageurl}');
        //remove previous image
        if (update == true) {
          if (Get.find<UserController>().user.smallimage == null ||
              Get.find<UserController>().user.smallimage.isEmpty) return;

          String link = Get.find<UserController>().user.smallimage;
          link = link.split("/")[7];
          link = link.replaceAll("%20", " ");
          link = link.replaceAll("%2C", ",");
          link = link.substring(0, link.indexOf('.jpg'));
          link = link.replaceAll("%2F", "/");
          Reference storageReferance = FirebaseStorage.instance.ref();
          storageReferance.child("/" + link + ".jpg").delete().then((_) => Functions.debug(
              'Successfully deleted ${Get.find<UserController>().user.smallimage} storage item'));

          // String bigimagelink = Get.find<UserController>().user.bigimage;
          // bigimagelink = bigimagelink.split("/")[7];
          // bigimagelink = bigimagelink.replaceAll("%20", " ");
          // bigimagelink = bigimagelink.replaceAll("%2C", ",");
          // bigimagelink = bigimagelink.substring(0, bigimagelink.indexOf('.jpg'));
          // bigimagelink = bigimagelink.replaceAll("%2F", "/");
          // Reference bigimagelinkstorageReferance = FirebaseStorage.instance.ref();
          // Functions.debug("deleting /" + bigimagelink + ".jpg");
          // bigimagelinkstorageReferance.child("/" + bigimagelink + ".jpg").delete().then((_) => Functions.debug(
          //     'Successfully deleted ${Get.find<UserController>().user.bigimage} storage item'));
        }
      } catch (e) {
      }
    } else {
      user.smallimage = "";
    }
  }

  //upload image to firebase store and then returns image url
  uploadClubImage(String clubid,
      {bool update = false, File file, String previousurl = ""}) async {
    Functions.debug(file);
    if (file != null) {
      String fileName = basename(file.path);
      Reference firebaseSt =
      FirebaseStorage.instance.ref().child('clubicons/$fileName');
      UploadTask uploadTask = firebaseSt.putFile(file);

      await uploadTask.whenComplete(() async {
        String storagePath = await firebaseSt.getDownloadURL();
        updateClub(clubid, {
          "iconurl": storagePath,
        });
      });

      //delete previous icon url
      if (previousurl.isNotEmpty) {
        String link = previousurl;
        link = link.split("/")[7];
        link = link.replaceAll("%20", " ");
        link = link.replaceAll("%2C", ",");
        link = link.substring(0, link.indexOf('.jpg'));
        link = link.replaceAll("%2F", "/");
        if (update == true) {
          Reference storageReferance = FirebaseStorage.instance.ref();
          storageReferance.child("/" + link + ".jpg").delete().then((_) => Functions.debug(
              'Successfully deleted ${Get.find<UserController>().user.smallimage} storage item'));
        }
      }
    }
  }

  Future<String> uploadSponsorImage(File file) async {
    String storagePath;
    if (file != null) {
      String fileName = basename(file.path);
      Reference firebaseRef =
          FirebaseStorage.instance.ref().child('sponsors/$fileName');
      UploadTask uploadTask = firebaseRef.putFile(file);

      await uploadTask.whenComplete(() async {
        storagePath = await firebaseRef.getDownloadURL();
      });
    }

    return storagePath.toString();
  }

  static Future<String> getDeviceDetails() async {
    String deviceName;
    String deviceVersion;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.androidId; //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor; //UUID for iOS
      }
    } on PlatformException {
    }

//if (!mounted) return;
    return identifier;
  }

  //create user profile with the extra data and save them in firestore
  Future createUserInfo(String id) async {
    UserModel user = Get.find<OnboardingController>().onboardingUser;
    await uploadImage(id);
    var data = {
      "username": user.username,
      "firstname": user.firstname,
      "pausenotifications": user.pausenotifications,
      "email": FirebaseAuth.instance.currentUser.email,
      "uid": id,
      "gcbalance": 0.0,
      "accountstatus": true,
      "mbalance": 0.0,
      "lastname": user.lastname,
      "bio": "",
      "deviceid": await getDeviceDetails(),
      "host": false,
      "subroomtopic": true,
      "accountverified": false,
      "enabled": true,
      "subtrend": true,
      "subothernot": true,
      "online": true,
      "moderator": false,
      "callerid": 0,
      "valume": 0,
      "callmute": false,
      "followers": [],
      "referrerid": user.referrerid,
      "following": [],
      "imageurl": user.smallimage,
      "countrycode": user.countrycode,
      "firebasetoken": await FirebaseMessaging.instance.getToken(),
      "countryname": user.countryname,
      "phonenumber": FirebaseAuth.instance.currentUser.displayName,
      "profileImage": user.profileImage,
      "interests": [],
      "isNewUser": true,
      "lastAccessTime": DateTime.now().microsecondsSinceEpoch,
      "membersince": DateTime.now().microsecondsSinceEpoch,
      "joinedclubs": MAIN_CLUB_ID.isNotEmpty ? [MAIN_CLUB_ID] : [],
    };

    await UserApi().saveUser(id, data);

      if (APPROVE_ONLY == true && user.referrerid.isEmpty) {
        Get.to(() => InviteOnly());
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("referrerId", "");

        FirebaseMessaging.instance.subscribeToTopic("all");
        Get.offAll(() => InterestsPick(
              title:
                  "Add your interests so we can begin to personalize GistHouse for you. Interests are private to you",
              showbackarrow: false,
              fromsignup: true,
            ));
      }
    }




  //check if followed by the speaks
  bool followedBySpeakersCheck(List<RoomUser> roomusers) {
    List<String> ff = [];
    for (var j = 0; j < roomusers.length; j++) {
      RoomUser element = roomusers[j];
      if (element.usertype == "speaker" || element.usertype == "host") {
        if (Get.find<UserController>().user.followers.contains(element.uid)) {
          ff.add(element.uid);
        }
      }
    }
    if (ff.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  createRoom(
      {UserModel userData,
      String topic,
      String type,
      String roomid,
      String sponsors,
      List<UserModel> users,
      BuildContext context,
      UpcomingRoom upcominroom,
      String currency,
      List<Club> clubs,
      bool openToMembersOnly = false,
      double amount}) async {
    //leave any existing room
    await leaveActiveRoom();

    String eventid = "";
    //check if its an event
    if (type == "scheduled") {
      if (clubs != null && clubs.length > 0) {
        type = openToMembersOnly == true ? "club" : "public";
      } else {
        type = "public";
      }

      if (upcominroom.private == true) {
        type = "private";
      }
      //update upcoming room
      updateUpcomingEvent(roomid, {"status": "ongoing"});
      eventid = roomid;
    }

    //GENERATE AGORA TOKEN
    if (users != null && users.length > 0) {
      if (users.indexWhere((element) => element.uid == userData.uid) == -1)
        users.add(userData);
    }
    var ref;
    if(upcominroom == null) {
      ref = roomsRef.doc().id;
    } else {
      ref = upcominroom.roomid;
    }


    return await getCallToken(ref, "0").then((token) async {
      if (token != null) {
        var clubmembers = [];
        if(clubs != null){
          clubs.forEach((element) {
            clubmembers = element.members;
          });
        }
        var roomData = {
          'title': topic.isEmpty ? '' : topic,
          "ownerid": userData.uid,
          "sponsors": sponsors, //sponsors.map((e) => e.toMap()).toList(),
          "raisedhands": [],
          'handsraisedby': 1,
          "activemoderators": [userData.uid],
          "allmoderators": [userData.uid],
          'invitedfriends':
          type == "private" ? users.map((e) => e.toMap()).toList() : [],
          'clubListIds': clubs != null ? clubs.map((e) => e.id).toList() : [],
          'clubListNames':
          clubs != null ? clubs.map((e) => e.title).toList() : [],
          'amount': amount,
          'clubMembers': clubmembers,
          'currency': currency,
          'roomtype': type,
          'eventid': eventid,
          'token': token,
          'speakerCount': 1,
          "created_time": DateTime
              .now()
              .microsecondsSinceEpoch,
          "openToMembersOnly": openToMembersOnly,

        };
        //CREATING A ROOM
        if (upcominroom == null) {
          await OngoingRoomApi().saveRoom(roomData, ref);
        } else {
          await OngoingRoomApi().saveRoom(roomData, ref,
              toNotify: upcominroom.tobenotifiedusers);
        }
      }
      return ref;
    });

  }

//charge wallet and enter the room
  bool chargeWallet(Room room, UserModel user) {
    if (room.currency == gccurrency) {
      if (user.gcbalance > 0) {
        if (room.amount > user.gcbalance) {
          Functions.walletAlert(
              notenoughgistcoin, (room.amount - user.gcbalance).toString(),
              currency: gccurrency);
          return false;
        }
        if (room.amount <= user.gcbalance) {
          //debit current user account

          CloudFunctions()
              .payForRoom(user.uid, room.amount, room.roomid, room.ownerid);

          return true;
        }
      } else {
        Functions.walletAlert(
            notenoughgistcoin, (room.amount - user.gcbalance).toString(),
            currency: gccurrency);
        return false;
      }
    }

    // if (room.currency == dollarcurrency) {
    //   if (user.mbalance > 0) {
    //     if (room.amount > user.mbalance) {
    //       Functions.walletAlert(notenoughmoney,
    //           dollarcurrency + " " + (room.amount - user.mbalance).toString());
    //       return false;
    //     }
    //     if (room.amount <= user.mbalance) {
    //       //debit current user account
    //       var bal = user.mbalance - room.amount;
    //       updateProfileData(user.uid, {
    //         "mbalance": bal,
    //         "paidrooms": FieldValue.arrayUnion([room.roomid]),
    //       });
    //       addTransactions(
    //           userModel: user,
    //           txtReason: "Joined room (${room.title})",
    //           amount: dollarcurrency + " " + room.amount.toString(),
    //           type: "0");
    //
    //       //credit room owner wallet account
    //       updateProfileData(user.uid, {
    //         "mbalance": FieldValue.increment(room.amount),
    //       });
    //       addTransactions(
    //           userModel: user,
    //           txtReason: "${user.firstname} Joined your room (${room.title})",
    //           amount: dollarcurrency + " " + room.amount.toString(),
    //           type: "1");
    //
    //       return true;
    //     }
    //   } else {
    //     Functions.walletAlert(notenoughmoney,
    //         dollarcurrency + " " + (room.amount - user.mbalance).toString());
    //     return false;
    //   }
    // }
    return false;
  }

//leave any existing room
  leaveActiveRoom({BuildContext context}) async {
    await Database.getUserProfile(Get.find<UserController>().user.uid)
        .then((value) async {
      if (value != null) {
        if (value?.activeroom.isNotEmpty) {
          Room myroom = await Database().getRoomDetails(value.activeroom);
          if (myroom != null) {
            await Functions.leaveChannel(
                quit: false,
                room: myroom,
                currentUser: value,
                context: context);
          }
        }
      }
    });
  }

// Future<void> joinexistingroom(Room room, UserModel currenctUser, {BuildContext context}) async {
//   ClientRole role;
//   Functions.debug("_joinexistingroom");
//   if (currenctUser.activeroom.isNotEmpty &&
//       room.roomid != currenctUser.activeroom) {
//     Functions.debug("exist in another room ${currenctUser.activeroom}");
//     await Functions.leaveChannel(
//         quit: false,
//         roomid: currenctUser.activeroom,
//         currentUser: currenctUser,
//         context: context);
//   }
//
//   //check if room, exists
//   Room roomdetails = await Database().getRoomDetails(room.roomid);
//   if(room !=null && room.activemoderators.length == 0 || roomdetails == null){
//     Database.deleteRoomInFirebase(room);
//     topTrayPopup("Room does not exist");
//     getRooms();
//   }else {
//     // Room roomdetails = await Database().getRoomDetails(room.roomid);
//     // if (roomdetails != null) {
//     Functions.debug("room exist ${room.roomid}");
//     room = roomdetails;
//     //check if user exists in this room
//     if (await Database.checkUserExistsRoom(room.roomid, myProfile.uid) !=
//         null) {
//       Functions.debug("i exist in this room ${room.roomid}");
//       enterRoom(room.roomid, room, role, exists: true);
//     } else {
//       Functions.debug("joining as new user");
//       //join the new room
//       addUserToRoom(room, role);
//     }
//     // } else {
//     //   topTrayPopup("Room doesnt exists");
//     //   getRooms();
//     // }
//   }
// }

  getRoomToken(String channel, String uid) async {
    try {
      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = new IOClient(ioc);
      var url = Uri.parse('$tokenpath?channel=$channel&uid=$uid');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["token"];
      } else {
        throw Exception('Failed to load token');
      }
    } catch (e) {
    }
  }

//update upcoming toom data

//add user to a room

  addUserToRoom(
      {Room room, UserModel user, host = false, int calleruid}) async {
    if (host == true) {
      //this is the sake of a host that had left the room
      if (!room.activemoderators.contains(user.uid)) {
        OngoingRoomApi().addToActiveModeratorsRoom(room.roomid, user.uid);
      }
      addUser(room.roomid, user.uid,
          data: user.toMap(
              usertype: "host", callmute: false, callerid: calleruid));

      if (room.amount > 0) {
        await UserApi().addPaidRoom(room.roomid);
      }
    } else {
      if (room.allmoderators.contains(user.uid)) {
        addUser(room.roomid, user.uid,
            data: user.toMap(usertype: "moderator", callerid: calleruid));
      } else if (room.speakers.contains(user.uid)) {
        addUser(room.roomid, user.uid,
            data: user.toMap(usertype: "speaker", callerid: calleruid));
      } else {
        addUser(room.roomid, user.uid,
            data: user.toMap(usertype: "others", callerid: calleruid));
      }
    }
    await updateProfileData(user.uid, {"activeroom": room.roomid});
    Get.find<UserController>().user.activeroom =  room.roomid;
  }

//add user to room data
  static addUser(String roomid, String userid, {data}) async {
   // roomsRef.doc(roomid).collection("users").doc(userid).set(data);
    await OngoingRoomApi().addUserToRoom(data, roomid);
  }

//update room data

  static updateRoomData(String roomid, data) async {
    await OngoingRoomApi().updateRoom(data, roomid);
  }

//add transactions
  addTransactions(
      {String userid, String txtReason, String amount, String type}) {

    TransactionApi().saveTransaction({
      "reason": txtReason,
      "date": DateTime.now().microsecondsSinceEpoch,
      "amount": amount,
      "uid": userid,
      "type": type
    }
    );

  }

//send notification to my following
//check if they want to be sent notification
  sendNotificationToMyInvitedUsers(List<UserModel> users, String id) {
    List<String> userstokens = [];
    users.removeAt(users.indexWhere(
        (element) => element.uid == Get.find<UserController>().user.uid));
    users.forEach((element) {
      userstokens.add(element.firebasetoken);
    });
    PushNotificationsManager().callOnFcmApiSendPushNotifications(
        userstokens,
        "🔒 ${Get.find<UserController>().user.getName()} started a closed GistRoom with you, asked you to join the stage.",
        "",
        "RoomScreen",
        id);
  }

  static _inboxItemFirebaase(DocumentSnapshot documentSnapshot) {
    return InboxItem.fromJson(documentSnapshot);
  }

  static getInboxItem(String id) async {
    return chatsRef.doc(id).get().then((event) => InboxItem.fromJson(event));
  }

//send notification to my following
//check if they want to be sent notification
  Future<List<String>> getMyFollowingFirebaseFct(
      UserModel following, var roomScreen, String id) async {

    List<String> users = [];
    List followersFromApi = await UserApi().getUserFollowersToNotify(id);
    followersFromApi.map((e) {

          if (e.length > 0) {
              if (e["uid"] !=
                  Get.find<UserController>().user.uid) {
                users.add(e["firebasetoken"]);
              }

          }
        });

    return users;
  }

  addUsertoUpcomingRoom(UpcomingRoom room, {fromhome = false}) async {
    UserModel myProfile = Get.put(UserController()).user;
    FirebaseMessaging.instance.subscribeToTopic(room.roomid);

    UpcomingRoomApi().addNotifiedUpcoming(myProfile.uid, room.roomid);

    Get.snackbar("", "Share Link Copied To Clipboard",
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 0,
        margin: EdgeInsets.all(0),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        messageText: Text.rich(TextSpan(
          children: [
            TextSpan(
              text: "You will be notified when this room starts",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )));
    if (fromhome == false) {
      Get.to(() => UpcomingRoomScreen());
    }
  }

  removeUserFromUpcomingRoom(UpcomingRoom room) async {
    UserModel myProfile = Get.put(UserController()).user;
    if (myProfile.uid != room.userid) {
      room.tobenotifiedusers.removeAt(room.tobenotifiedusers
          .indexWhere((element) => element == myProfile.uid));
      UpcomingRoomApi().removeNotifiedUpcoming(myProfile.uid, room.roomid);
    }
  }

//update profile data

  static updateProfileData(String userid, data) {
    UserApi().updateUser(data, userid);
  }

//getupcoming

//Generate agora channel token,
//the script to generate this is a nodejs script
  getCallToken(String channel, String uid) async {
    try {
      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = new IOClient(ioc);
      var url = Uri.parse('$tokenpath?channel=$channel&uid=$uid');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["token"];
      } else {
        throw Exception('Failed to load token');
      }
    } catch (e) {
    }
  }

//the script to generate this is a nodejs script
  static getTokenVideoSdk() async {
    try {
      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = new IOClient(ioc);
      var url = Uri.parse(vsdktokenpath);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["token"];
      } else {
        throw Exception('Failed to load token');
      }
    } catch (e) {
    }
  }

//the script to generate this is a nodejs script
  static getMeetingIdVideoSdk() async {
    try {
      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = new IOClient(ioc);
      var url = Uri.parse(getmeetingidUrl);
      final response = await http.post(url, headers: {"authorization": await getTokenVideoSdk()});
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["token"];
      } else {
        throw Exception('Failed to load token');
      }
    } catch (e) {
    }
  }

//follow user
  folloUser(UserModel otherUser) async {

    await UserApi().followUser(otherUser.uid);

    //follow userlog activity

    var data1 = {
      "imageurl": Get.find<UserController>().user.smallimage,
      "name": "",
      'to': Get.find<UserController>().user.uid,
      "message": "you started following ${otherUser.getName()}",
      "time": FieldValue.serverTimestamp(),
      "type": "user",
      "actionkey": otherUser.uid,
    };
    addActivity(data1);

    //followed userlog activity

    var data2 = {
      "imageurl": Get.find<UserController>().user.smallimage,
      "name": Get.find<UserController>().user.getName(),
      "message": " started following you",
      'to': otherUser.uid,
      "time": FieldValue.serverTimestamp(),
      "type": "user",
      "actionkey": Get.find<UserController>().user.uid,
    };

    addActivity(data2);
    // String title = "🙂 👋 New Follower";
    // String msg =
    //     "${Get.find<UserController>().user.getName()} started following you";
    // PushNotificationsManager().callOnFcmApiSendPushNotifications(
    //     [otherUser.firebasetoken],
    //     title,
    //     msg,
    //     "ProfilePage",
    //     Get.find<UserController>().user.uid);
    FirebaseMessaging.instance.subscribeToTopic(
        "usersamfollowing${Get.find<UserController>().user.uid}");
    FirebaseMessaging.instance
        .subscribeToTopic("usersfollowingme${otherUser.uid}");
  }

//follow user
  unFolloUser(String otherId) async {

    UserApi().unFollowUser(otherId);

    FirebaseMessaging.instance.unsubscribeFromTopic(
        "usersamfollowing${Get.find<UserController>().user.uid}");
    FirebaseMessaging.instance
        .unsubscribeFromTopic("usersfollowingme$otherId");
  }

//invite user to a user
  inviteUserToClub(Club club, UserModel userModel) async {

    await ClubApi().inviteToClub(club, userModel);

  }

//invite user to a club
  static acceptClubInvite(String clubid) async {
    ClubApi().joinClub(clubid, Get.find<UserController>().user.uid);

    FirebaseMessaging.instance.subscribeToTopic(clubid);
  }

//invite user to a club
  static activityUpdate(String id, data) async {
    ActivityApi().updateActivity(id, data);
   // await activitiesRef.doc(id).update(data);
  }


//get room details
  Future<Room> getRoomDetails(String roomid) async {

    var room = await OngoingRoomApi().getRoomById(roomid);
      if (room != null) {

        return Room.fromJson( room);
      }
      return null;

  }

//GET UPCOMING ROOMS
  static getProfileEvents(String userid, [int limit]) {
    return UpcomingRoomApi().getUpcomingForUserWithLimit(userid, limit.toString());
  }

  static getOneUpcomingRoom(String id) {
    return UpcomingRoomApi().getUpcomingById(id);
  }

//GET UPCOMING ROOMS
  static getEvents(String show, [int limit]) {
    var dt =
        DateTime.now().subtract(Duration(minutes: 15)).millisecondsSinceEpoch;

    if (show == "mine") {
      if (limit == null) {
        return UpcomingRoomApi()
            .getUpcomingForUser(Get.find<UserController>().user.uid);
      } else {
        return UpcomingRoomApi()
            .getUpcomingForUserWithLimit(Get.find<UserController>().user.uid,
            limit.toString());
      }
    } else {
      if (limit == null) {
        return UpcomingRoomApi().getAllUpcoming();
      } else {
        return UpcomingRoomApi().getAllUpcomingWithLimit(limit.toString());
      }
    }
  }

//GET INTERESTS
  static Stream<List<Interest>> getInterests() {
    return interestsRef.snapshots().map(_interestsFromFirebase);
  }

  static List<Interest> _interestsFromFirebase(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((e) => Interest.fromJson(e)).toList();
  }

//GET USERS TO FOLLOW
  static getUsersToFollow(int limit) async {
    List user = await UserApi().getAllUsersWithLimit(limit.toString());
    return user.map((e) => UserModel.fromJson(user)).toList();

  }

//GET PEOPLE I FOLLOW
  static  getAmFollow() async {
    List user = await UserApi().getUserFollowing(Get.put(UserController()).user.uid);
    return user.map((e) => UserModel.fromJson(user)).toList();
  }

//GET PEOPLE WE FOLLOW EACH OTHER
  static  getmyFollowers({String excludeid}) async {

    List user = await UserApi().getUserMutualFollowers(Get.put(UserController()).user.uid);
    return user.map((e) => UserModel.fromJson(e)).toList();

  }

  static  getMyOnlineFriends({String excludeid}) async {

    List user = await UserApi().getOnlineFriends(Get.put(UserController()).user.uid);
    return user.map((e) => UserModel.fromJson(e)).toList();

  }


  static List<UserModel> usersFromFirebase(QuerySnapshot querySnapshot) {
    List<UserModel> users = [];
    querySnapshot.docs.forEach((element) {
      if (element.data()['uid'] != Get.find<UserController>().user.uid) {
        users.add(UserModel.fromJson(element.data()));
      }
    });
    return users;
  }

  static List<UserModel> _usersFromFirebase(QuerySnapshot querySnapshot) {
    List<UserModel> users = [];
    querySnapshot.docs.forEach((element) {
      if (element.data()['uid'] != Get.find<UserController>().user.uid) {
        users.add(UserModel.fromJson(element.data()));
      }
    });
    return users;
  }

  static List<UserModel> _usersFromClubsFirebase(QuerySnapshot querySnapshot) {
    return querySnapshot.docs
        .map((element) => UserModel.fromJson(element.data()))
        .toList();
  }

  static List<RoomUser> _usersRoomFromFirebase(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((e) => RoomUser.fromJson(e.data())).toList();
  }

//ADD UPCOMING EVENT
  addUpcomingEvent(
      String title,
      DateTime combinedDate,
      int datedisplay,
      int timeseconds,
      String description,
      List<UserModel> hosts,
      String sponsors,
      Club club,
      List<String> clubListIds,
      List<String> clubListNames, double amount,
      {bool openToMembersOnly = false, private = false}) async {

    var upcomingData = {
      "title": title,
      "eventdatetimestamp": datedisplay,
      "eventtimetimestamp": timeseconds,
      "start_date": combinedDate.microsecondsSinceEpoch,
      "clubid": club != null ? club.id : "",
      "clubname": club != null ? club.title : "",
      "clubListIds": clubListIds,
      "clubListNames": clubListNames,
      "users": hosts
          .map((i) => i.toMap(
          usertype: i.uid != Get.find<UserController>().user.uid
              ? "speaker"
              : "host",
          newitem: false))
          .toList(),
      "description": description,
      "userid": Get.find<UserController>().user.uid,
      "status": "pending",
      "published_date": DateTime
          .now()
          .microsecondsSinceEpoch,
      "sponsors": sponsors,
      "openToMembersOnly": openToMembersOnly,
      "private": private,
      "amount": amount
    };

    String ref = await UpcomingRoomApi().saveUpcoming(upcomingData);
    ref = ref.replaceAll('"', '');

    String datedisplayy = DateFormat("dd, MM yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(datedisplay))
        .toString();
    String timedisplayy = DateFormat("h:mma")
        .format(DateTime.fromMillisecondsSinceEpoch(timeseconds))
        .toString();

    var data = {
      "imageurl": Get.find<UserController>().user.smallimage,
      "name": Get.find<UserController>().user.getName(),
      "message": "Scheduled '$title' for $datedisplayy - $timedisplayy",
      "time": DateTime
          .now()
          .microsecondsSinceEpoch,
      "type": "upcomingroom",
      "actionkey": ref,
    };

    //update club with the room attached to it
    //Only send notifications to members if openToMembersOnly is not empty
    if (clubListIds.length > 0) {

      clubListIds.forEach((element) async {

        await ClubApi().addRoomForClub(element, ref);

        var club = await ClubApi().getClubsById(element);

        club.members.remove(Get.find<UserController>().user.uid);
        club.members.forEach((element) async {
          var user = await UserApi().getUserById(element);
          var profile = UserModel.fromJson(user);

            PushNotificationsManager().callOnFcmApiSendPushNotifications(
                [profile.firebasetoken],
                club.title,
                "Event calendar for $datedisplayy - $timedisplayy ${eventcontroller.text}",
                "ViewClub",
                ref);
        });
      });
    } else {
      Get.find<UserController>()
          .user
          .following
          .add(Get.find<UserController>().user.uid);
      Get.find<UserController>().user.following.forEach((element) {
        data["to"] = element;
        addActivity(data);
      });
      PushNotificationsManager().sendFcmMessageToTopic(
          title:
              "Event calendar for $datedisplayy - $timedisplayy ${eventcontroller.text}",
          message: descriptioncontroller.text,
          topic: all);
    }
  }

//update club
  static updateClub(clubid, data) {
    ClubApi().updateClub(data, clubid);
  }

//ADD CLUB
  addClub(
      {String title,
      String description,
      bool allowfollowers,
      bool membercanstartrooms,
      bool membersprivate,
      List<Interest> selectedTopicsList,
      File image}) async {
    var a = await ClubApi().getClubsByTitle(title);

      var value = a;
      if (value.length > 2) {
        topTrayPopup("a club with that name already exists");
      } else {

        var clubData = {
          "title": title,
          "members":[Get.find<UserController>().user.uid],
          "invited": [],
          "topics": selectedTopicsList.map((i) => i.toMap()).toList(),
          "description": description,
          "ownerid": Get.find<UserController>().user.uid,
          "published_date": DateTime.now().toString(),
          "allowfollowers": allowfollowers,
          "membercanstartrooms": membercanstartrooms,
          "membersprivate": membersprivate
        };

        String ref = await ClubApi().saveClub(clubData, Get.find<UserController>().user.uid);
        ref = ref.replaceAll('"', "");
        await ClubApi().joinAsOwnerOfClub(ref, Get.find<UserController>().user.uid);

        //upload club image icon

        if (image != null) {
          await uploadClubImage(ref, file: image);
        }



        return ref;
      }
  }

//UPDATE UPCOMING EVENT
  static updateUpcomingEvent(roomid, data) async {
    await  UpcomingRoomApi().updateUpcoming(data, roomid);
  }

//ADD EVENT ACTIVITY

  addActivity(Map<String, dynamic> data) {
    data["from"] = Get.find<UserController>().user.uid;
    ActivityApi().saveActivity(data);
  }

  void sendNotificationToUsersiFollow(
      String title, String msg, var screen, String id) {
    Get.find<UserController>().user.followers.forEach((element) async {

      var user = await UserApi().getUserById(element);
      var userModel = UserModel.fromJson(user);
             if (userModel != null) {
          if (userModel.uid != Get.find<UserController>().user.uid) {
            PushNotificationsManager().callOnFcmApiSendPushNotifications(
                [userModel.firebasetoken], title, msg, screen, id);
          }
        }
      });
  }

  sendNotificationToNotifiedUsers(
      List<String> toBeNotified, String roomId, String roomTitle) {
    toBeNotified.forEach((element) async {

      var user = await UserApi().getUserById(element);
      var userModel = UserModel.fromJson(user);
        PushNotificationsManager().callOnFcmApiSendPushNotifications(
            [userModel.firebasetoken],
            "Event has started",
            "Event " + roomTitle + " has started",
            "RoomScreen",
            roomId);
      });
    }

//

//clubs fact from firebase
  static List<Club> _clubsFromFirebase(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((e) => Club.fromJson(e)).toList();
  }

  static List<UpcomingRoom> _upcomingroomsFromFirebase(
      QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((e) => UpcomingRoom.fromJson(e)).toList();
  }

//get club rooms
  static  getClubUpcomingRooms(Club club) async {
    List rooms = await UpcomingRoomApi().getUpcomingForClub(club.id);
    return rooms.map((e) => UpcomingRoom.fromJson(e)).toList();
  }

//get my clubs
  static getMyClubs(String id) async {
    List clubs = await ClubApi().userClubs(id);
    return clubs.map((e) => Club.fromJson(e)).toList();
  }

  static getClubDetails(Club club) {
    return ClubApi().getClubsById(club.id);
  }

  getClubByIdDetails(String id) async {

    return ClubApi().getClubsById(id);

  }

  List<Club>  getClubsByIdsDetails(List<String> id)  {
    List<Club> clubs = [];
    id.forEach((element) async {
      clubs.add(await ClubApi().getClubsById(element));
    });
    return clubs;
  }

  static getusersInaClub(Club club) async {

    List user = await ClubApi().getClubMembers(club.id);
    return user.map((e) => UserModel.fromJson(user)).toList();

  }


  static friendsToFollow() async {
    List user = await UserApi().getUserByCountry(Get.put(UserController()).user.countrycode);
    return user.map((e) => UserModel.fromJson(user)).toList();
  }

  static Future<int>  checkUsername(String text) async {
    text = text.trim();
    var user = await UserApi().getUserByUsername(text);

    if(user == null) {
      return 0;
    } else {
      return 1;
    }
  }

  static Future<List<UserModel>> searchUser(String txt) async {
    if (txt.isNotEmpty){

      List user = await UserApi().searchUserByFirstname(txt);
      return user.map((e) => UserModel.fromJson(e)).toList();
    }

    return null;
  }

  static Future<List<Club>> searchClub(String txt) async {
    List<Club> clubList = [];
      List clubs = await ClubApi().searchClubsByTitle(txt);

      if(clubs.length > 0) {
        clubs.forEach((element) {
          clubList.add(Club.fromJson(element));
        });
      }

      return clubList;
  }

//follow club
  static followClub(Club club) async {
    ClubApi().followClub(club.id, Get.find<UserController>().user.uid);
  }

//follow user
  static unFolloClub(Club club) async {

    ClubApi().unFollowClub(club.id, Get.find<UserController>().user.uid);
  }

  static leaveClub(Club club) async {

    ClubApi().leaveClub(club.id, Get.find<UserController>().user.uid);

    FirebaseMessaging.instance.unsubscribeFromTopic(club.id);
  }

  static getClubFollowers(Club club) async {

    List user = await ClubApi().getClubFollowers(club.id);
    return user.map((e) => UserModel.fromJson(user)).toList();

  }

  getTransactions(UserModel userModel) async {
    return TransactionApi().getUserTransactions(userModel.uid);
  }

  getClubTransactions(String clubid) async {
    return TransactionApi().getUserTransactions(clubid);
  }

  donateCoinsToClub(Club club, String amount, String currency) {
    if (amount.isEmpty) {
      topTrayPopup("Please enter amount to donate to ${club.title}");
      return;
    }
    if (amount.isNotEmpty) {
      if (currency == gccurrency) {
        if (double.parse(amount) > Get.find<UserController>().user.gcbalance) {
          topTrayPopup(
              "You do not have enough Gistcoins to donate to ${club.title}");
          return;
        }

        CloudFunctions().depositToClub(
            Get.find<UserController>().user.uid, club.id, amount);
        Get.find<UserController>().user.gcbalance = Get.find<UserController>().user.gcbalance - double.parse(amount);

      }
    }

    Get.back();
    topTrayPopup(
        "You have successfully donated $currency $amount to ${club.title}",
        bgcolor: Colors.green);
  }

  static Future checkVerified(UserModel user) async {
    if(FirebaseAuth.instance.currentUser == null) return;
    Database.updateProfileData(user.uid, {
      "accountverified": user.checkUserverified(),
      "emailverified": FirebaseAuth.instance.currentUser.emailVerified,
      "phonenumberverified": user.countrycode == null || user.countrycode.isEmpty ? false : user.phonenumberverified,
    });

    if (user.checkUserverified() == true) {
      var date1 = DateFormat("dd-MM-yyyy h:mma").parse(
          DateFormat("dd-MM-yyyy h:mma")
              .format(DateTime.fromMicrosecondsSinceEpoch(user.membersince)));

      var date2 = DateFormat("dd-MM-yyyy h:mma").parse(
          DateFormat("dd-MM-yyyy h:mma").format(
              DateTime.fromMicrosecondsSinceEpoch(
                  DateTime.now().microsecondsSinceEpoch)));

      if (date2.difference(date1).inDays < 14 &&
          !user.awards.contains("new account")) {
        await CloudFunctions()
            .checkUserverification(user.uid, user.phonenumber);
      }
    }
  }

  sendMoney(UserModel user, String amount, String currency) {
    if (amount.isEmpty) {
      topTrayPopup("Please enter amount to send to ${user.firstname}");
      return;
    }
    if (amount.isNotEmpty) {
      if (currency == gccurrency) {
        if (double.parse(amount) > Get.find<UserController>().user.gcbalance) {
          topTrayPopup(
              "You do not have enough Gistcoins to send to ${user.firstname}");
          return;
        }

        CloudFunctions().sendMoney(
            Get.find<UserController>().user.uid, user.uid, int.parse(amount));
        Get.find<UserController>().user.gcbalance = Get.find<UserController>().user.gcbalance - double.parse(amount);
      }

      if (currency == dollarcurrency) {
        if (double.parse(amount) > Get.find<UserController>().user.mbalance) {
          topTrayPopup(
              "You do not have enough money to send to ${user.firstname}");
          return;
        }
        updateProfileData(
            user.uid, {"mbalance": user.mbalance + double.parse(amount)});

        updateProfileData(Get.find<UserController>().user.uid,
            {"mbalance": Get.find<UserController>().user.mbalance - double.parse(amount)});
        Get.find<UserController>().user.mbalance =
            Get.find<UserController>().user.mbalance - double.parse(amount);

        String sendingreason = "Sent $currency $amount to ${user.firstname}";
        String rreceivedreason =
            "Received $currency $amount from ${Get.find<UserController>().user.firstname}";

        addTransactions(
            userid: Get.find<UserController>().user.uid,
            txtReason: sendingreason,
            amount: currency + " " + amount.toString(),
            type: "0");

        addTransactions(
            userid: user.uid,
            txtReason: rreceivedreason,
            amount: currency + " " + amount.toString(),
            type: "1");
      }
    }

    Get.back();
    topTrayPopup(
        "You have successfully transferred $currency $amount to ${user.firstname}",
        bgcolor: Colors.green);
  }

  deleteClub(String clubId) async {
    await ClubApi().deleteClub(clubId);
  }

//Delete room in firebase
  static deleteRoomInFirebase(String roomid, {roomtype, room}) async {
    //Add field to show that user ended room

    await OngoingRoomApi().updateRoom({"userEnded": true}, roomid);
    await OngoingRoomApi().removeAllUsersInRoom(roomid);
    await OngoingRoomApi().deleteRoom(roomid);

      UserApi().updateUser({"activeroom": ""}, FirebaseAuth.instance.currentUser.uid);
    Get.find<UserController>().user.activeroom = "";

      //check if its upcoming room and delete
      if (room != null && room.eventid != null && room.eventid.isNotEmpty) {
        updateUpcomingEvent(room.eventid, {"status": "pending"});
      }

  }

//chats functions
  static void sendMessage(
      {List<UserModel> chatusers,
      types.TextMessage chatMessage,
      String messagetype = "",
      InboxItem inboxitem,
      String chatid}) {
    try {
      if (messagetype == "request") {
        if (inboxitem != null) {
          if (chatMessage.author.id != inboxitem.ownerid) {
            messagetype = "chats";
          }
        }
      }

      var message = {
        "author": chatMessage.author.toJson(),
        "text": chatMessage.text,
        "type": "text",
        "status": "unseen",
        "createdAt": chatMessage.createdAt,
      };

      chatsRef.doc(chatid).set({
        "users": chatusers.map((e) => e.uid).toList(),
        "members": chatusers.map((e) => e.toMap(newitem: false)).toList(),
        "lastmessage": chatMessage.text,
        "ownerid": Get.find<UserController>().user.uid,
        "messagetype": messagetype,
        "receiver": messagetype == "request" ? chatusers[0].uid : "",
        "last_sender": chatMessage.author.toJson(),
        "creationTimestamp": chatMessage.createdAt,
      });
//
      chatsRef.doc(chatid).collection("messages").add(message);

      if (chatusers
              .indexWhere((element) => element.uid == chatMessage.author.id) !=
          -1) {
        chatusers.removeAt(chatusers
            .indexWhere((element) => element.uid == chatMessage.author.id));
      }

      messagenotificationsRef.doc(chatid).set({
        "unreadusers":
            FieldValue.arrayUnion(chatusers.map((e) => e.uid).toList()),
      });
    } catch (e) {
    }
  }

  static List<InboxItem> _inboxMessageFromFirebaase(
      QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((e) => InboxItem.fromJson(e)).toList();
  }

  static List<types.Message> _messageFromFirebaase(
      QuerySnapshot querySnapshot) {
    return querySnapshot.docs
        .map((element) => types.TextMessage(
            author: types.User(
                id: element["author"]["id"],
                firstName: element["author"]["firstName"]),
            id: element.id,
            text: element["text"],
            createdAt: element["createdAt"]))
        .toList();
  }

  static updateInbox(chatid, removeid) {
    messagenotificationsRef.doc(chatid).update({
      "unreadusers": FieldValue.arrayRemove([removeid])
    });
  }

  static Stream<List<types.Message>> getMessages(
      String chatid, InboxItem inboxItem) {
    if (inboxItem != null)
      updateInbox(chatid, Get.find<UserController>().user.uid);

    return chatsRef
        .doc(chatid)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(_messageFromFirebaase);
  }

  static Stream<List<InboxItem>> getInbox(
      {String messagetype = "chats", List<String> userids}) {
    return chatsRef
        .where("users", arrayContainsAny: userids)
        .where("messagetype", isEqualTo: messagetype)
        .orderBy("creationTimestamp", descending: true)
        .snapshots()
        .map(_inboxMessageFromFirebaase);
  }

  void deactivateAccount(BuildContext context) {
    updateProfileData(
        Get.find<UserController>().user.uid, {"accountstatus": false});
    AuthService().signOut();
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => WelcomeScreen(),
      ),
      (route) => false, //if you want to disable back feature set to false
    );
  }

// ROOM FUNCTIONS

  static joinSpeakers({String userid, String roomid, RtcEngine engine}) async {
    await updateroomuser(roomid, userid, data: {"usertype": "speaker"});
    OngoingRoomApi().removeRaisedHands(userid, roomid);
    OngoingRoomApi()
        .addToSpeakersRoom(roomid, userid);
    engine.setClientRole(ClientRole.Broadcaster);
    engine.muteLocalAudioStream(true);
  }

  static getMessageChatType(String touid) {
    return Get.find<UserController>().user.followers.contains(touid) == true
        ? "chats"
        : "request";
  }

  static joinasModerators({String userid, Room room}) async {
    await updateroomuser(room.roomid, userid, data: {"usertype": "moderator"});

    OngoingRoomApi().removeRaisedHands(userid, room.roomid);

    OngoingRoomApi()
        .addToInvitedModeratorsRoom(room.roomid, userid);
  }

  static makeAudience({String userid, Room room}) async {
    await updateroomuser(room.roomid, userid,
        data: {"usertype": "others", "callmute": true});
    await OngoingRoomApi()
        .removeFromAllModeratorsRoom(room.roomid, userid);
    await OngoingRoomApi()
        .removeFromSpeakersRoom(room.roomid, userid);
  }

  static muteuser(Room room, RoomUser roomUser) async {
    await OngoingRoomApi().updateUserInRoom({
      "callmute": !roomUser.callmute,
    }, room.roomid, roomUser.uid);
  }

//mute user mic
  static void callMuteUnmute(Room room, int index, users, {state}) {
//  index = user
    engine.muteLocalAudioStream(!users[index].callmute);
    OngoingRoomApi().updateUserInRoom({
      "callmute": !users[index].callmute,
    }, room.roomid, users[index].uid);

  }

//add user to room data
  static getroomUsers(String roomid) async {
    List users =  await OngoingRoomApi().getRoomAllUsers(roomid);

    return users.map((e) => RoomUser.fromJson(e)).toList();
  }

//check user exists in a room
  static checkUserExistsRoom(String roomid, String userid) {
    return OngoingRoomApi().getRoomUserById(roomid, userid);
  }

//update room user
  static updateroomuser(String roomid, String userid, {data}) async {
    await OngoingRoomApi().updateUserInRoom(data, roomid, userid);
  }

//get raisedhans users
  static getRaisedHandsUsers(String roomid) async {
    return await OngoingRoomApi().getRaisedHands(roomid);

  }

//remove user from room raised hands
  static removeUserFromRaisedHands({String userid, String roomid}) {

    OngoingRoomApi()
        .removeRaisedHands(roomid, userid);
  }

//remove user from room
  static removeuser(String userid, String roomid) async {
    await OngoingRoomApi().removeUserFromRoom(userid, roomid);
  }

  static Future<void> removeUserFromRoom(Room room, UserModel profile) async {
    Get.back();
    Get.back();

    await OngoingRoomApi()
        .addToRemovedUsersRoom(room.roomid, profile.uid);

    await OngoingRoomApi()
        .removeFromActiveModeratorsRoom(room.roomid, profile.uid);

    await OngoingRoomApi()
        .removeFromAllModeratorsRoom(room.roomid, profile.uid);


    removeuser(profile.uid, room.roomid);
  }
}
