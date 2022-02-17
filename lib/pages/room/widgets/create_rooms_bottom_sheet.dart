import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/room/followers_match_grid_sheet.dart';
import 'package:gisthouse/services/database_api/club_api.dart';
import 'package:gisthouse/util/strings.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/round_button.dart';
import 'package:gisthouse/widgets/round_image.dart';
import 'package:gisthouse/widgets/upgrade_account_sheet.dart';

import '../../../widgets/upgrade_account_sheet.dart';

List<RoomItem> lobbyBottomSheets = [];

class LobbyBottomSheet extends StatefulWidget {
  final Function onButtonTap;
  final Function onChange;

  const LobbyBottomSheet({Key key, this.onButtonTap, this.onChange})
      : super(key: key);

  @override
  _LobbyBottomSheetState createState() => _LobbyBottomSheetState();
}

class _LobbyBottomSheetState extends State<LobbyBottomSheet> {
  var selectedButtonIndex = 0;
  var _textFieldController = new TextEditingController();
  final TextEditingController textController = new TextEditingController();
  final TextEditingController amountcontroller = new TextEditingController();
  List<UserModel> roomusers = [];
  bool gistcoin = true;

  final globalScaffoldKey = GlobalKey<ScaffoldState>();

  String txterror = "";

  callback(List<UserModel> users, Room room, StateSetter state, send) {
    roomusers = users;
    state(() {});
  }

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    lobbyBottomSheets = RoomItem().getItems();

    populateClubs();

    // clubRef
    //     .where("members",
    //         arrayContainsAny: [Get.find<UserController>().user.uid])
    //     .get()
    //     .then((value) {
    //       value.docs.forEach((element) {
    //         Club club = Club.fromJson(element);
    //         if (club.membercanstartrooms == true ||
    //             club.ownerid == Get.find<UserController>().user.uid) {
    //           RoomItem roomItem = RoomItem.fromJson({
    //             'image': '',
    //             'text': club.title,
    //             'type': 'club',
    //             'selectedMessage': 'Start a room for ${club.title}',
    //             'club': club
    //           });
    //           lobbyBottomSheets.add(roomItem);
    //         }
    //       });
    //       setState(() {});
    //     });
  }

  populateClubs() async {
    var clubsFromApi =
        await ClubApi().userClubs(Get.find<UserController>().user.uid);

    clubsFromApi.forEach((element) {
      Club club = Club.fromJson(element);
      if (club.membercanstartrooms == true ||
          club.ownerid == Get.find<UserController>().user.uid) {
        RoomItem roomItem = RoomItem.fromJson({
          'image': '',
          'text': club.title,
          'type': 'club',
          'selectedMessage': 'Start a room for ${club.title}',
          'club': club
        });
        lobbyBottomSheets.add(roomItem);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: globalScaffoldKey,
      color: Style.LightBrown,
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 20,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          InkWell(
            onTap: () {
              addTopicDialog(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              alignment: Alignment.centerRight,
              child: Text(
                '+ Add a Topic',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: lobbyBottomSheets.length > 4
                ? 250
                : MediaQuery.of(context).size.height * 0.2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Wrap(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0, len = 4; i < len; i++)
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            setState(() {
                              selectedButtonIndex = i;
                            });
                            widget.onChange(
                                lobbyBottomSheets[selectedButtonIndex].text);
                          },
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                                color: i == selectedButtonIndex
                                    ? Style.AccentBrown
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: i == selectedButtonIndex
                                      ? Style.AccentBrown
                                      : Colors.transparent,
                                )),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: i == selectedButtonIndex
                                          ? Style.AccentBrown
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: i == selectedButtonIndex
                                            ? Style.AccentBrown
                                            : Colors.transparent,
                                      )),
                                  padding: const EdgeInsets.all(5),
                                  child: RoundImage(
                                    width: 60,
                                    height: 60,
                                    borderRadius: 20,
                                    path: lobbyBottomSheets[i].image,
                                    txt: "",
                                  ),
                                ),
                                Text(
                                  lobbyBottomSheets[i].text,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Wrap(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    direction: Axis.horizontal,
                    children: [
                      for (var i = 4, len = lobbyBottomSheets.length;
                          i < len;
                          i++)
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            setState(() {
                              selectedButtonIndex = i;
                            });
                            widget.onChange(
                                lobbyBottomSheets[selectedButtonIndex].text);
                          },
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                color: i == selectedButtonIndex
                                    ? Style.AccentBrown
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: i == selectedButtonIndex
                                      ? Style.AccentBrown
                                      : Colors.transparent,
                                )),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: i == selectedButtonIndex
                                          ? Style.AccentBrown
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: i == selectedButtonIndex
                                            ? Style.AccentBrown
                                            : Colors.transparent,
                                      )),
                                  padding: const EdgeInsets.all(5),
                                  child: RoundImage(
                                    width: 60,
                                    height: 60,
                                    borderRadius: 20,
                                    url: lobbyBottomSheets[i].image,
                                    txt: lobbyBottomSheets[i].text,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    lobbyBottomSheets[i].text.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: "InterBold",
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 1,
            height: 40,
            indent: 20,
            endIndent: 20,
            color: Color(0XFF425171),
          ),
          if (lobbyBottomSheets[selectedButtonIndex].club != null)
            lobbyBottomSheets[selectedButtonIndex].slogan == "Paid"
                ? showPayWidget()
                : showToMakeClubRoomPaid(),
          if (lobbyBottomSheets[selectedButtonIndex].text == "Paid")
            showPayWidget(),
          SizedBox(
            height: 20,
          ),
          Column(
            children: [
              Text(
                lobbyBottomSheets[selectedButtonIndex].selectedMessage,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              if (lobbyBottomSheets[selectedButtonIndex].slogan.isNotEmpty)
                Text(
                  lobbyBottomSheets[selectedButtonIndex].slogan,
                  style: TextStyle(fontSize: 13, color: Colors.white),
                )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          lobbyBottomSheets[selectedButtonIndex].type == "private" &&
                  roomusers.length == 0
              ? CustomButton(
                  radius: 8,
                  color: Color(0XFF00FFB0),
                  txtcolor: Colors.black,
                  fontSize: 15,
                  onPressed: () {
                    showModalBottomSheet(
                        backgroundColor: Style.AccentBlue,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15.0)),
                        ),
                        context: context,
                        builder: (context) {
                          //3
                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter customState) {
                            return DraggableScrollableSheet(
                                expand: false,
                                builder: (BuildContext context,
                                    ScrollController scrollController) {
                                  return Container(
                                      padding: EdgeInsets.only(top: 20),
                                      child: FollowerMatchGridPage(
                                          callback: callback,
                                          title: "With...",
                                          fromroom: false,
                                          state: setState,
                                          customState: customState));
                                });
                          });
                        });
                  },
                  text: 'Choose People',
                )
              :
              // lobbyBottomSheets[selectedButtonIndex].type == "paid"
              // ? Row(
              //     children: [
              //       Functions.buildChoiceChip(
              //         "GistCoin",
              //         context,
              //         gistcoin,
              //         onSelected: (value) {
              //           setState(() {
              //             gistcoin = true;
              //           });
              //         },
              //       ),
              //       // SizedBox(width: 8),
              //       // Functions.buildChoiceChip(
              //       //   "Cash",
              //       //   context,
              //       //   !gistcoin,
              //       //   onSelected: (value) {
              //       //     setState(() {
              //       //       gistcoin = false;
              //       //     });
              //       //   },
              //       // ),
              //       Spacer(),
              //       Expanded(
              //         flex: 10,
              //         child: createRoomButton(),
              //       ),
              //     ],
              //   )
              // :
              createRoomButton(),
          SizedBox(
            height: 20,
          ),
          if (txterror.isNotEmpty &&
              lobbyBottomSheets[selectedButtonIndex].text == "Paid")
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    txterror,
                    style: TextStyle(color: Colors.red),
                  ),
                ))
        ],
      ),
    );
  }

  createRoomButton() {
    return CustomButton(
      radius: 8,
      color: Color(0XFF00FFB0),
      txtcolor: Colors.black,
      onPressed: () {
        if (lobbyBottomSheets[selectedButtonIndex].text == "Paid") {
          if (Get.find<UserController>().user.premiumMember() == false) {
            showPremiumAlert(context,
                msg:
                    "This is a Premium Feature! Click Upgrade to find out how to upgrade",
                userModel: Get.find<UserController>().user);
            return;
          }
          if (amountcontroller.text.isEmpty) {
            txterror = 'Please enter amount';
            setState(() {});
            return null;
          }
        }

        widget.onButtonTap(
            lobbyBottomSheets[selectedButtonIndex].type,
            _textFieldController.text,
            roomusers,
            lobbyBottomSheets[selectedButtonIndex].club,
            amountcontroller.text == ""
                ? 0.0
                : double.parse(amountcontroller.text),
            gistcoin == true ? gccurrency : dollarcurrency);
      },
      text: 'Let\'s go',
      fontSize: 15,
    );
  }

//dialog for adding a topic
  Future<void> addTopicDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Style.AccentBrown,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add a Topic',
                    style: TextStyle(fontSize: 16, color: Colors.black)),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'e.g what if every body in the world loved each other?',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                )
              ],
            ),
            content: TextField(
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {});
              },
              controller: _textFieldController,
              decoration: InputDecoration(
                  hintText: "write topic here",
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12)),
            ),
            actions: <Widget>[
              TextButton(
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    color: Style.ButtonColor,
                    child: Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.black),
                    )),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Container(
                    color: Style.ButtonColor,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text(
                      'SET TOPIC',
                      style: TextStyle(color: Colors.black),
                    )),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  showPayWidget() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Style.AccentBrown),
      child: TextFormField(
        enabled: Get.find<UserController>().user.coinsEnabled == true,
        controller: amountcontroller,
        style: TextStyle(color: Colors.white, fontSize: 13),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(8.0, 13.0, 8.0, 8.0),
          prefixIcon: gistcoin == true
              ? Icon(
                  Icons.account_balance_wallet_sharp,
                  color: Style.HintColor,
                )
              : Icon(
                  CupertinoIcons.money_dollar,
                  color: Style.HintColor,
                ),
          hintText: Get.find<UserController>().user.coinsEnabled == true
              ? 'Amount'
              : 'Wallet Access Denied! Contact Admin.',
          hintStyle: TextStyle(color: Colors.white, fontSize: 13),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  showToMakeClubRoomPaid() {
    return InkWell(
      onTap: () {
        if (Get.find<UserController>().user.coinsEnabled == true) {
          lobbyBottomSheets[selectedButtonIndex].slogan = "Paid";
          setState(() {});
        } else {
          blockCheck();
        }
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.green),
        child: Center(
          child: Text(
            "Make room paid?",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  blockCheck() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
            onWillPop: () async => false,
            // <-- Prevents dialog dismiss on press of back button.
            child: new CupertinoAlertDialog(
              title: new Text('Wallet Access Denied!'),
              content: new Text(
                  'You have been blocked from accessing your wallet. Contact Admin for more details'),
              actions: <Widget>[
                new CupertinoDialogAction(
                    child: const Text('Okay'),
                    onPressed: () async {
                      Navigator.pop(context);
                    }),
              ],
            )));
  }
}
