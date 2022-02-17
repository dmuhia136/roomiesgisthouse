import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/club_api.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/loading.dart';
import 'package:gisthouse/widgets/noitem_widget.dart';
import 'package:gisthouse/widgets/round_image.dart';

//ignore: must_be_immutable
class FollowersList extends StatefulWidget {
  Club club;

  FollowersList({this.club});

  @override
  State<StatefulWidget> createState() {
    return _FollowersListState();
  }
}

class _FollowersListState extends State<FollowersList>
    with WidgetsBindingObserver {
  StreamSubscription<DocumentSnapshot> streamSubscription;
  QuerySnapshot tempList;
  List<Interest> selectedItemList = [];
  bool isCallApi = false;
  FocusNode _focus = new FocusNode();

  bool loading = false;
  TextEditingController _controller = new TextEditingController();
  var profile = Get.put(OnboardingController());
  UserModel userModel = Get.find<UserController>().user;

  @override
  void initState() {
    invitedlistener();
    _focus.addListener(_onFocusChange);
    super.initState();
  }

  void _onFocusChange() {
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
  }

  @override
  void dispose() {
    if(streamSubscription !=null){
      streamSubscription.cancel();
    }

    super.dispose();
  }

  //listening to the users profile cahnges
  invitedlistener() async {
    //listener for the current user profile followers and followed
    if(widget.club !=null){
          widget.club = await ClubApi().getClubsById(widget.club.id);
      setState(() {});

    }
  }

  bool getColor(String itemName) {
    bool val = false;
    for (var i = 0; i < selectedItemList.length; i++) {
      if (selectedItemList[i].title == itemName) {
        val = true;
        break;
      } else {
        val = false;
      }
    }
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Style.AccentBlue,
      body: CupertinoPageScaffold(

              backgroundColor: Style.themeColor,
              navigationBar: CupertinoNavigationBar(
                border: null,
                padding: EdgeInsetsDirectional.fromSTEB(0,10,10,10),
                backgroundColor: Style.themeColor,
                automaticallyImplyLeading: false,
//back button
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.back,
                    size: 35,
                    color: CupertinoColors.black,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
//Add members text
                middle: Text(
                  "ADD MEMBERS",
                  textScaleFactor: 1.0,
                  style: TextStyle(fontSize: 21, color: Colors.black),
                ),
                  trailing: widget.club.id == null ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
//done button
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        loading = true;
                      });
                      await Database().addClub(
                          title: widget.club.title,
                          description: widget.club.description,
                          allowfollowers: widget.club.allowfollowers,
                          membersprivate: widget.club.membersprivate,
                          membercanstartrooms: widget.club.membercanstartrooms,
                          selectedTopicsList: widget.club.topics);
                      setState(() {
                        loading = false;
                      });
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 23,
                          fontFamily: "InterSemiBold"),
                    ),
                  ),
                ) : null,
              ),
//textfield container
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[300]),
                      child: TextField(
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          focusNode: _focus,
                          controller: _controller,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(8.0, 13.0, 8.0, 8.0),
                            prefixIcon: Icon(Icons.search,color: Colors.black54),
                            hintText: "Find People",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Recommended Members",
                      style: TextStyle(fontSize: 16,color: Colors.black54),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                        child: FutureBuilder(
                            future: Database.getmyFollowers(excludeid: widget.club.ownerid),
                            builder: (context, snapshot) {

                              if(snapshot.connectionState == ConnectionState.waiting){
                                return loadingWidget(context);
                              }
                              if(!snapshot.hasData) {
                                return noDataWidget("No users to invite yet");
                              }
                              return ListView.separated(
                                separatorBuilder: (c, i) {
                                  return Container(
                                    height: 15,
                                  );
                                },
                                itemCount:
                                _buildSearchList(snapshot.data).length,
                                itemBuilder: (context, index) {
                                  return singleItem(
                                      _buildSearchList(snapshot.data)[index]);
                                },
                              );

                            })),
                  ],
                ),
              ),
            ),
    );
  }

  List<UserModel> _buildSearchList(List<UserModel> users) {
    List<UserModel> _searchList = [];
    if (_controller.text.isEmpty) {
      return users;
    }
    for (int i = 0; i < users.length; i++) {
      String name = users[i].getName();
      if (name.toLowerCase().contains(_controller.text.toLowerCase())) {
        _searchList.add(users[i]);
      }
    }
    return _searchList;
  }

  Widget singleItem(UserModel user) {
    return Container(
      child: Row(
        children: [
          RoundImage(
            url: user.smallimage,
            txt: user.username,
            height: 45,
            width: 45,
            txtsize: 14,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                ),
                Text(
                  user.bio,
                  textScaleFactor: 1,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Style.HintColor),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 16,
          ),
          if (widget.club.invited !=null && widget.club.invited.contains(user.uid) && !widget.club.members.contains(user.uid)) Wrap(
              children: ["✓", " Invited"].map((e) => Text(e, style: TextStyle(color: Style.indigo),)).toList(),
            ),
          if (widget.club.members !=null && widget.club.members.contains(user.uid)) Wrap(
              children: ["✓", " Member"].map((e) => Text(e, style: TextStyle(color: Style.indigo),)).toList(),
            ),
         if (!widget.club.members.contains(user.uid) && !widget.club.invited.contains(user.uid)) TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Style.indigo,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  "Invite",
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: Style.indigo,
                  ),
                ),
              ),
              onPressed: () async {
                if (widget.club == null) {
                  // Database().unInviteUser(widget.club, user);
                }
                else {
                  await Database().inviteUserToClub(widget.club, user);
                  widget.club.invited.add(user.uid);
                }
                setState(() {});
              },
            ),
        ],
      ),
    );
  }
}
