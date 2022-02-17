import 'package:flutter/material.dart';

class TextWithShowMore extends StatefulWidget{
  String text;
  Color textColor;

  @override
  _TextWithShowMoreState createState() => _TextWithShowMoreState();

  TextWithShowMore(this.text, this.textColor);
}

class _TextWithShowMoreState extends State<TextWithShowMore> {

  String firstHalf;
  String secondHalf;
  bool flag = true;

  @override
  Widget build(BuildContext context) {
    if (widget.text.length > 60) {
      firstHalf = widget.text.substring(0, 60);
      secondHalf = widget.text.substring(60, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
    return secondHalf.isEmpty
        ? new Text(
      firstHalf,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: widget.textColor),
    )
        : new Column(
      children: <Widget>[
        new Text(
          flag ? (firstHalf + "...") : (firstHalf + secondHalf),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: widget.textColor),
        ),
        new InkWell(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Text(
                flag ? "show more" : "show less",
                style: new TextStyle(color: Colors.lightBlue),
              ),
            ],
          ),
          onTap: () {
            setState(() {
              flag = !flag;
            });
          },
        ),
      ],
    );
  }

}