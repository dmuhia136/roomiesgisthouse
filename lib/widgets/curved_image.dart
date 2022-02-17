import 'package:flutter/material.dart';

class CurvedImage extends StatelessWidget {
  final String image;
  final double height;
  final double width;
  final double radius;
  final GestureTapCallback onTap;

  CurvedImage(
    this.image, {
    this.height,
    this.width,
    this.radius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          image,
          height: height,
          width: width ?? height,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
