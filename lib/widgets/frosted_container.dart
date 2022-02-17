import 'package:flutter/material.dart';
import 'package:blur/blur.dart';

class FrostedContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  FrostedContainer({this.child, this.borderRadius, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor.withOpacity(0.2),
      padding: padding ?? EdgeInsets.all(20),
      child: child,
    ).frosted(
      borderRadius:
          borderRadius ?? BorderRadius.vertical(top: Radius.circular(24)),
      frostColor: Theme.of(context).cardColor,
      blur: 20,
    );
  }
}
