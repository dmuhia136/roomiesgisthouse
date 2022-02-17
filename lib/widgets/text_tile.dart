import 'package:flutter/material.dart';

class TextTile extends StatelessWidget {
  final String text;
  final GestureTapCallback onTap;

  TextTile(this.text, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
