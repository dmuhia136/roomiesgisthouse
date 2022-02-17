/*
  type : Model
 */
class ActivityItem{
  String imageurl;
  String id;
  String from;
  String name;
  String actionkey;
  bool actioned;
  String type;
  String message;
  String time;

  ActivityItem({this.from,this.imageurl, this.name, this.message, this.time, this.type,this.actionkey,this.actioned,this.id});
  factory ActivityItem.fromJson(json, String id) {
    return ActivityItem(
      imageurl: json['imageurl'],
      id: id,
      actioned: json['actioned'] ??  false,
      name: json['name'],
      type: json['type'],
      actionkey: json['actionkey'],
      message: json['message'],
      from: json['from'] ?? null,
      time: json['time'],
    );
  }
}