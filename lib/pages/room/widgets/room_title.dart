import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/room/widgets/text_with_show_more.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';

Future<void> addTopicDialog(BuildContext context, Room room) async {
  var _textFieldController = TextEditingController();
  _textFieldController.text = room.title;

  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Style.AccentBrown,
          content: TextField(
            style: TextStyle(color: Colors.white),
            onChanged: (value) {},
            controller: _textFieldController,
            decoration: InputDecoration(
                hintText: "write topic here",
                hintStyle: TextStyle(color: Style.HintColor, fontSize: 12)),
          ),
          actions: <Widget>[
            TextButton(
              child: Container(
                  color: Style.ButtonColor,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'UPDATE ROOM TITLE',
                    style: TextStyle(color: Colors.black),
                  )),
              onPressed: () {
                Get.back();
                Database.updateRoomData(
                    room.roomid, {"title": _textFieldController.text});
              },
            ),
          ],
        );
      });
}

class RoomTitle extends StatefulWidget {
  @override
  _RoomTitleState createState() => _RoomTitleState();

  Room room;
  BuildContext context;
  bool homepage;

  RoomTitle(this.room, this.context, {this.homepage = false});
}

class _RoomTitleState extends State<RoomTitle> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 5,
        ),
        if (widget.room != null && widget.room.title.isNotEmpty)
          InkWell(
              onTap: () {
                if (widget.room.ownerid ==
                        Get.find<UserController>().user.uid &&
                    widget.homepage == false)
                  addTopicDialog(context, widget.room);
              },
              child: widget.homepage == true
                  ? Text(
                      widget.room.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black),
                      maxLines: 2,
                    )
                  : TextWithShowMore(widget.room.title, Colors.black)),
        widget.room != null && widget.room.clubListNames.length > 0
            ?  CategoryRow(category: widget.room.clubListNames,ids: widget.room.clubListIds,color: Style.indigo,)
            :
            Container(),
      ],
    );
  }
}
