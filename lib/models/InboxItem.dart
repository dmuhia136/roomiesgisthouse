import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';

class InboxItem {
  String lastmessage;
  String messagetype;
  UserModel lastsender;
  String ownerid;
  String chatid;
  int timestamp;
  List<UserModel> users;
  List<String> allusers;

  InboxItem({this.ownerid,this.allusers,this.messagetype,this.lastmessage,this.lastsender, this.timestamp, this.users, this.chatid});

  factory InboxItem.fromJson(DocumentSnapshot json) {
    return InboxItem(
      chatid: json.id,
      ownerid: json["ownerid"],
      lastmessage: json["lastmessage"],
      messagetype: json["messagetype"],
      allusers: List<String>.from(json["users"].map((item) => item)),
      lastsender: UserModel(
        lastname: json["last_sender"]["lastName"],
        firstname: json["last_sender"]["firstName"],
        uid: json["last_sender"]["id"],
      ),
      timestamp: json["creationTimestamp"],
      users: json['members'].map<UserModel>((user) {
        return UserModel.fromJson(user);
      }).toList(), //_chatUserFromFirebaase(List<ChatUser>.from(e.data()["users"].map((item) => item)))
    );
  }

  static getChatUsers(List<String> ids) {
    List<UserModel> chatuser = [];
    ids.forEach((element) async {
      chatuser.add(await Database.getUserProfile(element));
    });
    return chatuser;
  }
}
