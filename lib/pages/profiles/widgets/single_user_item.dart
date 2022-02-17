import 'package:flutter/material.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/widgets/round_image.dart';

Widget singleItem(UserModel user,
    {List<UserModel> selectedusers,
    bool selected,
    IconData selectediconData,
    IconData unselectediconData,
    Function callBackFUnction}) {
  return Container(
    child: Row(
      children: [
        RoundImage(
          url: user.smallimage,
          txt: user.username,
          width: 45,
          height: 45,
          txtsize: 16,
          borderRadius: 18,
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.getName(),
                textScaleFactor: 1,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 16,
        ),
        TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: FutureBuilder<Object>(
              future: null,
              builder: (context, snapshot) {
                return selectedusers
                            .indexWhere((element) => element.uid == user.uid) ==
                        -1
                    ? Icon(selectediconData)
                    : Icon(unselectediconData);
              }),
          onPressed: () => callBackFUnction(user),
        ),
      ],
    ),
  );
}
