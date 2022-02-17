import 'dart:convert';

import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database_api/util/db_base.dart';

import 'util/db_utils.dart';

class ActivityApi {

   getActivitiesForUser(String id) async {

    return await jsonDecode(await DbBase().databaseRequest(ACTIVITIES_FOR_USER + id, DbBase().getRequestType));
  }

   getActivitiesForUserAfter(String id, ActivityItem lastActivity) async {
     var body = {
       "time": lastActivity.time,
       "id": lastActivity.id,
       "uid": id
     };

     return await DbBase().databaseRequest(ACTIVITIES_FOR_USER_AFTER, DbBase().getRequestType, body: body);
   }

  saveActivity(Map<String, dynamic> data) async {

    try{
      await DbBase().databaseRequest(SAVE_ACTIVITY, DbBase().postRequestType, body: data);
    } catch(e) {
    }
  }

  updateActivity(String id, Map<String, dynamic> data) async {

    try{
      await DbBase().databaseRequest(UPDATE_ACTIVITY + id, DbBase().patchRequestType, body: data);
    } catch(e) {
    }
  }

}