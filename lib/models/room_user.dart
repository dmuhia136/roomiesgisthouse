class RoomUser {
  String firstname;

  String lastname;
  String username;
  bool callmute;
  String uid;
  String imageurl;
  String profileImage;
  int callerid;
  String usertype;
  int valume = 1;
  int membership = 0;
  int membersince;

  RoomUser(
      {this.firstname,
      this.lastname,
      this.username,
      this.callmute,
      this.uid,
      this.imageurl,
      this.profileImage,
      this.callerid,
      this.usertype,
      this.valume,
      this.membership,
      this.membersince});

  Map<String, dynamic> toMap(
      {usertype = "host", callmute = true, callerid = 0}) {
    return {
      "membersince": membersince,
      "membership": 0,
      "valume": valume,
      "lastname": lastname,
      "firstname": firstname,
      "uid": uid,
      "usertype": usertype,
      "callerid": callerid,
      "callmute": callmute,
      "username": this.username,
      "imageurl": imageurl,
      "profileImage": profileImage,
    };
  }
  getName() {
    return this.firstname + " " + this.lastname;
  }
  factory RoomUser.fromJson(json) {

    return  json["firstname"] != null ? RoomUser(
      lastname: json['lastname'] == null ? "" : json['lastname'] ,
      membership: json['membership'],
      membersince: json['membersince'],
      firstname: json['firstname'],
      callerid: json['callerid'] ?? 0,
      valume: json['valume'] ?? 0,
      callmute: json['callmute'] ?? false,
      username: json['username'],
      usertype: json['usertype'],
      uid: json['uid'],
      imageurl: json['imageurl'] ?? "",
      profileImage: json['profileImage'] ?? "",
    ): RoomUser();
  }
}
