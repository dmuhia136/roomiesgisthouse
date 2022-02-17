import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/clubs/view_club.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/activity_api.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/round_image.dart';
import 'package:intl/intl.dart';

import '../../widgets/widgets.dart';
import 'lounge_screen.dart';

class NotificationActivities extends StatefulWidget {
  @override
  _NotificationActivitiesState createState() => _NotificationActivitiesState();
}

class _NotificationActivitiesState extends State<NotificationActivities> {
  StreamSubscription<dynamic> stream;
  List<ActivityItem> activities = [];
  bool loading = true;
  ScrollController _scrollController;

  @override
  void initState() {
    // stream = activitiesRef
    //     .where("to", isEqualTo: Get.find<UserController>().user.uid)
    //     .orderBy("time", descending: true)
    //     .snapshots()
    //     .listen((event) {
    //   activities.clear();
    //   if (event.docs.length > 0) {
    //     event.docs.forEach((element) {
    //       activities.add(ActivityItem.fromJson(element.data(), element.id));
    //     });
    //   }
    //   setState(() {});
    // });
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.atEdge) {
          if (_scrollController.position.pixels == 0)
            {}
          else {
            //getActivities(true);
          }
        }
      });

    getActivities(false);
    super.initState();
  }

  var last = null;
  int loadMoreMsgs = 20;
  bool moreusers = true;

  getActivities(bool more) async {
    if (more == false) {
      loading = true;
      setState(() {});
      List activitiesFromApi = await ActivityApi().getActivitiesForUser(Get.find<UserController>().user.uid);

        activities.clear();
        if (activitiesFromApi.length > 0) {
          last = activitiesFromApi.last;
          activitiesFromApi.forEach((element) {
            activities.add(ActivityItem.fromJson(element, element['_id']));
          });
        }

        loading = false;
        setState(() {});
    } else {
      if (moreusers == false) {
        return;
      }
      // Functions.debug(last["username"]);
      loading = true;
      setState(() {});
      List activitiesFromApi = await ActivityApi()
          .getActivitiesForUserAfter(Get.find<UserController>().user.uid, ActivityItem.fromJson(last, last['_id']));


            if (activitiesFromApi.length < loadMoreMsgs) {
              moreusers = false;
            } else {
              last = activitiesFromApi.last;
            }

      activitiesFromApi.forEach((element) {
              activities.add(ActivityItem.fromJson(element, element.id));
            });
            loading = false;
            setState(() {});

    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image.asset(
        //   "assets/images/bg.png",
        //   height: MediaQuery.of(context).size.height * 100,
        //   fit: BoxFit.cover,
        // ),
        Scaffold(
            backgroundColor: Style.themeColor,
            body: CupertinoPageScaffold(
              backgroundColor: Colors.transparent,
              navigationBar: CupertinoNavigationBar(
                border: null,
                padding: EdgeInsetsDirectional.only(top: 20),
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.back,
                    size: 25,
                    color: CupertinoColors.black,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
                middle: Text(
                  "NOTIFICATIONS",
                  textScaleFactor: 1.0,
                  style: TextStyle(fontSize: 21, color: Colors.black),
                ),
              ),
              child: Column(
                mainAxisAlignment: activities.length == 0
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (activities.length == 0)
                    noDataWidget("No Activities yet", fontsize: 21, colors: Colors.black),
                  if (activities.length > 0)
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          physics: ScrollPhysics(),
                          itemBuilder: (lc, index) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (activities[index].type ==
                                        "clubinvite") {
                                      Club club = await Database()
                                          .getClubByIdDetails(
                                              activities[index].actionkey);
                                      Get.to(() => ViewClub(
                                            club: club,
                                          ));
                                    } else if (activities[index].type ==
                                        "user") {
                                      UserModel user =
                                          await Database.getUserProfile(
                                              activities[index].actionkey);
                                      Get.to(() => ProfilePage(
                                          profile: user, fromRoom: false));
                                    } else if (activities[index].type ==
                                        "room") {
                                      Room room = await Database()
                                          .getRoomDetails(
                                              activities[index].actionkey);
                                      if (room != null) {
                                        joinexistingroom(
                                            room: room,
                                            currentUser:
                                                Get.find<UserController>().user,
                                            context: context);
                                      } else {
                                        topTrayPopup("The room has ended");
                                      }
                                    } else if (activities[index].type ==
                                        "upcomingroom") {
                                      UpcomingRoom upcoming =
                                          UpcomingRoom.fromJson(
                                              await Database.getOneUpcomingRoom(
                                                  activities[index].actionkey));
                                      if (upcoming == null) {
                                        Room room = await Database()
                                            .getRoomDetails(
                                                activities[index].actionkey);
                                        if (room != null) {
                                          joinexistingroom(
                                              room: room,
                                              currentUser:
                                                  Get.find<UserController>()
                                                      .user,
                                              context: context);
                                        } else {
                                          topTrayPopup("The room has ended");
                                        }
                                      } else {
                                        topTrayPopup(
                                            "The room has not started");
                                      }
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        RoundImage(
                                          url: activities[index].imageurl,
                                          txtsize: 10,
                                          txt: activities[index].name,
                                          borderRadius: 18,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: Wrap(
                                            children: [
                                              Text(
                                                activities[index].name,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                '${activities[index].message}',
                                                style: TextStyle(
                                                  color: Style.DarkBrown,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Text(
                                            Functions.timeAgoSinceDate(
                                                DateFormat("dd-MM-yyyy h:mma")
                                                    .format(DateTime.fromMillisecondsSinceEpoch(
                                                        int.parse(activities[index]
                                                            .time)))),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                if (activities[index].type == "clubinvite" &&
                                    activities[index].actioned == false)
                                  Column(
                                    children: [
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            CustomButton(
                                              onPressed: () {
                                                Database.acceptClubInvite(
                                                    activities[index]
                                                        .actionkey);
                                                Database.activityUpdate(
                                                    activities[index].id,
                                                    {"actioned": true});
                                              },
                                              minimumWidth: 150,
                                              minimumHeight: 20,
                                              color: Style.AccentBlue,
                                              fontSize: 12,
                                              text: 'Join',
                                            ),
                                            CustomButton(
                                              onPressed: () {},
                                              minimumWidth: 150,
                                              minimumHeight: 20,
                                              color: Colors.white,
                                              txtcolor: Style.AccentBlue,
                                              fontSize: 12,
                                              text: 'Ignore',
                                            )
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        height: 1,
                                      ),
                                    ],
                                  )
                              ],
                            );
                          },
                          itemCount: activities.length,
                        ),
                      ),
                    ),
                  if (loading == true)
                    Center(
                      child: Container(
                          // margin: EdgeInsets.symmetric(horizontal: 40),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          // decoration: BoxDecoration(
                          //     color: Style.AccentBlue,
                          //     borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Loading more activities....",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ))
                            ],
                          )),
                    )
                ],
              ),
            )),
      ],
    );
  }
}
