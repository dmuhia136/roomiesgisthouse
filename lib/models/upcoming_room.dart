import 'package:gisthouse/models/models.dart';

/*
  type : Model
 */
class UpcomingRoom {
  final String title;
  final List<String> clubListIds;
  final List<String> clubListNames;
  final String roomid;
  final String description;
  final int eventdate;
  final String timedisplay;
  final String publisheddate;
  final List<UserModel> users;
  final List<String> tobenotifiedusers;
  final String sponsors;
  final bool openToMembersOnly;
  final int eventtime;
  final String status;
  final String userid;
  final double amount;
  final bool private;

  UpcomingRoom({
    this.title,
    this.clubListIds,
    this.clubListNames,
    this.openToMembersOnly,
    this.tobenotifiedusers,
    this.description,
    this.publisheddate,
    this.users,
    this.roomid,
    this.eventdate,
    this.eventtime,
    this.timedisplay,
    this.status,
    this.userid,
    this.sponsors,
    this.amount,
    this.private
  });

  factory UpcomingRoom.fromJson( json) {
    return UpcomingRoom(
      eventdate: json['eventdatetimestamp'] ?? 0,
      title: json['title'] ?? "",
      clubListIds:
          json['clubListIds'] == null ? []:
             List<String>.from(
        json["clubListIds"].map((item) => item)),
      clubListNames:
          json['clubListNames'] == null ? [] :
         List<String>.from(
    json["clubListNames"].map((item) => item)),
      tobenotifiedusers: json["tobenotifiedusers"] == null
          ? []
          : List<String>.from(
    json["tobenotifiedusers"].map((item) => item)),
      roomid: json["_id"],
      users: json['users'] != null
          ? json['users'].map<UserModel>((user) {
              return UserModel.fromJson(user);
            }).toList()
          : [],
      sponsors: json['sponsors'] ?? "",
      description: json['description'] ?? "",
      publisheddate: json['published_date'] ?? null,
      openToMembersOnly: json['openToMembersOnly'] ?? false,
      eventtime: json['eventtimetimestamp'] ?? 0,
      status: json['status'] ?? "pending",
      userid: json['userid'] ?? "",
    amount: json['amount'] !=null && json['amount'] !="" ? json['amount'].toDouble() : 0,
    private: json['private'] ?? false,
    );
  }
}
