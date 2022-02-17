import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/clubs/view_club.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:gisthouse/util/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/widgets/noitem_widget.dart';
import 'package:gisthouse/pages/profiles/widgets/user_profile_image.dart';
import 'package:gisthouse/widgets/widgets.dart';

class SearchView extends StatefulWidget {
  const SearchView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchViewState();
  }
}

class _SearchViewState extends State<SearchView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  UserModel userModel = Get.find<UserController>().user;
  QuerySnapshot tempList;
  List<Interest> selectedItemList = [];
  bool isCallApi = false, loading = false;
  FocusNode _focus = new FocusNode();
  List<UserModel> _allUsers = [];
  TabController _tabController;

  ScrollController _scrollController;
  int loadMoreMsgs = 20; // at first it will load only 25
  // int a = 50;

  TextEditingController _controller = new TextEditingController();
  var profile = Get.put(OnboardingController());

  Future<List<UserModel>> users;
  Future<List<Club>> clubs;

  int tabindex = 0;
  bool moreusers = true;

  @override
  void initState() {
    //add list of users to remove from the query
    Get.find<UserController>()
        .user
        .following
        .add(Get.find<UserController>().user.uid);

    //query users that i can follow

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.atEdge) {
          if (_scrollController.position.pixels == 0) {
          } else {
            // setState(() {
            // loadMoreMsgs = loadMoreMsgs + a;
            // });
            getUsers(true);
          }
        }
      });
    _tabController = TabController(length: 2, vsync: this);
    _focus.addListener(_onFocusChange);

    getUsers(false);

    super.initState();
  }

  var last = null;

  getUsers(bool more) async {
    List<String> removeusers = Get.find<UserController>().user.following;
    if (more == false) {
      loading = true;
      setState(() {});
      List usersFromApi = await UserApi().getAllUsers();

      _allUsers.clear();
      last = usersFromApi.last;

      usersFromApi.forEach((element) {
        UserModel userModel = UserModel.fromJson(element);
        // _allUsers.add(UserModel.fromJson(element.data()));
        if (!removeusers.contains(userModel.uid)) {
          _allUsers.add(UserModel.fromJson(element));
        }
      });

      loading = false;
      setState(() {});
    } else {
      if (moreusers == false) {
        return;
      }
      loading = true;
      setState(() {});

      List usersFromApi = await UserApi().getAllUsersAfter(last['id']);

      if (usersFromApi.length < loadMoreMsgs) {
        moreusers = false;
      } else {
        last = usersFromApi.last;
      }

      usersFromApi.forEach((element) {
        UserModel userModel = UserModel.fromJson(element);
        // _allUsers.add(UserModel.fromJson(element.data()));
        if (!removeusers.contains(userModel.uid)) {
          _allUsers.add(UserModel.fromJson(element));
        }
      });
      loading = false;
      setState(() {});
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void dispose() {
    super.dispose();
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
    return Container(
      decoration: BoxDecoration(color: Style.themeColor),
      child: Scaffold(
        backgroundColor: Style.themeColor,
        body: Container(
          margin: EdgeInsets.only(top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stack(
              //   children: [
              //     CupertinoButton(
              //       padding: EdgeInsets.zero,
              //       child: Icon(
              //         CupertinoIcons.back,
              //         size: 25,
              //         color: CupertinoColors.black,
              //       ),
              //       onPressed: () {
              //         Get.back();
              //       },
              //     ),
              //
              //   ],
              // ),

//search bar row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: EdgeInsets.only(left: 10, top: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[400]),
                      child: TextField(
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          focusNode: _focus,
                          controller: _controller,
                          onChanged: (value) async {
                            loading = true;
                            setState(() {});
                            searchData(value);

                            loading = false;
                          },
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(8.0, 13.0, 8.0, 8.0),

//search Icon
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.black54),
                              hintText: "Find People and Clubs",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.black54))),
                    ),
                  ),

// Cancel button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Style.Blue,
                            ),
                          )),
                    ),
                  ),
                ],
              ),
              if (_focus.hasFocus)
                Expanded(
                    child: Container(
                        margin: EdgeInsets.only(top: 20), child: tabsSearch())),
              if (!_focus.hasFocus)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_buildSearchList(_controller.text).length == 0)
                          noDataWidget("No users yet to follow"),
                        if (_buildSearchList(_controller.text).length > 0)
                          Expanded(
                              child: ListView.separated(
                            controller: _scrollController,
                            separatorBuilder: (c, i) {
                              return Container(
                                height: 15,
                              );
                            },
                            itemCount:
                                _buildSearchList(_controller.text).length,
                            itemBuilder: (context, index) {
                              return singleItem(
                                  _buildSearchList(_controller.text)[index]);
                            },
                          )),
                      ],
                    ),
                  ),
                ),
              if (loading == true)
                Center(
                  child: Container(
                      // margin: EdgeInsets.symmetric(horizontal: 40),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      // decoration: BoxDecoration(
                      //     color: Style.AccentBlue,
                      //     borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Loading more users....",
                            style: TextStyle(color: Colors.black),
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
        ),
      ),
    );
  }

// tab controller
  tabsSearch() {
    return Column(
      children: [
        // give the tab bar a height [can change hheight to preferred height]
        Container(
          height: 35,
          child: TabBar(
            indicatorColor: Style.Blue,
            indicatorWeight: 3,
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            onTap: (index) {
              setState(() {
                tabindex = index;
              });
              searchData(_controller.text);
            },
            tabs: [
              // first tab [you can add an icon using the icon property]
              Tab(
                child: Text(
                  "People",
                  style: TextStyle(fontFamily: "InterSemiBold", fontSize: 15),
                ),
              ),
              // first tab [you can add an icon using the icon property]
              Tab(
                child: Text(
                  "Clubs",
                  style: TextStyle(fontFamily: "InterSemiBold", fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: TabBarView(
              controller: _tabController,
              children: [
                // first tab bar view widget
                loading == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 20),
                        child: FutureBuilder(
                            future: users,
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                List<UserModel> users = snapshot.data;
                                if (users.length == 0) return Container();
                                return ListView.separated(
                                  separatorBuilder: (c, i) {
                                    return Container(
                                      height: 15,
                                    );
                                  },
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    return singleItem(users[index]);
                                  },
                                );
                              } else {
                                return Container();
                              }
                            }),
                      ),
                // first tab bar view widget
                loading == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 20),
                        child: FutureBuilder(
                            future: clubs,
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                List<Club> clubs = snapshot.data;
                                if (clubs.length == 0) return Container();
                                return ListView.separated(
                                  separatorBuilder: (c, i) {
                                    return Container(
                                      height: 15,
                                    );
                                  },
                                  itemCount: clubs.length,
                                  itemBuilder: (context, index) {
                                    return singleClub(clubs[index]);
                                  },
                                );
                              } else {
                                return Container();
                              }
                            }),
                      ),
              ],
            ),
          ),
        )
      ],
    );
  }

  List<UserModel> _buildSearchList(String userSearchTerm) {
    List<UserModel> _searchList = [];
    if (userSearchTerm.isEmpty) {
      return _allUsers;
    }
    for (int i = 0; i < _allUsers.length; i++) {
      String name = _allUsers[i].getName();
      if (name.toLowerCase().contains(userSearchTerm.toLowerCase())) {
        _searchList.add(_allUsers[i]);
      }
    }
    return _searchList;
  }

  Widget singleItem(UserModel user) {
    return InkWell(
      onTap: () {
        Get.to(
          () => ProfilePage(
            profile: user,
            // userid: user.uid,
            fromRoom: false,
            isMe: user.uid == Get.find<UserController>().user.uid,
          ),
        );
      },
//search list items defined
      child: Container(
        child: Row(
          children: [
            UserProfileImage(
              user: user,
              txt: user.firstname,
              width: 45,
              height: 45,
              txtsize: 16,
              borderRadius: 18,
              clickacle: false,
            ),
            SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
//user name description
                  Text(
                    user.getName(),
                    textScaleFactor: 1,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
//user bio
                  Text(
                    user.bio,
                    textScaleFactor: 1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16,
            ),
            if (!_focus.hasFocus)
              TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
//follow button
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                      border: Border.all(color: Style.Blue, width: 2.0),
                      color: userModel != null &&
                              userModel.following.contains(user.uid)
                          ? Style.Blue
                          : Style.themeColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    userModel != null && userModel.following.contains(user.uid)
                        ? "Following"
                        : "Follow",
                    textScaleFactor: 1,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "InterLight",
                        fontSize: 13),
                  ),
                ),
                onPressed: () {
                  if (userModel.following.contains(user.uid)) {
                    userModel.following.remove(user.uid);
                    Database().unFolloUser(user.uid);
                  } else {
                    userModel.following.add(user.uid);
                    Database().folloUser(user);
                  }
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }


  //clubs
  Widget singleClub(Club club) {
    return InkWell(
      onTap: () {
        Get.to(() => ViewClub(
              club: club,
            ));
      },

//club details defined
      child: Container(
        child: Row(
          children: [
            RoundImage(
              url: club.imageurl,
              txt: club.title,
              width: 55,
              height: 55,
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
                    club.title.toUpperCase(),
                    textScaleFactor: 1,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: "InterSemiBold",
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    club.id == MAIN_CLUB_ID
                        ? "Headquarters"
                        : club.members.length.toString() + " Members",
                    textScaleFactor: 1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  searchData(value) async {
    if (tabindex == 0) {
      users = Database.searchUser(value);
    } else if (tabindex == 1) {
      clubs = Database.searchClub(value);
    }
  }
}
