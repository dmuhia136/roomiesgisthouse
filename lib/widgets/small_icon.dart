import 'package:flutter/material.dart';

class SmallIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  SmallIcon(this.icon, {this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 12,
      color: color ?? Theme.of(context).dividerColor,
    );
  }
}
