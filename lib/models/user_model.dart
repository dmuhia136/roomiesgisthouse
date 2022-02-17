import 'dart:io';

import 'package:gisthouse/util/configs.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:intl/intl.dart';
/*
  type : Model
 */

class UserModel {
  String firstname;
  bool enabled;
  bool sendfewernotifications;
  String email;
  String logintype;
  bool phonenumberverified;
  bool emailverified;
  String lastname;
  bool online;
  bool accountstatus;
  String deviceid;
  bool accountverified;
  String bio;
  String username;
  double mbalance;
  double gcbalance;
  String profileImage;

  // Room activeRoom;
  String uid;
  String referrerid;
  String contactsinvited;
  String phonenumber;
  String countrycode;
  String countryname;
  String smallimage;
  int lastAccessTime;
  int callerid;
  List<String> interests;
  List<String> followers;
  List<String> clubs;
  List<String> following;
  List<String> blocked;
  List<String> paidrooms;
  List<String> awards;
  bool isNewUser = true;
  bool callmute = false;
  bool moderator = false;
  bool subroomtopic = false;
  bool subtrend = false;
  bool subothernot = false;
  bool pausenotifications = false;
  bool renewUpgrade = true;
  File imagefile;
  String usertype;
  int valume = 1;
  int membership = 0;
  int membersince;
  String activeroom = "";
  String firebasetoken = "";
  int pausedtime;
  String twitter;
  String instagram;
  String facebook;
  String linkedIn;
  bool coinsEnabled = true;

  UserModel(
      {this.sendfewernotifications,
      this.deviceid,
      this.enabled,
      this.phonenumberverified,
      this.emailverified,
      this.accountverified,
      this.accountstatus,
      this.valume,
      this.membersince,
      this.subroomtopic,
      this.pausenotifications,
      this.email,
      this.awards,
      this.subothernot,
      this.contactsinvited,
      this.subtrend,
      this.logintype,
      this.interests,
      this.firebasetoken,
      this.usertype,
      this.clubs,
      this.activeroom,
      this.gcbalance,
      this.membership,
      this.mbalance,
      this.bio,
      this.paidrooms,
      this.blocked,
      this.firstname,
      this.moderator,
      this.online,
      this.lastname,
      this.countrycode,
      this.uid,
      this.referrerid,
      this.countryname,
      this.username,
      this.callerid,
      this.phonenumber,
      this.imagefile,
      this.smallimage,
      this.profileImage,
      // this.activeRoom,
      this.followers,
      this.following,
      this.lastAccessTime,
      this.isNewUser,
      this.pausedtime,
      this.callmute = true,
      this.renewUpgrade,
      this.twitter,
      this.facebook,
      this.instagram,
      this.linkedIn,
      this.coinsEnabled});

  getName() {
    return this.firstname + " " + this.lastname;
  }

  mhtml() {
    return dollarcurrency + " " + this.mbalance.toStringAsFixed(0);
  }

  getUserWalletCoinsBalance() {
    return this.gcbalance;
  }

  gchtml() {
    return gccurrency + " " + this.gcbalance.toStringAsFixed(0);
  }

  isFollowing(String id) {
    return this.following.contains(id);
  }

  premiumMember() {
    if (this.membership != null && this.membership == 1) {
      return true;
    }

    if (FORCE_MEMBERSHIP == true) {
      return false;
    }
    if (USER_TRIAL_PERIOD) {
      var tt = DateTime.fromMicrosecondsSinceEpoch(this.membersince);
      var date1 = DateFormat("dd-MM-yyyy h:mma")
          .parse(DateFormat("dd-MM-yyyy h:mma").format(tt));
      var ttc = DateTime.now().microsecondsSinceEpoch;

      var date2 = DateFormat("dd-MM-yyyy h:mma").parse(
          DateFormat("dd-MM-yyyy h:mma")
              .format(DateTime.fromMicrosecondsSinceEpoch(ttc)));

      if (date2.difference(date1).inDays < TRIAL_DAYS) {
        return true;
      }
    }
    return false;
  }

  checkApproval() {
    if (APPROVE_ONLY == true &&
        (this.referrerid == null || this.referrerid.isEmpty)) {
      return true;
    }
    return false;
  }

  checkUserverified() {
    if (phoneVerified() == true && emailverified == true) {
      return true;
    }
    return false;
  }

  phoneVerified() {
    if (countrycode != null &&
        phonenumber != null &&
        countryname != null &&
        phonenumberverified == true) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> toMap(
      {usertype = "host", callmute = true, callerid = 0, newitem = true}) {
    return {
      "followers": followers,
      "following": following,
      "sendfewernotifications": sendfewernotifications,
      "pausenotifications": pausenotifications,
      "contactsinvited": contactsinvited,
      "deviceid": deviceid,
      "awards": awards,
      "membersince": membersince,
      "pausedtime": pausedtime,
      "phonenumberverified": phonenumberverified,
      "emailverified": emailverified,
      "accountstatus": accountstatus,
      "email": email,
      "gcbalance": gcbalance,
      "mbalance": mbalance,
      "paidrooms": paidrooms,
      "addedtime": newitem ? DateTime.now().microsecondsSinceEpoch : "",
      "membership": 0,
      "enabled": true,
      "accountverified": accountverified,
      "subothernot": subothernot,
      "blocked": blocked,
      "subtrend": subtrend,
      "subroomtopic": subroomtopic,
      "valume": valume,
      "firebasetoken": firebasetoken,
      "lastname": lastname,
      "bio": bio,
      "firstname": firstname,
      "uid": uid,
      "usertype": usertype,
      "activeroom": activeroom,
      "callerid": callerid,
      "callmute": callmute,
      "logintype": logintype,
      "moderator": moderator,
      "username": this.username,
      "countrycode": countrycode,
      "countryname": countryname,
      "phonenumber": phonenumber,
      "imageurl": smallimage,
      "profileImage": profileImage,
      "isNewUser": isNewUser,
      "renewUpgrade": renewUpgrade,
      "twitter": twitter,
      "facebook": facebook,
      "instagram": instagram,
      "linkedin": linkedIn,
      "coinsEnabled": coinsEnabled
    };
  }

  factory UserModel.fromJson(json) {
    List<String> followers = json["followers"] == null
        ? []
        : List<String>.from(json["followers"].map((item) => item));
    List<String> following = json["following"] == null
        ? []
        : List<String>.from(json["following"].map((item) => item));

    List<String> awards = json["awards"] == null
        ? []
        : List<String>.from(json["awards"].map((item) => item));

    List<String> clubs = json["clubs"] == null
        ? []
        : List<String>.from(json["clubs"].map((item) => item));

    List<String> paidrooms = json["paidrooms"] == null
        ? []
        : List<String>.from(json["paidrooms"].map((item) => item));

    List<String> interests = json["interests"] == null
        ? []
        : List<String>.from(json["interests"].map((item) => item));

    return UserModel(
        lastname: json['lastname'],
        clubs: clubs,
        awards: awards,
        blocked: [],
        emailverified:
            json['emailverified'] == null ? false : json['emailverified'],
        phonenumberverified: json['phonenumberverified'] == null
            ? false
            : json['phonenumberverified'],
        subothernot: json['subothernot'] ?? false,
        sendfewernotifications: json['sendfewernotifications'] ?? false,
        pausenotifications: json['pausenotifications'] ?? false,
        pausedtime: json['pausedtime'] is int ? json['pausedtime'] : 0,
        subtrend: json['subtrend'] ?? false,
        subroomtopic: json['subroomtopic'] ?? false,
        enabled: json['enabled'] == null ? true : json['enabled'],
        accountverified:
            json['accountverified'] == null ? false : json['accountverified'],
        accountstatus: json['accountstatus'] ?? true,
        logintype: json['logintype'] ?? "",
        interests: interests,
        membership: json['membership'] ?? null,
        membersince: json['membersince'],
        firstname: json['firstname'],
        contactsinvited: json['contactsinvited'] ?? "",
        deviceid: json['deviceid'] ?? "",
        email: json['email'] == null ? "" : json['email'],
        activeroom: json['activeroom'] ?? "",
        callerid: json['callerid'] ?? 0,
        paidrooms: paidrooms,
        mbalance: json['mbalance'] == null
            ? 0.0
            : double.parse(json['mbalance'].toString()) ?? 0.0,
        gcbalance: json['gcbalance'] == null
            ? 0.0
            : double.parse(json['gcbalance'].toString()) ?? 0.0,
        valume: json['valume'] ?? 0,
        callmute: json['callmute'] ?? false,
        online: json['online'] ?? false,
        username: json['username'],
        countrycode: json['countrycode'],
        firebasetoken: json['firebasetoken'],
        usertype: json['usertype'],
        uid: json['uid'],
        referrerid: json['referrerid'] ?? null,
        moderator: json['moderator'],
        bio: json['bio'] ?? "",
        countryname: json['countryname'],
        phonenumber: json['phonenumber'],
        profileImage: json['profileImage'] ?? "",
        smallimage: json['imageurl'] ?? "",
        lastAccessTime: json['lastAccessTime'],
        followers: followers,
        following: following,
        isNewUser: json['isNewUser'] ?? true,
        renewUpgrade: json['renewUpgrade'] ?? true,
        twitter: json["twitter"],
        facebook: json["facebook"],
        instagram: json["instagram"],
        linkedIn: json["linkedin"],
        coinsEnabled: json['coinsEnabled'] ?? true);
  }
}
