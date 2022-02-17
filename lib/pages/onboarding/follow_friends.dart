import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/home/home_page.dart';
import 'package:gisthouse/pages/onboarding/invite_only.dart';
import 'package:gisthouse/pages/profiles/widgets/user_profile_image.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/noitem_widget.dart';
import 'package:gisthouse/widgets/widgets.dart';

class FollowFriends extends StatefulWidget {
  const FollowFriends({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FollowFriendsState();
  }
}

class _FollowFriendsState extends State<FollowFriends> with WidgetsBindingObserver {
  UserModel userModel = Get.find<UserController>().user;
  List<String> followed = [];
  bool deselect = true;
  @override
  void initState() {

    super.initState();

    getUsersFromApi();
  }

  getUsersFromApi() async {
    var user = await UserApi().getUserById(FirebaseAuth.instance.currentUser.uid);

      userModel = UserModel.fromJson(user);
      followed = userModel.following;
      setState(() {});

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildGradientContainer() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Style.LightBrown.withOpacity(0.2),
              Style.LightBrown,
            ],
          )),
    );
  }
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: false,
          title: const Text('Are you sure?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("GistHouse will be be pretty quiet for you."),
              SizedBox(height: 20,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                      onTap: (){
                        deselect = !deselect;
                        setState(() {

                        });
                        Navigator.pop(context);
                      },
                      child: Text("NEVER MIND", style: TextStyle(color: Style.AccentBlue),)
                  ),
                  SizedBox(height: 20,),
                  InkWell(
                      onTap: (){
                        Navigator.pop(context);
                        Get.offAll(HomePage());
                      },
                      child: Text("YES", style: TextStyle(color: Style.AccentBlue),)
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset("assets/images/bg.png", height: MediaQuery.of(context).size.height * 100, fit: BoxFit.cover,),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: CupertinoPageScaffold(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30,),
                        Center(
                          child: Text(
                            "Follow new friends to have access to their rooms",
                            textScaleFactor: 1.0,
                            style: TextStyle(fontSize: 23, color: Colors.white, fontFamily: "InterSemiBold"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 30,),
                          Expanded(
                              child: FutureBuilder(
                                future: Database.friendsToFollow(),
                                builder: (context, snapshot) {
                                  if(snapshot.connectionState == ConnectionState.waiting){
                                    return Container(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  if(snapshot.data == null){
                                    return noDataWidget("No Friends to follow yet");
                                  }
                                  if(snapshot.hasData){
                                    List<UserModel> users = snapshot.data;
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
                                  }else{
                                    return noDataWidget("No friends to follow fo now");
                                  }
                                }
                              )),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: 200,
                          child: CustomButton(
                              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 25),
                              onPressed: () {
                                if(deselect == true){
                                  _showMyDialog();
                                }else {
                                  if(userModel.checkApproval() == true){
                                    Get.to(() => InviteOnly());
                                  }else{
                                    Get.offAll(HomePage());
                                  }

                                }

                              },
                              color: Style.AccentBlue,
                              text: userModel !=null && userModel.following.length == 0 ? "Skip ->" : 'Follow -> '),
                        ),
                      ),
                    ),

                    Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,child: Column(children: [
                      InkWell(
                        onTap: (){
                          deselect = !deselect;
                          if(deselect == true){
                            Database.updateProfileData(userModel.uid, {
                              "following": []
                            });
                          }else{
                            followed.forEach((element) { UserApi().followUser(element);});
                          }
                          setState(() {

                          });
                        },
                        child: Text(deselect == true ? "Or use our suggestons" : "Deselect all", style: TextStyle(color: Style.indigo, fontFamily: "InterBold"),),
                      )
                    ],))
                  ],
                ),
              ),
            ),
          ),
        ),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                ),
                Text(
                  user.bio,
                  textScaleFactor: 1,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white),

                ),
              ],
            ),
          ),
          SizedBox(
            width: 16,
          ),
          TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            child: followed.contains(user.uid) ? Icon(Icons.check_circle) : Icon(Icons.add_circle_outline),
            onPressed: () {
              if (followed.contains(user.uid)) {
                followed.remove(user.uid);
                Database().unFolloUser(user.uid);
              } else {
                followed.add(user.uid);
                Database().folloUser(user);
              }
            },
          ),
        ],
      ),
    );
  }
}
