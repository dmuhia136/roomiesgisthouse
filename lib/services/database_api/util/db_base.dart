import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/main.dart';
import 'package:gisthouse/services/database_api/auth_api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DbBase {
  var postRequestType = "POST";
  var getRequestType = "GET";
  var patchRequestType = "PATCH";
  var deleteRequestType = "DELETE";

  databaseRequest(
      String link, String type, {Map<String, dynamic> body}) async {

    _tryConnection();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("access_token");

    var headers = {
      'Content-Type': 'application/json',
      'auth-token': token

    };
    Functions.debug("link c $link");
    Functions.debug("type $type");
    Functions.debug("body $body");
    var request = http.Request(type, Uri.parse(link));

    if ( body != null ) {
      request.body = json.encode(body);
    }

    request.headers.addAll(headers);


    http.StreamedResponse response = await request.send();

    Functions.debug("errror: ${response.reasonPhrase}");
    Functions.debug("errror: ${response.request.url}");


    if (response.statusCode == 404) {
      Functions.debug("response status code 404: ${response.reasonPhrase}");
      Functions.debug("response status code 404: ${response.request.url}");

      AuthAPI().getToken();

    }

    return response.stream.bytesToString();
  }


  Future<void> _tryConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');

      if(response.isEmpty) {
        final snackBar = SnackBar(
          content: const Text('Check your internet connection'),
          action: SnackBarAction(
            onPressed: () {
              // Some code to undo the change.
            }, label: '',
          ),
        );

        ScaffoldMessenger.of(navigatorKey.currentContext).showSnackBar(snackBar);
      }
    } on SocketException catch (e) {
      Functions.debug(e);
      final snackBar = SnackBar(
        content: const Text('Check your internet connection'),
        action: SnackBarAction(
          onPressed: () {
            // Some code to undo the change.
          }, label: '',
        ),
      );

      ScaffoldMessenger.of(navigatorKey.currentContext).showSnackBar(snackBar);
    }
  }

}
