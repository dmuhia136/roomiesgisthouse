import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart' as User;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get/get.dart';
import 'package:gisthouse/Notifications/push_nofitications.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/InboxItem.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final List<UserModel> chatusers;
  final InboxItem item;
  final String messagetype;

  const ChatPage({Key key, this.chatusers, this.item, this.messagetype})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  List<types.Message> _messages = [];
  var _user;
  UserModel userModel = Get.find<UserController>().user;
  String chatid = "";
  InboxItem inboxItem;
  bool loading = true;

  @override
  void initState() {
    super.initState();
// Add the observer.
    WidgetsBinding.instance.addObserver(this);

    //check if there is existing chat between thithe users
    getChatByUsers();
    _user = User.User(
      id: userModel.uid,
      firstName: userModel.firstname,
      lastName: userModel.lastname,
      imageUrl: userModel.smallimage,
    );

    Database.updateProfileData(userModel.uid, {
      "onlinestatus": "online",
    });

    // _loadMessages();
  }

  getChatByUsers() async {
    if (widget.chatusers
            .indexWhere((element) => element.uid == userModel.uid) ==
        -1) {
      widget.chatusers.add(userModel);
    }
    List<String> ids = widget.chatusers.map((e) => e.uid).toList();

    QuerySnapshot snapshot = await chatsRef
        .where('users', arrayContainsAny: ids)
        .where("messagetype", isEqualTo: widget.messagetype)
        .get();
    if (snapshot.docs.length > 0) {
      snapshot.docs.forEach((element) {
        InboxItem inboxIte = InboxItem.fromJson(element);
        List<String> rr = [];
        for (int i = 0; i < inboxIte.allusers.length; i++) {
          if (ids.contains(inboxIte.allusers[i])) {
            rr.add(inboxIte.allusers[i]);
          }
        }
        if (rr.length == inboxIte.allusers.length) {
          inboxItem = inboxIte;
        }
      });
    }
    if (inboxItem == null) {
      chatid = chatsRef.doc().id;
    } else {
      chatid = inboxItem.chatid;
    }
    loading = false;
    setState(() {});
  }

  @override
  void dispose() {
    // Remove the observer
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        // widget is resumed
        Database.updateProfileData(userModel.uid, {
          "onlinestatus": "online",
        });
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        Database.updateProfileData(userModel.uid, {
          "onlinestatus": "away",
        });
        break;
      case AppLifecycleState.paused:
        // widget is paused
        Database.updateProfileData(userModel.uid, {
          "onlinestatus": "offline",
        });
        break;
      case AppLifecycleState.detached:
        Database.updateProfileData(userModel.uid, {
          "onlinestatus": "offline",
        });
        // widget is detached
        break;
    }
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      // await OpenFile.open(message.uri);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().microsecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    widget.chatusers.add(userModel);

    Database.sendMessage(
        chatusers: widget.chatusers,
        chatMessage: textMessage,
        chatid: chatid,
        inboxitem: widget.item,
        messagetype: widget.messagetype);

    //send notification
    if (widget.chatusers
            .indexWhere((element) => element.uid == userModel.uid) !=
        -1) {
      widget.chatusers.removeAt(widget.chatusers
          .indexWhere((element) => element.uid == userModel.uid));
    }
    PushNotificationsManager().callOnFcmApiSendPushNotifications(
        widget.chatusers.map((e) => e.firebasetoken).toList(),
        "${textMessage.author.firstName + " " + textMessage.author.lastName}",
        textMessage.text,
        "ChatPage",
        chatid);
  }

  Widget _buildChatTitle() {
    if (widget.chatusers.indexWhere(
            (element) => element.uid == Get.find<UserController>().user.uid) !=
        -1)
      widget.chatusers.removeAt(widget.chatusers.indexWhere(
          (element) => element.uid == Get.find<UserController>().user.uid));
    return widget.chatusers.length == 1
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 10),
                child: Container(
                  margin: EdgeInsets.only(right: 5),
                  child: RoundImage(
                    url: widget.chatusers[0].smallimage,
                    txt: widget.chatusers[0].username,
                    height: 42,
                    txtsize: 14,
                    borderRadius: 20,
                    width: 42,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                child: Container(
                  margin: EdgeInsets.only(right: 5),
                  child: Text(
                    widget.chatusers[0].username,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              )
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: widget.chatusers
                        .map((e) => InkWell(
                              onTap: () => Sheet.open(
                                context,
                                OpenContainer(
                                  openElevation: 1,
                                  closedElevation: 1,
                                  closedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  tappable: false,
                                  openBuilder: (context, action) {
                                    return ProfilePage(
                                      profile: e,
                                      isMe: e.uid ==
                                          Get.find<UserController>().user.uid,
                                      fromRoom: false,
                                    );
                                  },
                                  closedBuilder: (context, action) {
                                    return ProfilePage(
                                      profile: Get.find<UserController>().user,
                                      fromRoom: false,
                                      isMe: e.uid ==
                                          Get.find<UserController>().user.uid,
                                    );
                                  },
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: RoundImage(
                                    url: e.smallimage,
                                    txt: e.username,
                                    height: 38,
                                    txtsize: 14,
                                    borderRadius: 20,
                                    width: 38,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: widget.chatusers
                      .map((e) => Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Container(
                              margin: EdgeInsets.only(right: 5),
                              child: Text(
                                e.username,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {

        //trigger leaving and use own data
        Navigator.pop(context, false);
        Database.updateProfileData(userModel.uid, {
          "onlinestatus": false,
        });
        //we need to return a future
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Style.LightBrown,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: _buildChatTitle(),
        ),
        body: SafeArea(
          bottom: false,
          child: loading == true
              ? Container(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                          stream: Database.getMessages(chatid, inboxItem),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return loadingWidget(context);
                            }
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            List<types.Message> _messages = snapshot.data;
                            return Chat(
                              showUserNames: true,
                              // showUserAvatars: true,
                              messages: _messages,
                              showtextabovesendbutton: widget.item != null &&
                                  widget.item.messagetype == "request" &&
                                  widget.item.ownerid != userModel.uid,
                              custwidget: Container(
                                  margin: EdgeInsets.only(
                                      bottom: 20, left: 30, right: 30),
                                  child: Column(
                                    children: [
                                      Divider(),
                                      Text(
                                        "If you reply, this chat will move to your inbox and you'll be notified of updates",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )),
                              // onAttachmentPressed: _handleAtachmentPressed,
                              onMessageTap: _handleMessageTap,
                              onPreviewDataFetched: _handlePreviewDataFetched,
                              customDateHeaderText: (dateTime) {
                                return DateFormatter
                                    .getVerboseDateTimeRepresentation(
                                        context,
                                        DateTime.fromMillisecondsSinceEpoch(
                                            dateTime.millisecondsSinceEpoch));
                              },
                              onSendPressed: _handleSendPressed,
                              sendButtonVisibilityMode:
                                  SendButtonVisibilityMode.editing,
                              user: _user,
                            );
                          }),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
