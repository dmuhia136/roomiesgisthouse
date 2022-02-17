
import 'package:intl/intl.dart';
/*
  type : Model
 */
class Room {
  final String title;
  final List<String> speakers;
  final List<String> allmoderators;
  final List<String> activemoderators;
  final List<String> raisedhands;
  final String pinnedurl;
  final String sponsors;
  final List<String> invitedusers;
  final List<String> invitedasmoderator;
  final List<String> removedusers;
  final int speakerCount;
  final int handsraisedby;
  final int createdtime;
  final int activeTime;
  final String readabledate;
  final String roomtype;
  String roomid;
  final String sponsor;
  final double amount;
  final String currency;
  final String token;
  final String ownerid;
  final String eventid;
  final List<String> clubListIds;
  final List<String> clubListNames;

  Room({
     this.currency,
     this.speakers,
     this.allmoderators,
     this.readabledate,
     this.invitedasmoderator,
     this.invitedusers,
     this.amount,
     this.removedusers,
     this.title,
     this.activemoderators,
     this.pinnedurl,
     this.roomtype,
     this.token,
     this.handsraisedby,
     this.roomid,
     this.sponsor,
     this.createdtime,
     this.speakerCount,
     this.eventid,
     this.ownerid,
    // this.users,
     this.raisedhands,
     this.sponsors,
     this.clubListIds,
     this.clubListNames,
     this.activeTime,
  });

  getHandsRaisedByType(){
    if(handsraisedby == 1)return "Open to EveryOne";
    if(handsraisedby == 2)return "Followed by the Speakers";
    if(handsraisedby == 3)return "Off";
  }

  Map<String, dynamic> toMap(){
    return {
      'title': title,
      "ownerid": ownerid,
      "pinnedurl": pinnedurl,
      // 'users': users.map((e) => e.toMap()).toList(),
      "sponsors": '',//sponsors.map((e) => e.toMap()).toList(),
      "activemoderators": activemoderators.map((e) => e).toList(),
      "allmoderators": allmoderators.map((e) => e).toList(),
      "speakers": speakers.map((e) => e).toList(),
      "raisedhands": raisedhands.map((e) => e).toList(),
      "invitedusers": invitedusers.map((e) => e).toList(),
      "invitedasmoderator": invitedasmoderator.map((e) => e).toList(),
      'clubListIds': clubListIds.map((e) => e).toList(),
      'clubListNames': clubListNames.map((e) => e).toList(),
      'readabledate': readabledate,
      'amount': amount,
      'currency': currency,
      'roomtype': roomtype,
      'roomid' : roomid,
      'eventid' : eventid,
      'token': token,
      'speakerCount': speakerCount,
      "created_time": createdtime,
      "activeTime": activeTime,
    };
  }

  factory Room.fromJson(doc) {
    DateFormat format = DateFormat("yyyy-MM-dd");

    var json  = doc;
    return Room(
      handsraisedby: json['handsraisedby'] ?? 0,
      title: json['title'] ?? "",
      pinnedurl: json['pinnedurl'] ?? "",
      sponsor: json['sponsor'],
      currency: json['currency'],
      amount: json['amount'] !=null ? double.parse(json['amount'].toString()) : 0.0,
      ownerid: json['ownerid'],
      readabledate: format.format(DateTime.fromMicrosecondsSinceEpoch(json['created_time'])),
      eventid: json['eventid'] ?? "",
      roomtype: json['roomtype'],
      createdtime: json['created_time'],
        activeTime: json['activeTime'],
      token: json['token'],
      roomid: json['id'],
      speakers: json['speakers'] == null ? [] : List<String>.from(json["speakers"].map((item) => item)),
      allmoderators: json['allmoderators'] == null ? [] : List<String>.from(json["allmoderators"].map((item) => item)),
      activemoderators: json['activemoderators'] == null ? [] : List<String>.from(json["activemoderators"].map((item) => item)),
      raisedhands: json['raisedhands'] == null ? [] : List<String>.from(json["raisedhands"].map((item) => item)),
      removedusers: json['removedusers'] == null ? [] : List<String>.from(json["removedusers"].map((item) => item)),
      invitedasmoderator: json['invitedasmoderator'] == null ? [] : List<String>.from(json["invitedasmoderator"].map((item) => item)),
      invitedusers: json['invitedusers'] == null ? [] : List<String>.from(json["invitedusers"].map((item) => item)),
      sponsors: json['sponsors'] ?? "",// != null ? json['sponsors'].map<Sponsors>((sponsor){
      //   return Sponsors.fromJson(sponsor);
      // }).toList() : [],
      speakerCount: json['speakerCount'],
    clubListIds: json['clubListIds'] == null ? []:List<String>.from(json["clubListIds"].map((item) => item)),
    clubListNames: json['clubListNames'] == null ? [] :
    List<String>.from(
    json["clubListNames"].map((item) => item)),
    );

  }
}
