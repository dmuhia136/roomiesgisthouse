import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/profiles/widgets/user_profile_image.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/strings.dart';
import 'package:gisthouse/util/style.dart';

class SearchWalletUsers extends StatefulWidget {
  const SearchWalletUsers({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchWalletUsersState();
  }
}

class _SearchWalletUsersState extends State<SearchWalletUsers> with WidgetsBindingObserver, SingleTickerProviderStateMixin  {
  UserModel userModel;
  bool isCallApi = false, loading = false, gistcoin = true;
  FocusNode _focus = new FocusNode();
  List<UserModel> _allUsers = [];

  TextEditingController _controller = new TextEditingController();
  var profile = Get.put(OnboardingController());

  Future<List<UserModel>> users;

  int tabindex = 0;

  @override
  void initState() {
    _focus.addListener(_onFocusChange);


    //query users that i can follow
    getUserFromApi();

    super.initState();
  }

  getUserFromApi() async {
    List user = await UserApi().getUserFollowing(Get.put(UserController()).user.countrycode);

    _allUsers.clear();
    user.forEach((element) {
      _allUsers.add(UserModel.fromJson(element.data()));
    });
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
              color: CupertinoColors.white,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          middle: Text(
            "SEARCH USER",
            textScaleFactor: 1.0,
            style: TextStyle(fontSize: 18, fontFamily: "InterLight", color: Colors.white),
          ),
        ),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 10, top: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Style.themeColor),
                      child: TextField(
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.blueAccent,
                          ),
                          focusNode: _focus,
                          controller: _controller,
                          onChanged: (value) async {
                            loading = true;
                            setState(() {

                            });
                            searchData(value);

                            loading = false;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(8.0, 13.0, 8.0, 8.0),
                            prefixIcon: Icon(Icons.search, color: Style.AccentBlue,),
                            hintText: "Find User to send to..",
                            hintStyle: TextStyle(
                              color: Style.AccentBlue,
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          )),
                    ),
                  ),
                  if(_focus.hasFocus) Padding(
                    padding: const EdgeInsets.only(top: 18, right: 20),
                    child: TextButton(onPressed : (){
                      _focus.unfocus();
                      _controller.text = "";
                      searchData("");
                      setState(() {

                      });
                    },child: Center(child: Text("cancel", style: TextStyle(fontSize: 16, color: Style.AccentGrey), textAlign: TextAlign.center,))),
                  )
                ],
              ),
             Expanded(child: Container(margin:EdgeInsets.only(top: 20),child: tabsSearch())),

            ],
          ),
        ),
      ),
    );
  }

  tabsSearch(){
    return Column(
      children: [
        // give the tab bar a height [can change hheight to preferred height]
        // Container(
        //   height: 35,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Functions.buildChoiceChip(
        //         "Cash",
        //         context,
        //         !gistcoin,
        //         onSelected: (value) {
        //           setState(() {
        //             gistcoin = false;
        //           });
        //         },
        //       ),
        //       SizedBox(width: 50),
        //       Functions.buildChoiceChip(
        //         "GistCoin",
        //         context,
        //         gistcoin,
        //         onSelected: (value) {
        //           setState(() {
        //             gistcoin = true;
        //           });
        //         },
        //       )
        //     ],
        //   ),
        // ),
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: loading == true ? Center(
              child: CircularProgressIndicator(),
            ) : Container(
              margin: EdgeInsets.only(top: 20),
              child: FutureBuilder(
                  future: users,
                  builder: (context, snapshot) {
                    if(snapshot.data !=null){
                      List<UserModel> users = snapshot.data;
                      if(users.length > 0 && users.indexWhere((element) => element.uid == Get.find<UserController>().user.uid) !=-1){
                        users.removeAt(users.indexWhere((element) => element.uid == Get.find<UserController>().user.uid));
                      }
                      if(users.length == 0) return Container();
                      return ListView.separated(
                        separatorBuilder: (c, i) {
                          return Container(
                            height: 15,
                          );
                        },
                        //added
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                              child: singleItem(users[index]),
                              onTap: (){
                                if(users[index].coinsEnabled == true) {
                                  Get.back();
                                  Functions.depositAmount(context, "send",
                                      gistcoin == true
                                          ? gccurrency
                                          : dollarcurrency,
                                      userModel: users[index],
                                      onButtonPressed: (type, amount) {
                                        Database().sendMoney(
                                            users[index], amount,
                                            gistcoin == true
                                                ? gccurrency
                                                : dollarcurrency);
                                      });
                                } else {
                                  blockCheck();
                                }
                              },
                          );
                        },
                      );
                    }else{
                      return Container();
                    }
                  }
              ),
            ),
          ),
        )
      ],
    );
  }

  void blockCheck() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
            onWillPop: () async => false,
            // <-- Prevents dialog dismiss on press of back button.
            child: new CupertinoAlertDialog(
              title: new Text('Not available!'),
              content: new Text(
                  'This user can not receive coins. Kindly try again later.'),
              actions: <Widget>[
                new CupertinoDialogAction(
                    child: const Text('Okay'),
                    onPressed: () async {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }),
              ],
            )));
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
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
    setState(() {
    });
  }
}
