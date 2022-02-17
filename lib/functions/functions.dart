import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/Notifications/push_nofitications.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/room/room_screen.dart';
import 'package:gisthouse/services/cloud_functions.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/ongoingroom_api.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/wallet/wallet_page.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:intl/intl.dart';

/*
  type : Class
  packages used: none
  function: holds all general methods used in the whole app
 */

class Functions {
  //creates a timestamp string with how long ago a task was done
  static String timeAgoSinceDate(String dateString,
      {bool numericDates = true}) {
    DateTime notificationDate =
        DateFormat("dd-MM-yyyy h:mma").parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(notificationDate);

    if (difference.inDays > 8) {
      return dateString;
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1w ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1d ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours}h ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1h ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes}mins ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1mins ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
  static debug(data, {bool show = true, }){
    if(show) print(data);
  }
//jj
  //creates a timestamp string with how long ago a task was done
  static String timeFutureSinceDate( //bb
      { String dateString, int timestamp, alphas = false}) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime notificationDate;
    if (dateString != null) {
      notificationDate = DateFormat("dd-MM-yyyy h:mma")
          .parse(DateFormat("dd-MM-yyyy h:mma").format(DateTime.parse(dateString)));
    } else {
      notificationDate = DateFormat("dd-MM-yyyy h:mma")
          .parse(DateFormat("dd-MM-yyyy h:mma").format(date));
    }
    final date2 = DateTime.now();
//    final difference = notificationDate.difference(date2);
/*    if (difference.inHours >= 0 && difference.inHours <= 12) {
      return alphas ? "$dateForDay Today" : "Today $time";
    } else if (difference.inHours > 12 && difference.inHours < 24) {
      return alphas ? "$dateForDay Tomorrow" : "Tomorrow $time";
    } else if (difference.inHours > 1) {
      if(dateString !=null) {
        return DateFormat('E, d MMM').format(dateString.toDate());
      }else{
        return DateFormat('d MMM, E').format(date);
      }
    }*/

    if (dateString != null) {
      return DateFormat('E, d MMM yyyy').format(DateTime.parse(dateString));
    } else {
      return DateFormat('d MMM, E yyyy').format(date);
    }
  }

  //methos invoked when user is leaving the room
  static Future<void> leaveChannel(
      {setState,
        room,
      roomid,
      UserModel currentUser,
      BuildContext context,
      StreamSubscription<DocumentSnapshot> roomlistener,
      bool quit = false,
      String usertype}) async {

    String rId;
    if (room != null) {
      rId = room.roomid;
      if(room.activemoderators
          .indexWhere((element) => element == currentUser.uid) !=-1){
        room.activemoderators.removeAt(room.activemoderators
            .indexWhere((element) => element == currentUser.uid));
      }

    }

    if (roomid != null) {
      rId = roomid;
    }

    if (quit == true) {
      quitRoomandPop(roomlistener: roomlistener, context: context);
    } else {
      await leaveEngine();
    }
    Get.find<CurrentRoomController>().room = null;
    Database.removeuser(currentUser.uid, rId);

    await UserApi().updateUser({"activeroom": ""}, currentUser.uid);
    currentUser.activeroom = "";
    await OngoingRoomApi().removeFromActiveModeratorsRoom(rId, currentUser.uid);

    if (usertype != null && usertype.isNotEmpty && usertype == "host" && room.activemoderators.length > 0) {
      String newhostid = room.activemoderators.first;
      Database.updateroomuser(rId, newhostid, data: {"usertype": "host"});
    }


    CloudFunctions().roomUserAnalytics(
        user: currentUser.uid,
        roomid: rId,
        usertype: usertype,
        action: "leave");

    if (room != null &&
        room.activemoderators.length == 0) {
      Database.deleteRoomInFirebase(rId, roomtype: room.roomtype, room:room);
    }


  }

  //exit room and navigate back to homepage
  static Future<void> quitRoomandPop(
      { StreamSubscription<DocumentSnapshot> roomlistener,
      context}) async {
    await leaveEngine();
    if (roomlistener != null) roomlistener.cancel();
    Navigator.pop(context);
  }

  //wallet alert sms
  static walletAlert(message, String balance, { String currency}) {
    Get.snackbar("", "",
        snackPosition: SnackPosition.TOP,
        borderRadius: 0,
        titleText: Text(
          message,
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontFamily: "InterBold"),
        ),
        margin: EdgeInsets.all(0),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(days: 365),
        messageText: Container(
          margin: EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                color: Colors.white70,
                text: "Not Now",
                txtcolor: Colors.black.withOpacity(0.6),
                fontSize: 16,
                onPressed: () {
                  Get.back();
                },
              ),
              CustomButton(
                color: Colors.white,
                text: "Deposit $currency$balance",
                txtcolor: Colors.green,
                fontSize: 16,
                onPressed: () {
                  Get.back();
                  Get.to(() => WalletPage());
                },
              )
            ],
          ),
        ));
  }

  static leaveEngine() async {
    try {
      if (engine != null) {
        await engine.leaveChannel();
        await engine.destroy();
        Get.find<CurrentRoomController>().room = null;
      }
    } catch (e) {
    }
  }

  static var alert;

  static void deleteRoom(
      {Room room,
      UserModel currentuser,
      BuildContext context,
      StreamSubscription<DocumentSnapshot> roomlistener}) {
    if (alert == null) {
      alert = new CupertinoAlertDialog(
        content: new Text('Room does not exists any longer'),
        actions: <Widget>[
          new CupertinoDialogAction(
              child: const Text('End Room'),
              isDestructiveAction: false,
              onPressed: () async {
                roomlistener.cancel();
                Navigator.pop(context);
                Navigator.pop(context);
                Database.deleteRoomInFirebase(room.roomid);
                await UserApi().updateUser({"activeroom": ""}, currentuser.uid);
                currentuser.activeroom = "";
                await leaveEngine();
                alert = null;
              }),
        ],
      );

      //show alert
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return alert;
          });
    }
  }

  static ChoiceChip buildChoiceChip(
      String text, BuildContext context, bool isSelected,
      {ValueChanged<bool> onSelected}) {
    var theme = Theme.of(context);
    return ChoiceChip(
      label: Text(text),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Style.indigo,
      backgroundColor: theme.scaffoldBackgroundColor,
      labelStyle: theme.textTheme.bodyText1
          .copyWith(color: isSelected ? Style.AccentBlue : theme.disabledColor),
      elevation: 0,
      side: BorderSide(color: theme.cardColor, width: 2),
      labelPadding: EdgeInsets.symmetric(horizontal: 50),
    );
  }

  static depositAmount(BuildContext context, String type, String currency,
      {Function onButtonPressed, UserModel userModel}) {
    var amountcontroller = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Style.LightBrown,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
              initialChildSize: 0.9,
              expand: false,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Icon(Icons.clear, size: 30, color: Colors.black),
                      ),
                    ),

                    SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                type == "send"
                                    ? "How much ${currency == gccurrency ? "Gistcoin" : "Money"} you want to send to ${userModel.firstname}"
                                    : "Deposit  $type",
                                style: TextStyle(fontSize: 21, color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              decoration: new BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                controller: amountcontroller,
                                maxLength: null,
                                maxLines: null,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                      fontSize: 20,
                                    ),
                                    prefixIcon: currency == gccurrency
                                        ? Icon(Icons.account_balance_wallet_sharp)
                                        : Icon(CupertinoIcons.money_dollar),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    fillColor: Colors.white),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            CustomButton(

                                text: type == "send" ? "Send" : "Deposit",
                                color: Style.Blue,
                                onPressed: () {
                                  int amount = int.parse(amountcontroller.text);
                                  if (amount > 0) {
                                    onButtonPressed(type, amountcontroller.text);
                                  } else {
                                    topTrayPopup(
                                        "Amount has to be greater than 0");
                                  }
                                })
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                );
              });
        });
      },
    );
  }

  static donateToClub(BuildContext context, String type, String currency,
      {Function onButtonPressed, Club club}) {
    var amountcontroller = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Style.AccentBrown,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
              initialChildSize: 0.9,
              expand: false,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Icon(Icons.clear, size: 30, color: Colors.white),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            type == "send"
                                ? "How much ${currency == gccurrency ? "Gistcoin" : "Money"} you want to donate to ${club.title} club"
                                : "Deposit  $type",
                            style: TextStyle(fontSize: 21, color: Colors.white),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: new BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              controller: amountcontroller,
                              maxLength: null,
                              maxLines: null,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                  ),
                                  prefixIcon: currency == gccurrency
                                      ? Icon(Icons.account_balance_wallet_sharp)
                                      : Icon(CupertinoIcons.money_dollar),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  fillColor: Colors.white),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CustomButton(
                              text: type == "send" ? "Send" : "Deposit",
                              color: Style.AccentBlue,
                              onPressed: () {
                                int amount = int.parse(amountcontroller.text);
                                if (amount > 0) {
                                  onButtonPressed(type, amountcontroller.text);
                                } else {
                                  topTrayPopup(
                                      "Amount has to be greater than 0");
                                }
                              })
                        ],
                      ),
                    ),
                    Spacer(),
                  ],
                );
              });
        });
      },
    );
  }

  static Future<void> raisehand(Room room) async {
    topTrayPopup(
        " you  raised your hand! we'll let the speakers know you want to talk..");

    OngoingRoomApi().addRaisedHands(Get.find<UserController>().user.uid, room.roomid);

    //SEND NOTIFICATION TO THE SPEAKER
    // List<String> users = [];
    // room.users.forEach((element) {
    //   if (element.usertype == "host") {
    //     users.add(element.uid);
    //   }
    // });
    // PushNotificationsManager().callOnFcmApiSendPushNotifications(users, "", "${Get.find<UserController>().user.username} want to speak");
  }

  static showPaymentOptions(BuildContext contextt) {
    return showCupertinoModalPopup(
      context: contextt,
      builder: (BuildContext context) => CupertinoActionSheet(
          title: Text("Payment options"),
          actions: [
            CupertinoActionSheetAction(
              child: Text("GistCoin", style: TextStyle(fontSize: 16)),
              onPressed: () {
                Get.back();
                depositAmount(context, "GistCoin", gccurrency,
                    onButtonPressed: (type, amount) async {
                  if (amount.toString().length >= 6) {
                    //show alert message
                    topTrayPopup("You cannot deposit  $amount GIST",
                        bgcolor: Colors.green);
                    return;
                  } else {
                    Get.back();
                    showDialog(
                        context: contextt,
                        builder: (BuildContext context) {
                          return CustomDialogBox(
                            amount: amount,
                          );
                        });
                  }

                  // Navigator.pop(context);
                  // UserModel profile = Get.find<UserController>().user;
                  // Database.updateProfileData(profile.uid,
                  //     {"gcbalance": profile.gcbalance + double.parse(amount)});
                  //
                  // Database().addTransactions(
                  //     userModel: profile,
                  //     txtReason: "Deposit",
                  //     amount: "GIST $amount",
                  //     type: "1");
                  //
                  // //show alert message
                  // topTrayPopup("You have deposited  $amount GIST successfully",
                  //     bgcolor: Colors.green);
                });

                // Get.back();
              },
            ),
            // CupertinoActionSheetAction(
            //   child: Text("Paypal", style: TextStyle(fontSize: 16)),
            //   onPressed: () {
            //     Functions.depositAmount(context, "PayPal", dollarcurrency);
            //   },
            // ),
            // CupertinoActionSheetAction(
            //   child: Text("Stripe", style: TextStyle(fontSize: 16)),
            //   onPressed: () {
            //     Get.back();
            //     Functions.depositAmount(context, "Stripe", dollarcurrency);
            //   },
            // )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel',
                style: TextStyle(fontSize: 16, color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
    );
  }

  paginationFunction(){
    ScrollController _scrollController;
  }

  sendNotificationToSpeakerFollowers(var user, String roomId) async {
    List users = await UserApi().getUserFollowers(user.uid);

    List<String> userTokens = [];
    users.forEach((e) => userTokens.add(UserModel.fromJson(e).firebasetoken));


    PushNotificationsManager().callOnFcmApiSendPushNotifications(
        userTokens,
        "${user.getName()} is speaking",
        "Join room?",
        "RoomScreen",
        roomId);
  }
}
