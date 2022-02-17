import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color txtcolor;
  final Color disabledColor;
  final EdgeInsets padding;
  final Function onPressed;
  final Widget child;
  final bool isCircle;
  final double minimumWidth;
  final double minimumHeight;
  final double radius;
  final String fontfamily;

  const CustomButton({
    Key key,
    this.text = '',
    this.fontSize = 20,
    this.radius = 30,
    this.fontfamily = "InterBold",
    this.color,
    this.txtcolor = Colors.white,
    this.disabledColor,
    this.padding = const EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 25,
    ),
    this.onPressed,
    this.isCircle = false,
    this.minimumWidth = 0,
    this.minimumHeight = 0,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // icon: text == "Send" ? Icon(Icons.wifi_protected_setup_sharp, size: 20,) : Icon(null, size: 20,),
      style: ButtonStyle(
        minimumSize:
        MaterialStateProperty.all<Size>(Size(minimumWidth, minimumHeight)),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) {
            if (states.contains(MaterialState.disabled)) {
              return disabledColor;
            }

            return color;
          },
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          isCircle
              ? CircleBorder()
              : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsets>(padding),
        elevation: MaterialStateProperty.all<double>(0.5),
      ),
      onPressed: onPressed,
      child: text.isNotEmpty ? Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: txtcolor,
            fontFamily: fontfamily
        ),
      ) : child,
    );
  }
}
