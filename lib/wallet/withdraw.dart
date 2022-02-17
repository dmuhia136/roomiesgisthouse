import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/profiles/widgets/user_profile_image.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/style.dart';

class WithdrawFunds extends StatefulWidget {
  const WithdrawFunds({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WithdrawFundsState();
  }
}

class _WithdrawFundsState extends State<WithdrawFunds> with WidgetsBindingObserver, SingleTickerProviderStateMixin  {
  StreamSubscription<DocumentSnapshot> streamSubscription;
  UserModel userModel;
  bool isCallApi = false, loading = false, gistcoin = false;
  TabController _tabController;
  FocusNode _focus = new FocusNode();
  List<UserModel> _allUsers = [];

  TextEditingController _controller = new TextEditingController();
  var profile = Get.put(OnboardingController());

  Future<List<UserModel>> users;

  int tabindex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _focus.addListener(_onFocusChange);
    //query users that i can follow

    getUserFromApi();

    super.initState();
  }

  getUserFromApi() async {
    List userFromApi = await UserApi().getAllUsers();
    _allUsers = userFromApi.map((e) => UserModel.fromJson(userFromApi)).toList();
    setState(() {});
  }

  void _onFocusChange() {
    setState(() {

    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.AccentBrown,
      body: CupertinoPageScaffold(
        backgroundColor: Style.AccentBrown,
        navigationBar: CupertinoNavigationBar(
          border: null,
          padding: EdgeInsetsDirectional.only(top: 20),
          backgroundColor: Style.AccentBrown,
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
            "WITHDRAW FUNDS",
            textScaleFactor: 1.0,
            style: TextStyle(fontSize: 18, fontFamily: "InterLight"),
          ),
        ),
        child: Container(
          child: Expanded(child: Container(margin:EdgeInsets.only(top: 20),child: tabsSearch())),
        ),
      ),
    );
  }

  tabsSearch(){
    return Column(
      children: [
        // give the tab bar a height [can change hheight to preferred height]
        Container(
          height: 35,
          child: TabBar(
            indicatorColor: Style.indigo,
            indicatorWeight: 3,
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            onTap: (index){
              setState(() {
                tabindex = index;
              });
              searchData(_controller.text);
            },
            tabs: [
              // first tab [you can add an icon using the icon property]
              Tab(
                child: Text(
                  "Paypal",
                  style: TextStyle(fontFamily: "InterSemiBold",fontSize: 15),
                ),
              ),
              // first tab [you can add an icon using the icon property]
              Tab(
                child: Text(
                  "GistCoin",
                  style: TextStyle(fontFamily: "InterSemiBold",fontSize: 15),
                ),
              ),
              // first tab [you can add an icon using the icon property]
              Tab(
                child: Text(
                  "Stripe",
                  style: TextStyle(fontFamily: "InterSemiBold",fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: TabBarView(
              controller: _tabController,
              children: [
                Text("Paypal withdraw coming soon"),
                Text("GistCoin withdraw coming soon"),
                Text("Stripe withdraw coming soon")
              ],
            ),
          ),
        )
      ],
    );
  }


  Widget singleItem(UserModel user) {
    return Container(
      child: Row(
        children: [
          UserProfileImage(
            user: user,
            txt: user.firstname,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  user.bio,
                  textScaleFactor: 1,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 16,
          ),
          if(!_focus.hasFocus) TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Style.indigo,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                userModel != null && userModel.following.contains(user.uid)
                    ? "Following"
                    : "Follow",
                textScaleFactor: 1,
                style: TextStyle(
                  color: Style.indigo,
                  fontFamily: "InterSemiBold",
                  fontSize: 13
                ),
              ),
            ),
            onPressed: () {
              if (userModel.following.contains(user.uid)) {
                Database().unFolloUser(user.uid);
              } else {
                Database().folloUser(user);
              }
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  searchData(value) {
    users =  Database.searchUser(value);
  }
}
