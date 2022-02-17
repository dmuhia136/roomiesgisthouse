import 'package:flutter/material.dart';
import 'package:gisthouse/widgets/round_image.dart';

import '../../../models/models.dart';

Widget userWidgetWithInfo({bool selected, UserModel user, Function clickCallBack}) {
  return Container(
    child: InkWell(
      onTap: () {
        clickCallBack(user);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Center(
                child: RoundImage(
                  url: user.smallimage,
                  txt: user.username,
                  width: 70,
                  height: 70,
                ),
              ),
              if (selected == true)
                Center(
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white.withOpacity(0.9)),
                    child: Icon(
                      Icons.check,
                      size: 30,
                      color: Colors.blue,
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                )
            ],
          ),

          Center(
            child: Container(
              padding: EdgeInsets.only(top: 10),
              width: 110,
              child: Center(
                child: Wrap(
                  children: [
                    Text(
                      user.firstname,
                      textScaleFactor: 1,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}