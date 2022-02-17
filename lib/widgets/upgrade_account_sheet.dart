import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/cloud_functions.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:gisthouse/util/utils.dart';

import '../controllers/controllers.dart';
import 'widgets.dart';

showPremiumAlert(BuildContext context,
    {String msg, double fontsize = 23, UserModel userModel}) {
  Dialog errorDialog = Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0)), //this right here
    child: Container(
      height: 300.0,
      width: 300.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              msg,
              style: TextStyle(color: Colors.black, fontSize: fontsize),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              Get.back();
              upgradeToPremium(context, userModel);
            },
            child: Container(
              alignment: FractionalOffset.bottomCenter,
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Card(
                color: Colors.green,
                elevation: 30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "Upgrade",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20.0)),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Dismiss!',
                style: TextStyle(color: Colors.red, fontSize: 18.0),
              ))
        ],
      ),
    ),
  );
  showDialog(context: context, builder: (BuildContext context) => errorDialog);
}

upgradeToPremium(BuildContext context, UserModel userModel) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Color(0XFF0A0D2C),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height * .8,
            margin: EdgeInsets.only(top: 30),
            color: Color(0XFF0A0D2C),
            child: SingleChildScrollView(
              child: Column(children: [
                Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "UPGRADE PREMIUM GISTER",
                                style: TextStyle(
                                    fontSize: 15, color: Color(0XFF00FFB0)),
                              ),
                              InkWell(
                                onTap: () => Get.back(),
                                child: Icon(
                                  Icons.clear,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          Text(
                            "Upgrade now to get unlimited access to amazing next-level features of GistHouse",
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0XFF00FFB0),
                                height: 1.3),
                          ),
                          SizedBox(height: 10),
                          premiumFeature(
                              "Activate  Peer To Peer In-App Donations",
                              "Activate feature to Receive donations and gifts from your GistRooms, Followers and other Gisters"),
                          SizedBox(height: 20),
                          premiumFeature(
                              "Activate Detailed Analytics Of Your GistRooms",
                              "Take the managing and marketing of your Rooms to next level with full business analytics of your rooms (attendee records, Room Length, Best Rooms in your clubs, moderator records, etc"),
                          SizedBox(height: 20),
                          premiumFeature("Activate Room Advert/ Sponsorships",
                              "Monetize your rooms with ability to put sponsor names/tags at the top of your rooms."),
                          SizedBox(height: 20),
                          premiumFeature("Activate Paid Rooms",
                              "Monetize your knowledge, followership and skills by running paid rooms right inside the app. "),
                          SizedBox(height: 20),
                          premiumFeature(
                              "Access GistDeck For Desktop/Laptop Access",
                              "Get access to the desktop/laptop version of the app with extra features not found on the phone apps"),
                          SizedBox(height: 20),
                          premiumFeature(
                              "Record and repurpose your room content",
                              "Access to gistdeck lets you record any room and you can use recordings in your podcasts and repurpose for other places"),
                        ])),
                SizedBox(height: 20),
                CustomButton(
                  text: "$PREMIUM_UPGRADE_COINS_AMOUNT GIST/Month \n \n UPGRADE NOW",
                  fontfamily: "LucidaGrande",
                  txtcolor: Color(0XFF0A0D2C),
                  fontSize: 13,
                  color: Color(0XFF00FFB0),
                  radius: 10,
                  onPressed: () async {
                    Get.back();
                    await upgradeAccount(context, userModel);
                  },
                ),
              ]),
            ));
      });
}

Widget premiumFeature(String title, String body) {
  return Container(
    padding: const EdgeInsets.all(10.0),
    child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "LucidaGrande",
                  color: Colors.white,
                  height: 1.2)),
          SizedBox(height: 10),
          Text(body,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: "LucidaGrande",
                  height: 1.5,
                  color: Colors.white)),
        ]),
  );
}

upgradeAccount(BuildContext context, UserModel userModel) async {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Wallet Balance (${userModel.gchtml()})'),
        actions: [
          CupertinoActionSheetAction(
            child: Text('Amount to be decuted $gccurrency $PREMIUM_UPGRADE_COINS_AMOUNT',
                style: TextStyle(fontSize: 16)),
            onPressed: () async {

            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child:
              Text('Confirm Payment', style: TextStyle(fontSize: 16, color: Colors.red)),
          onPressed: () {

            if (userModel.getUserWalletCoinsBalance() <
                PREMIUM_UPGRADE_COINS_AMOUNT) {
              Functions.walletAlert(
                  "You do not have enough GC to upgrade your account to premium",
                  (PREMIUM_UPGRADE_COINS_AMOUNT -
                      Get.find<UserController>()
                          .user
                          .getUserWalletCoinsBalance())
                      .toString(),
                  currency: gccurrency);
            } else {

              Navigator.pop(context);
              Navigator.pop(context);
              CloudFunctions().upgradeToPremium(
                  Get.find<UserController>().user.uid,
                  PREMIUM_UPGRADE_COINS_AMOUNT);
              Get.find<UserController>().user.gcbalance =
                  Get.find<UserController>().user.gcbalance - PREMIUM_UPGRADE_COINS_AMOUNT;
              Get.find<UserController>().user.membership = 1;

              topTrayPopup(
                  "You have successfully upgraded your account o premium membership, Enjoy Gisting",
                  bgcolor: Colors.green);
            }
          },
        )),
  );
}
