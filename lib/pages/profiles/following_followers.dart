import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/pages/profiles/widgets/user_profile_image.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/follow_button.dart';
import 'package:gisthouse/widgets/loading.dart';
import 'package:gisthouse/widgets/noitem_widget.dart';

class FollowingFollowers extends StatefulWidget {
  final String type;
  final String userid;

  const FollowingFollowers({Key key, this.type, this.userid}) : super(key: key);

  @override
  _FollowingFollowersState createState() => _FollowingFollowersState();
}

class _FollowingFollowersState extends State<FollowingFollowers> {
  ScrollController _scrollController;
  int loadMoreMsgs = 14; // at first it will load only 25
  bool moreusers = true, loading = false, loadingmore = false;
  List<UserModel> _allUsers = [];
  UserModel userModel = Get.find<UserController>().user;

  QuerySnapshot querySnapshot;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.atEdge) {
          if (_scrollController.position.pixels == 20)
            {}
          else {
            getUsers(true);
          }
        }
      });
    getUsers(false);
  }

  getUsers(bool more) async {
    if (more == false) {
      loading = true;
      setState(() {});
      List usersFromApi = [];
      if(widget.type == "followers") {

        usersFromApi = await UserApi().getUserFollowers(widget.userid);

      } else if(widget.type == "following") {

        usersFromApi = await UserApi().getUserFollowing(widget.userid);

      }

      _allUsers.clear();
      last = usersFromApi.last;

      usersFromApi.forEach((element) {
        _allUsers.add(UserModel.fromJson(element));
      });

        loading = false;
        setState(() {});

    } else {
      if (moreusers == false) {
        return;
      }

      loadingmore = true;
      setState(() {});

      List usersFromApi = [];

      if(widget.type == "followers") {

        usersFromApi = await UserApi().getUserFollowersAfter(widget.userid, last['_id']);

      } else if(widget.type == "following") {

        usersFromApi = await UserApi().getUserFollowingAfter(widget.userid, last['_id']);

      }


        if (usersFromApi.length < loadMoreMsgs) {
          moreusers = false;
        } else {
          last = usersFromApi.last;
        }

      usersFromApi.forEach((element) {
          _allUsers.add(UserModel.fromJson(element));
        });
        loadingmore = false;
        setState(() {});
    }
  }

  var last;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.LightBrown,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        elevation: 0,
        backgroundColor: Style.LightBrown,
        title: Text(widget.type == "followers" ? "Followers" : "Following", style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
        ),
        child: Column(
          children: [
            if (loading) Expanded(child: loadingWidget(context)),
            if (_allUsers.length == 0 && loading ==false)
              Expanded(child: noDataWidget("No Followers yet", colors: Colors.white)),
            if (_allUsers.length > 0)
              Expanded(
                child: Container(
                  child: ListView.separated(
                      itemCount: _allUsers.length,
                      controller: _scrollController,
                      shrinkWrap: true,
                      separatorBuilder: (lc, i) {
                        return SizedBox(
                          height: 15,
                        );
                      },
                      physics: ScrollPhysics(),
                      itemBuilder: (lc, index) {
                        return singleItem(_allUsers[index]);
                      }),
                ),
              ),
            if(loadingmore) CircularProgressIndicator(
              backgroundColor: Colors.transparent,
            )
          ],
        ),
      ),
    );
  }

  Widget singleItem(UserModel user) {
    return InkWell(
      onTap: () {
        Get.to(
          () => ProfilePage(
            profile: user,
            fromRoom: false,
          ),
        );
      },
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
                  Text(
                    user.getName(),
                    textScaleFactor: 1,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
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
            if (userModel.uid != user.uid)
              FollowButton(
                isFollowing: userModel.following.contains(user.uid),
                onTap: () {
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
}
