import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/models/room_user.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/widgets/widgets.dart';

class SearchRoomUsers extends StatefulWidget {
  List<RoomUser> users;
  SearchRoomUsers({this.users});

  @override
  _SearchRoomUsersState createState() => _SearchRoomUsersState();
}

class _SearchRoomUsersState extends State<SearchRoomUsers> {
  final TextEditingController textController = new TextEditingController();

  List<RoomUser> _tempListOfUsers = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tempListOfUsers = widget.users;

  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/images/bg.png",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("Search people in the room"),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(children: <Widget>[
                    Expanded(
                        child: TextField(
                            style: TextStyle(color: Colors.white),
                            controller: textController,
                            decoration: InputDecoration(
                              hintText: "Search",
                              contentPadding: EdgeInsets.all(5),
                              hintStyle:
                              TextStyle(color: Colors.grey),
                              border: new OutlineInputBorder(
                                borderRadius:
                                new BorderRadius.circular(8.0),
                                borderSide: new BorderSide(),
                              ),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.white),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _tempListOfUsers =
                                    _buildSearchList(value);
                              });
                            })),
                  ])),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    itemCount: _tempListOfUsers.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      if (textController.text.isEmpty) {
                        return userWidgetWithInfo(
                            user: _tempListOfUsers[index],
                            clickCallBack: searchUserClickCallBack);
                      } else if (_tempListOfUsers[index]
                          .firstname
                          .toLowerCase()
                          .contains(textController.text) ||
                          _tempListOfUsers[index]
                              .lastname
                              .toLowerCase()
                              .contains(textController.text)) {
                        return userWidgetWithInfo(
                            user: _tempListOfUsers[index],
                            clickCallBack: searchUserClickCallBack);
                      }
                    },
                  ),
                ),
              )
            ]),
      ),
    );
  }
  searchUserClickCallBack(RoomUser user) {
    Get.back();
    Get.to(() => ProfilePage(userid: user.uid, fromRoom: true));
  }
  List<RoomUser> _buildSearchList(String userSearchTerm) {
    List<RoomUser> _searchList = [];

    for (int i = 0; i < widget.users.length; i++) {
      String name = widget.users[i].getName();
      if (name.toLowerCase().contains(userSearchTerm.toLowerCase())) {
        _searchList.add(widget.users[i]);
      }
    }
    return _searchList;
  }

  Widget userWidgetWithInfo(
      {bool selected, RoomUser user, Function clickCallBack}) {
    return Container(
      child: InkWell(
        onTap: () {
          clickCallBack(user);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: RoundImage(
                    url: user.imageurl,
                    txt: user.username,
                    width: 70,
                    height: 70,
                  ),
                ),
                if (selected == true)
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white.withOpacity(0.9)),
                    child: Icon(
                      Icons.check,
                      size: 30,
                      color: Colors.blue,
                    ),
                    clipBehavior: Clip.hardEdge,
                  )
              ],
            ),
            Center(
              child: Container(
                padding: EdgeInsets.only(top: 10),
                width: 110,
                child: Center(
                  child: Wrap(
                    children: [
                      Text(
                        user.firstname,
                        textScaleFactor: 1,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
