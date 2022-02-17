import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/onboarding/follow_friends.dart';
import 'package:gisthouse/services/database_api/club_api.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/firebase_refs.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/widgets.dart';

/*
    interests pick screen
 */
//ignore: must_be_immutable

class InterestsPick extends StatefulWidget {
  final String title;
  final String subtitle;
  final Club club;
  final Function selectedItemsCallback;
  final showbackarrow;
  final fromsignup;

  InterestsPick(
      {this.title,
      this.subtitle,
      this.selectedItemsCallback,
      this.club,
      this.showbackarrow = true,
      this.fromsignup = false});

  @override
  _InterestsPickState createState() => _InterestsPickState();
}

class _InterestsPickState extends State<InterestsPick> {
  bool isCallApi = false;
  bool loading = false;
  StreamSubscription<DocumentSnapshot> userlisterner;

  @override
  void initState() {
    super.initState();
    if (widget.club != null) {
      selectedItemList = widget.club.topics;
    }

    getFirebaseData();

    getUserFromApi();
  }

  getUserFromApi() async {
    var userFromApi =
        await UserApi().getUserById(FirebaseAuth.instance.currentUser.uid);

    Get.put(UserController()).user = UserModel.fromJson(userFromApi);

    setState(() {});
  }

  @override
  void dispose() {
    //userlisterner.cancel();
    super.dispose();
  }

  QuerySnapshot tempList;
  List<Interest> selectedItemList = [];

  @override
  Widget build(BuildContext context) {
    // loading = false;
    return loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Style.LightBrown,
            // set
            appBar: AppBar(
              backgroundColor: Style.LightBrown,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              elevation: 2,
              flexibleSpace: Container(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                            fontFamily: "InterLight",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.5,
                            // fontStyle: FontStyle.italic,
                            color: Colors.black),
                        children: [
                          TextSpan(text: "Add your interests so we can begin"),
                          TextSpan(
                              text: "\n   to personalize GitHouse for you."),
                          TextSpan(text: "\n     Interests are private for you")
                        ]),
                  ),
                ),
              ),
              centerTitle: true,
              toolbarHeight: 100.0,
            ),

            body: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 1.4,
                  child: Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: isCallApi
                        ? Center(child: CircularProgressIndicator())
                        : ListView(
                            children: [
                              if (widget.showbackarrow == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Stack(
                                    children: [

                                      Center(
                                        child: Text(
                                          widget.title != null
                                              ? widget.title
                                              : 'Interests',
                                          style: TextStyle(
                                              fontFamily: "InterExtraBold",
                                              fontSize: 25,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: tempList.docs.length,
                                  itemBuilder: (BuildContext context, int i) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${tempList.docs[i].id}',
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.black,
                                                fontFamily: "InterSemiBold")),
                                        SizedBox(height: 10),
                                        funListViewData(
                                            list: tempList.docs[i]['data'],
                                            categoryName:
                                                tempList.docs[i].id.toString()),
                                      ],
                                    );
                                  }),
                            ],
                          ),
                  ),
                ),
                Spacer(),
                Container(

                  color: Colors.transparent,

                  // if (widget.fromsignup == true)

                  child: Center(
                    child: CustomButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 80),
                        onPressed: () {
                          Get.to(() => FollowFriends());
                        },
                        color: Style.Blue,
                        text: 'Next'),
                  ),
                )
              ],
            ),
          );
  }

  /*
    single interest widget
   */
  List<Widget> listMyWidgets(List<dynamic> docs) {
    List<Widget> list = [];

    for (var itemm in docs) {
      Interest item = Interest.fromJson2(itemm, docs.indexOf(itemm).toString());
      list.add(GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Text(
            item.title,
            style: TextStyle(
                fontSize: 13,
                fontFamily: "InterRegular",
                color: getColor(item.title) ||
                        (widget.club == null &&
                            Get.put(UserController())
                                .user
                                .interests
                                .contains(item.title))
                    ? Colors.white
                    : Colors.black),
          ),
          decoration: BoxDecoration(
            color: getColor(item.title) ||
                    (widget.club == null &&
                        Get.put(UserController())
                            .user
                            .interests
                            .contains(item.title))
                ? Style.Blue
                : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  // color: ccc.getactiveBgColor.value,
                  // blurRadius: 4,
                  ),
            ],
          ),
        ),
        onTap: () {
          if (widget.club != null) {
            updateClubTopics(item);
          } else {
            updateUserInterests(item);
          }
          setState(() {});
        },
      ));
    }
    return list;
  }

  updateUserInterests(Interest item) async {
    selectedItemList.clear();
    Get.put(UserController()).user.interests.forEach((element) {
      selectedItemList.add(Interest(title: element));
    });
    bool isAddData = true;
    for (var i = 0; i < selectedItemList.length; i++) {
      if (selectedItemList[i].title == item.title) {
        isAddData = false;
        selectedItemList.removeAt(i);
        Get.find<UserController>().user.interests.removeAt(i);
        await UserApi().removeInterestForUser(item.title);
        break;
      } else {
        isAddData = true;
      }
    }
    if (isAddData) {
      selectedItemList.add(Interest(title: item.title));
      Get.find<UserController>().user.interests.add(item.title);

      //check if its from signup
      if (widget.selectedItemsCallback != null) {
        widget.selectedItemsCallback(selectedItemList);
      }

      await UserApi().addInterestForUser(item.title);
    }

    setState(() {});
  }

  void updateClubTopics(Interest item) {
    if (selectedItemList.length == 3 &&
        selectedItemList.indexWhere((element) => element.title == item.title) <
            0) {
      var alert = new CupertinoAlertDialog(
        title: new Text(''),
        content: new Text('A club can only have 3 topics maximum'),
        actions: <Widget>[
          new CupertinoDialogAction(
              child: const Text('Okay'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      );
      showDialog(
          context: context,
          builder: (context) {
            return alert;
          });
    } else {
      bool isAddData = true;
      for (var i = 0; i < selectedItemList.length; i++) {
        if (selectedItemList[i].title == item.title) {
          isAddData = false;
          selectedItemList.removeAt(i);
          if (widget.club.id != null) {
            ClubApi().removeTopicClub(widget.club.id, item.toMap());
          } else {
            widget.selectedItemsCallback(selectedItemList);
          }

          break;
        } else {
          isAddData = true;
        }
      }
      if (isAddData) {
        selectedItemList.add(Interest(title: item.title, id: item.id));

        if (widget.club.id != null) {
          ClubApi().addTopicClub(widget.club.id, item.toMap());
        } else {
          widget.selectedItemsCallback(selectedItemList);
        }
      }
    }
  }

// ==========   Use for show data in gridview based on category     ================

  Widget funListViewData({List list, String categoryName}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 650,
        child: Wrap(
          direction: Axis.horizontal,
          children: listMyWidgets(list),
        ),
      ),
    );
  }

// ==========   Use for get data from firebase     ================

  getFirebaseData() async {
    isCallApi = true;
    setState(() {});
    tempList = await interestsRef.get();
    isCallApi = false;
    setState(() {});
  }

  /*
      assign intersts link color
   */
  bool getColor(String itemName) {
    bool val = false;
    if (widget.club != null) {
      for (var i = 0; i < selectedItemList.length; i++) {
        if (selectedItemList[i].title == itemName ||
            selectedItemList
                    .indexWhere((element) => element.title == itemName) >
                0) {
          val = true;
          break;
        } else {
          val = false;
        }
      }
    } else {
      for (var i = 0; i < selectedItemList.length; i++) {
        if (selectedItemList[i].title == itemName ||
            Get.find<UserController>().user.interests.contains(itemName)) {
          val = true;
          break;
        } else {
          val = false;
        }
      }
    }
    return val;
  }
}
