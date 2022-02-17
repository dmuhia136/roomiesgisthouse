import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

 topTrayPopup(String title, {Color bgcolor = Colors.red }){
   Get.snackbar("",
      " $title",
      // " you  raised your hand! we'll let the speakers know you want to talk..",
      snackPosition: SnackPosition.TOP,
      borderRadius: 0,
      margin: EdgeInsets.all(0),
      backgroundColor: bgcolor,
      colorText: Colors.white,
      messageText: Text.rich(TextSpan(
        children: [
          WidgetSpan(
            child: Icon(
              CupertinoIcons.hand_raised_fill,
              size: 21.0,
              color: Color(0XFFE5C9B6),
            ),
          ),
          TextSpan(
            text:
            " $title",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      )));
}