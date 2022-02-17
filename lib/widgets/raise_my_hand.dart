
//raise hands action bottom sheet widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';

raiseMyHandView(BuildContext context, Room room, UserModel myProfile) {
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      builder: (context) {
        return Container(
          height: 350,
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.hand_raised_fill,
                size: 60.0,
                color: Color(0XFFE5C9B6),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  "Raise your hand?",
                  style:
                  TextStyle(fontSize: 18, fontFamily: "InterExtraBold"),
                ),
              ),
              Center(
                  child: Text(
                    "This will let the speaker know you have something you'd like to say",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16, fontFamily: "InterRegular"),
                  )),
              Container(
                margin: EdgeInsets.symmetric(vertical: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 21, vertical: 12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.red
                          ),
                          child: Text(
                            "Never mind",
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "InterBold",
                                color: Colors.white),
                          ),
                        )),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.red
                      ),
                      child: TextButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await Functions.raisehand(room);
                          },

                          icon: Icon(
                            CupertinoIcons.hand_raised_fill,
                            size: 20.0,
                            color: Color(0XFFE5C9B6),
                          ),
                          label: Text(
                            "Raise hand",
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "InterBold",
                                color: Colors.white),
                          )),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      });
}