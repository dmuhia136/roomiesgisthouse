import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/chats/chat_screen.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/noitem_widget.dart';
import 'package:gisthouse/widgets/widgets.dart';

class UsersToChatWith extends StatefulWidget {
  const UsersToChatWith({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UsersToChatWithState();
  }
}

class _UsersToChatWithState extends State<UsersToChatWith>
    with WidgetsBindingObserver {
  List<UserModel> filteredallusers = [];
  List<UserModel> allusers = [];
  List<UserModel> selectedusers = [];

  String searchtxt = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ('state = $state');
  }

  @override
  void dispose() {
    super.dispose();
  }

  itemClicked(UserModel userModel) {
    selectedusers.indexWhere((element) => element.uid == userModel.uid) == -1
        ? selectedusers.add(userModel)
        : selectedusers.removeAt(selectedusers
            .indexWhere((element) => element.uid == userModel.uid));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Style.LightBrown,
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
            backgroundColor: Colors.transparent,
            title: Text(
              "NEW MESSAGE",
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: SafeArea(
            child: CupertinoPageScaffold(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
//search bar
                          child: Container(
                            margin: EdgeInsets.only(right: 10, top: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blueGrey),
                                color: Style.LightBrown),
                            child: TextField(
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                                onChanged: (value) async {
                                  searchtxt = value;
                                  filteredallusers.clear();
                                  for (int i = 0; i < allusers.length; i++) {
                                    if (allusers[i]
                                            .firstname
                                            .toLowerCase()
                                            .contains(value.toLowerCase()) ==
                                        true) {
                                      filteredallusers.add(allusers[i]);
                                      setState(() {});
                                    }
                                  }
                                },
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(8.0, 13.0, 8.0, 8.0),
                                  prefixIcon: Icon(Icons.search,
                                      color: Style.HintColor),
                                  hintText: "Search Followers",
                                  hintStyle: TextStyle(color: Style.HintColor),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    selectedusers.length == 0
                        ? Container()
                        : Container(
                            height: 100,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: selectedusers
                                  .map((e) => InkWell(
                                        onTap: () => itemClicked(e),
                                        child: Container(
                                          margin: EdgeInsets.only(right: 10),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        right: 5),
                                                    child: RoundImage(
                                                      url: e.smallimage,
                                                      txt: e.username,
                                                      height: 65,
                                                      borderRadius: 25,
                                                      width: 65,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    e.username,
                                                    style: TextStyle(
                                                        color: Colors.black, decorationColor: Style.Blue),
                                                  )
                                                ],
                                              ),
                                              Positioned(
                                                right: -10,
                                                top: -10,
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.cancel,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      itemClicked(e),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                    if (selectedusers.length > 0)
                      Column(
                        children: [
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    Expanded(
                        child: FutureBuilder(
                            future: Database.getmyFollowers(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (snapshot.data == null) {
                                return noDataWidget(
                                    "No Friends who have followed you yet");
                              }
                              if (snapshot.hasData) {
                                List<UserModel> users = snapshot.data;
                                allusers = users;
                                return ListView.separated(
                                  separatorBuilder: (c, i) {
                                    return Container(
                                      height: 15,
                                    );
                                  },
                                  itemCount: searchtxt.isEmpty
                                      ? users.length
                                      : filteredallusers.length,
                                  itemBuilder: (context, index) {
                                    UserModel user = searchtxt.isEmpty
                                        ? users[index]
                                        : filteredallusers[index];
                                    return InkWell(
                                      onTap: () => itemClicked(user),
                                      child: singleItem(user,
                                          selectedusers: selectedusers,
                                          callBackFUnction: itemClicked,
                                          selectediconData:
                                              Icons.add_circle_outline,
                                          unselectediconData:
                                              Icons.check_circle),
                                    );
                                  },
                                );
                              } else {
                                return noDataWidget(
                                    "No friends to follow for now");
                              }
                            })),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: selectedusers.length == 0
              ? null
              : FloatingActionButton(
                  child: Icon(Icons.arrow_forward_rounded),
                  onPressed: () {
                    Get.back();
                    Get.to(() => ChatPage(
                          chatusers: selectedusers,
                          messagetype: "chats",
                        ));
                  },
                ),
        ),
      ],
    );
  }
}
