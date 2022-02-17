import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/widgets/round_image.dart';

List<UserModel> selectedusers = [];

class AddCoHostScreen extends StatefulWidget {
  final Function clickCallback;
  final StateSetter mystate;

  AddCoHostScreen({this.clickCallback, this.mystate});

  @override
  _AddCoHostScreenState createState() => _AddCoHostScreenState();
}

class _AddCoHostScreenState extends State<AddCoHostScreen> {
  bool loading = false;
  var searchcontroller = TextEditingController();
  List<UserModel> allusers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.AccentBlue,
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 40,
          ),
          InkWell(
            child: Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.arrow_back_ios, color: Colors.white)),
            onTap: () {
              Get.back();
            },
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Style.AccentBrown),
                    child: TextField(
                        onChanged: (tx) {
                          setState(() {});
                        },
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                        controller: searchcontroller,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(8.0, 13.0, 8.0, 8.0),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          hintText: "Search people to add as co-host",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        )),
                  ),
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 30),
                        child: loading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : FutureBuilder(
                                future: Database.getUsersToFollow(-1),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text("Technical Error");
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting)
                                    Center(child: CircularProgressIndicator());
                                  if (snapshot.data == null) {
                                    return Center(child: Text("No Users Yet "));
                                  }
                                  List<UserModel> users = snapshot.data;
                                  if (users.length == 0) {
                                    return Center(child: Text("No Users Yet "));
                                  }
                                  allusers = snapshot.data;
                                  return GridView.builder(
                                    // padding: EdgeInsets.fromLTRB(30, 30, 30, 72),
                                    physics: BouncingScrollPhysics(),
                                    // itemCount: speakers.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.67,
                                    ),
                                    itemCount:
                                        _buildSearchList(searchcontroller.text)
                                            .length,
                                    // gridDelegate:
                                    //     SliverGridDelegateWithFixedCrossAxisCount(
                                    //         crossAxisCount: 3,
                                    //         crossAxisSpacing: 16,
                                    //         mainAxisSpacing: 16,
                                    //         childAspectRatio: 0.67,
                                    //     ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return singleUser(_buildSearchList(
                                          searchcontroller.text)[index]);
                                      // return Container();
                                    },
                                  );
                                })),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<UserModel> _buildSearchList(String userSearchTerm) {
    List<UserModel> _searchList = [];

    if (userSearchTerm.isEmpty) {
      return allusers;
    }
    for (int i = 0; i < allusers.length; i++) {
      String name = allusers[i].getName();
      if (name.toLowerCase().contains(userSearchTerm.toLowerCase())) {
        _searchList.add(allusers[i]);
      }
    }
    return _searchList;
  }

  singleUser(UserModel user) {
    return Container(
      height: 60,
      child: InkWell(
        onTap: () {
          if (!selectedusers.contains(user)) widget.clickCallback(user);
          setState(() {});
          Get.back();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Center(
                  child: RoundImage(
                    url: user.smallimage,
                    txtsize: 14,
                    txt: user.username,
                    width: 60,
                    height: 60,
                  ),
                ),
                selectedusers.contains(user) == true
                    ? Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.white,
                        ))
                    : Container()
              ],
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    textScaleFactor: 1,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
