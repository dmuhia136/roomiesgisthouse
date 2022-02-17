import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/util/utils.dart';

class Club {
  String title;
  String id;
  String description;
  String ownerid;
  String imageurl;
  double gcbalance;
  bool allowfollowers;
  bool allowmemberstohostrooms;
  bool membercanstartrooms;
  bool allowmembersviewwallet;
  bool membersprivate;
  Timestamp publisheddate;
  List<String> members;
  List<String> followers;
  List<String> invited;
  List<Interest> topics;

  Club(
      {this.title,
      this.id,
      this.imageurl,
      this.description,
      this.invited,
      this.gcbalance,
      this.ownerid,
      this.allowfollowers,
      this.allowmembersviewwallet,
      this.allowmemberstohostrooms,
      this.membercanstartrooms,
      this.membersprivate,
      this.publisheddate,
      this.followers,
      this.members,
      this.topics});

  gchtml() {
    return  gccurrency +" "+ this.gcbalance.toStringAsFixed(0);
  }
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "ownerid": ownerid,
      "iconurl": imageurl,
      "invited": invited,
      "allowfollowers": allowfollowers,
      "membercanstartrooms": membercanstartrooms,
      "allowmembersviewwallet": allowmembersviewwallet,
      "allowmemberstohostrooms": allowmemberstohostrooms,
      "membersprivate": membersprivate,
      "publisheddate": publisheddate,
      "topics": topics,
      "members": members,
      "followers": followers,
    };
  }

  factory Club.fromJson(club) {
    var json = club;
    Functions.debug(json);
    List<Interest> topics = json["topics"] == null
        ? []
        : List<Interest>.from(json["topics"].map((item) {
            return new Interest(
              id: item["id"],
              title: item["title"],
            );
          }));
    // List<Interest> topics = List<Interest>.from(json["topics"].map((item) => item["title"]));
    List<String> members =
        List<String>.from(json["members"].map((item) => item));
    List<String> followers = json["followers"] == null ? [] :
        List<String>.from(json["followers"].map((item) => item));

    List<String> invited = json["invited"] != null
        ? List<String>.from(json["invited"].map((item) => item))
        : [];
    return Club(
      id: json['clubid'],
      title: json['title'],
      description: json['description'],
      imageurl: json['iconurl'] ?? "",
      invited: invited,
      ownerid: json['ownerid'],
      allowfollowers: json['allowfollowers'] ?? false,
      allowmemberstohostrooms: json['allowmemberstohostrooms'] ?? false,
      allowmembersviewwallet: json['allowmembersviewwallet'] ?? false,
      membercanstartrooms: json['membercanstartrooms'] ?? false,
      membersprivate: json['membersprivate'] ?? false,
      publisheddate: json['publisheddate'],
      gcbalance: json['gcbalance'] !=null ? json['gcbalance'].toDouble() :  0.0,
      topics: topics,
      members: members,
      followers: followers,
    );
  }
}
