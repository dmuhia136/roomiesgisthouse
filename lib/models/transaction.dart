import 'package:intl/intl.dart';

class Wtransaction{
  String date;
  String reason;
  String type;
  String amount;
  String uid;

  Wtransaction({this.date, this.reason, this.amount, this.uid,this.type});

  getDate(){
    return DateFormat('dd MMM yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(date)));
  }

  factory Wtransaction.fromJson(doc) {
    var json  = doc;
    return Wtransaction(
      reason: json['reason'] ?? "",
      type: json['type'] ?? "",
      amount: json['amount'] ?? "",
      uid: json['uid'] ?? "",
      date: json['date'] ?? null,
    );
  }

}