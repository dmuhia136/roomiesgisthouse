import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/InboxItem.dart';
import 'package:gisthouse/pages/chats/chat_screen.dart';
import 'package:gisthouse/pages/chats/users_to_chat_with.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/round_image.dart';
import 'package:gisthouse/widgets/widgets.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenSate createState() => _ChatsScreenSate();
}

extension CapExtension on String {
  String get inCaps =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';

  String get allInCaps => this.toUpperCase();

  String get capitalizeFirstofEach => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");
}

class _ChatsScreenSate extends State<ChatsScreen>
    with SingleTickerProviderStateMixin {
  int tabindex = 0;
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.LightBrown,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {},
            child: IconButton(
              icon: Icon(
                CupertinoIcons.pencil_circle,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () => Get.to(() => UsersToChatWith()),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Style.LightBrown,
        title: Text("Side Gist".toUpperCase(),
            style: TextStyle(color: Colors.black)),
        // automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // give the tab bar a height [can change height to preferred height]
          Container(
            height: 35,
            child: TabBar(
              indicatorColor: Style.indigo,
              indicatorWeight: 3,
              controller: _tabController,
              labelColor: Style.indigo,
              unselectedLabelColor: Colors.black,
              onTap: (index) {},
              tabs: [
                // first tab [you can add an icon using the icon property]
                Tab(
                  child: Text(
                    "Chats".toUpperCase(),
                    style: TextStyle(
                        fontFamily: "InterSemiBold", fontSize: 15, color: Colors.black),
                  ),
                ),
                // first tab [you can add an icon using the icon property]
                Tab(
                  child: Text(
                    "initiate chats".toUpperCase(),
                    style: TextStyle(
                        fontFamily: "InterSemiBold", fontSize: 15, color: Colors.black),
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
                  StreamBuilder(
                      stream: Database.getInbox(
                          userids: [Get.find<UserController>().user.uid]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return loadingWidget(context);
                        }
                        if (!snapshot.hasData) {
                          return noDataWidget("No Messages yet");
                        }
                        List<InboxItem> inboxes = snapshot.data;
                        if (inboxes.length == 0) {
                          return noDataWidget("No Messages yet",
                              colors: Colors.black);
                        }
                        return ListView(
                          children:
                              inboxes.map((e) => _messageItem(e)).toList(),
                        );
                      }),
                  StreamBuilder(
                      stream: Database.getInbox(
                          messagetype: "request",
                          userids: [Get.find<UserController>().user.uid]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return loadingWidget(context);
                        }
                        if (!snapshot.hasData) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 80),
                            child: noDataWidget(
                                "You are all good!  you don't have any  new message requests"),
                          );
                        }
                        List<InboxItem> inboxes = snapshot.data;
                        return ListView(
                          children:
                              inboxes.map((e) => _messageItem(e)).toList(),
                        );
                      }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _messageItem(InboxItem item) {
    String names = "";
    item.users.forEach((element) {
      if (Get.find<UserController>().user.uid != element.uid) {
        names += element.username.capitalizeFirstofEach + ", ";
      }
    });


    return ListTile(
      onTap: () => Get.to(() => ChatPage(
            chatusers: item.users,
            item: item,
            messagetype: item.messagetype,
          )),
      leading: RoundImage(
        txt: item.users[item.users.indexWhere((element) => element.uid != Get.find<UserController>().user.uid)].username,
        url: item.users[item.users.indexWhere((element) => element.uid != Get.find<UserController>().user.uid)].smallimage,
        width: 55,
        height: 55,
        borderRadius: 20,
        txtsize: 14,
      ),
      title: Text(
        names,
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontFamily: "InterSemiBold"),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        // "${item.lastmessage}",
        (item.lastsender.uid == Get.find<UserController>().user.uid
                ? "You: "
                : item.lastsender.firstname) +
            ": ${item.lastmessage}",
        style: TextStyle(
            color: Colors.black, fontSize: 14, fontFamily: "InterLight"),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        DateFormatter.getVerboseDateTimeRepresentation(
            context, DateTime.fromMillisecondsSinceEpoch(item.timestamp)),
        style: TextStyle(
            color: Colors.black, fontSize: 14, fontFamily: "InterLight"),
      ),
    );
  }
}
