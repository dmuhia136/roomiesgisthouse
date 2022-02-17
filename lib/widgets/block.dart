import 'package:flutter/material.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/top_tray_popup.dart';

Future<void> blockProfile(BuildContext context, {UserModel myprofile,UserModel reportuser}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: false,
        title:  Text("Block ${reportuser.getName()}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("This will prevent them from entering rooms where you are a speaker, and we'll warn you about room where they are speaking"),
            SizedBox(height: 20,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: (){

                      Navigator.pop(context);
                    },
                    child: Text("CANCEL", style: TextStyle(color: Style.AccentBlue),)
                ),
                SizedBox(height: 20,),
                InkWell(
                    onTap: (){
                      Navigator.pop(context);

                      UserApi().blockUser(reportuser.uid);

                      topTrayPopup("${reportuser.getName()} has been blocked");
                    },
                    child: Text("BLOCK", style: TextStyle(color: Style.AccentBlue),)
                )
              ],
            )
          ],
        ),
      );
    },
  );
}

Future<void> unBlockProfile(BuildContext context, {UserModel myprofile,UserModel reportuser}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: false,
        title:  Text("Unblock ${reportuser.getName()}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("This will no longer be prevented from entering rooms where you are a speaker"),
            SizedBox(height: 20,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: (){

                      Navigator.pop(context);
                    },
                    child: Text("CANCEL", style: TextStyle(color: Style.AccentBlue),)
                ),
                SizedBox(height: 20,),
                InkWell(
                    onTap: (){
                      Navigator.pop(context);

                      UserApi().unBlockUser(reportuser.uid);
                      topTrayPopup("${reportuser.getName()} has been unblocked", bgcolor: Colors.green);
                    },
                    child: Text("UNBLOCK", style: TextStyle(color: Style.AccentBlue),)
                )
              ],
            )
          ],
        ),
      );
    },
  );
}
Future<void> showBlockedUsersAlert(BuildContext context, int count) async {

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: false,
        title:  Text("Alert"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$count speaker${count > 1 ? "s are" : " is"} in your blocked list of users, you cant join this room untill you unblock them"),
            SizedBox(height: 20,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Text("OK", style: TextStyle(color: Style.AccentBlue),)
                )
              ],
            )
          ],
        ),
      );
    },
  );

}