import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/pages/home/home_page.dart';
import 'package:gisthouse/pages/onboarding/email_verification.dart';
import 'package:gisthouse/pages/onboarding/full_name_page.dart';
import 'package:gisthouse/pages/onboarding/invite_only.dart';
import 'package:gisthouse/pages/onboarding/welcome_page.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_api/auth_api.dart';


class AuthService {
  /// returns the initial screen depending on the authentication results
  handleAuth() {
    if (FirebaseAuth.instance.currentUser == null) {
      return WelcomeScreen();
    }
    return FutureBuilder(
           future: Database.getUserProfile(FirebaseAuth.instance.currentUser.uid),
           builder: (BuildContext context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
               return Scaffold(
                 backgroundColor: Style.AccentBlue,
                 body: Center(
                   child: Container(
                     child: CircularProgressIndicator(),
                   ),
                 ),
               );
             }
             if (snapshot.hasData == true) {
               Get.put(UserController()).user = snapshot.data;
               if(Get.put(UserController()).user.enabled == false){
                 return InviteOnly();
               }else {
                 if (Get
                     .put(UserController())
                     .user
                     .checkApproval()) {
                   return InviteOnly();
                 }
                 if ((FirebaseAuth.instance.currentUser.displayName == null ||
                     FirebaseAuth.instance.currentUser.displayName == "") &&
                     FirebaseAuth.instance.currentUser.emailVerified == false) {
                   return EmailVerification();
                 }
                 return HomePage();
               }
             } else {
               if(FirebaseAuth.instance.currentUser == null){
                 signOut();
               }else {
                 if ((FirebaseAuth.instance.currentUser.displayName == null ||
                     FirebaseAuth.instance.currentUser.displayName == "") &&
                     FirebaseAuth.instance.currentUser.emailVerified == false) {
                   return EmailVerification();
                 }
                 return FullNamePage();
               }
             }
           },
         );



  }

  /// This method is used to logout the `FirebaseUser`
  signOut() async {
    // if(FirebaseAuth.instance.currentUser == null) return;
    await Database.updateProfileData(FirebaseAuth.instance.currentUser.uid,
        {"online": false});
    FirebaseAuth.instance.signOut();
    Get.offAll(WelcomeScreen());
  }

  getNotifString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("from_notification_class");
  }

  /// get the `smsCode` from the user
  /// when used different phoneNumber other than the current (running) device
  /// we need to use OTP to get `phoneAuthCredential` which is inturn used to signIn/login
  Future signInWithOTP(
      BuildContext context, smsCode, verId, String logintype, String phone) async {

    String verified = await AuthAPI().verifyCode(smsCode, verId, phone);

    if(verified != null) {

      signInWithCustomToken(logintype, phone, verified);

    } else{
      print("Unverified" + verified);
    }
  }

  signInWithCustomToken(String logintype, String phone, String token) async {
    try {
      phone = phone.replaceAll('+', '');
      var result = await FirebaseAuth.instance.signInWithCustomToken(
          token);
      print("result $result" );
      if (result.user != null) {
        await FirebaseAuth.instance.currentUser.updateDisplayName(phone);
        print("display name " + FirebaseAuth.instance.currentUser.displayName);
        await AuthAPI().getToken();
        loginRedirect(result.user, logintype);
      } else {
        print("User null");
      }
    } catch (e) {
      print("error " + e.toString());
      return "null";
    }
  }

  static loginRedirect(User user, String logintype) {
    Database.getUserProfile(user.uid).then((value) async {
      Get.put(UserController()).user = value;
      if (value != null) {
        if(value.enabled == false){
          return Get.offAll(() => InviteOnly());
        }else{
          await Database.updateProfileData(user.uid, {
            "firebasetoken": await FirebaseMessaging.instance.getToken(),
            "accountstatus": true,
            "deviceid": await Database.getDeviceDetails(),
            "logintype": logintype,
          });
          if (logintype == "email" &&
              FirebaseAuth.instance.currentUser.emailVerified == false) {
            return Get.offAll(() => EmailVerification());
          }
          return Get.offAll(() => HomePage());
        }

      } else {
        return Get.to(() => FullNamePage());
      }
    });
  }
}
