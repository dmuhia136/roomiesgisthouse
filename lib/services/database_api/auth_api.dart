import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:gisthouse/services/database_api/util/db_base.dart';
import 'package:gisthouse/services/database_api/util/db_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthAPI {
  Future getToken() async {
    try {


      String phoneNumber = FirebaseAuth.instance.currentUser.displayName == null ||
          FirebaseAuth.instance.currentUser.displayName == ""
          ? FirebaseAuth.instance.currentUser.phoneNumber
          : FirebaseAuth.instance.currentUser.displayName;

      phoneNumber = phoneNumber.replaceAll("+", "");
      var body = {
        "userId": FirebaseAuth.instance.currentUser.uid,
        "phone": phoneNumber
      };

      var token = await jsonDecode(await DbBase()
          .databaseRequest(LOGIN, DbBase().postRequestType, body: body));

      if (token == null) {
        getToken();
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("access_token", token['accessToken']);
      }
    } catch (error, stack) {}
  }

  sendVerificationCode(String phone) async {
    phone = phone.replaceAll('+', '');
    var body = {"phone": phone};
    var requestId = await DbBase()
        .databaseRequest(SEND_CODE, DbBase().postRequestType, body: body);
    return requestId;
  }

  verifyCode(String code, String requestId, String phone) async {
    phone = phone.replaceAll('+', '');

    var body = {"requestId": requestId, "code": code, "phone": phone};
    var verify = await DbBase()
        .databaseRequest(VERIFY_CODE, DbBase().postRequestType, body: body);
    print("eeeeeeeee   " + verify);
    return verify;
  }

  authForTesting(String phone) async {
    phone = phone.replaceAll('+', '');

    var verify = await DbBase()
        .databaseRequest(AUTH_FOR_TESTING, DbBase().postRequestType);
    print("eeeeeeeee   " + verify);
    return verify;
  }
}
