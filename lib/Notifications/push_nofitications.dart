import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;
  static final PushNotificationsManager _instance =
      PushNotificationsManager._();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  /*
      send notification to a topic
      params:
        title
        topic
        message
   */

  Future<bool> sendFcmMessageToTopic(
      {String title,
      String message,
      String topic,
      String screenA,
      String id
      }) async {
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=" + serverToken
      };
      final request = {
        "collapse_key": "type_a",
        "notification": {
          "title": title,
          "body": message,
          "sound": "default",
        },
        "priority": "high",
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "sound": "default",
          "status": "done",
          "screen": screenA,
          "id": id
        },
        // "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "to": "/topics/$topic",
      };
      var client = new Client();
      var response = await client.post(url,
          encoding: Encoding.getByName('utf-8'),
          body: json.encode(request),
          headers: header);
      if (response.statusCode == 200) {
        // on success do sth
        return true;
      } else {
        // on failure do sth
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /*
      send notification to specific user
      params:
        user tokes
        title
        message
   */

  Future<bool> callOnFcmApiSendPushNotifications(List<String> userToken,
      String title, String msg, String screenA, String id, {bool paidroom}) async {

    final postUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final data = {
      "registration_ids": userToken,
      "collapse_key": "type_a",
      "notification": {
        "title": title,
        "body": msg,
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "status": "done",
        "screen": screenA,
        "id": id,
        "paidroom": paidroom
      },
    };

    final headers = {
      "Content-Type": "application/json",
      'Authorization': "key=" + serverToken,
    };

    final response = await http.post(postUrl,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);
    if (response.statusCode == 200) {
      // on success do sth
      return true;
    } else {
      // on failure do sth
      return false;
    }
  }
}
