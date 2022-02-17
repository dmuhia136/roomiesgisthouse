import 'package:flutter/material.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/buy_a_ticket_sheet.dart';

class PaidRoomScreen extends StatefulWidget {
  Room room;
  PaidRoomScreen({this.room});

  @override
  _PaidRoomScreenState createState() => _PaidRoomScreenState();
}

class _PaidRoomScreenState extends State<PaidRoomScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 0)).then((_) {
      Sheet.openDrag(context, BuyATicketSheet(widget.room, false));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/bg.png",
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
