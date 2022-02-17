import 'package:flutter/material.dart';
import 'package:gisthouse/util/utils.dart';

class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  FollowButton({this.isFollowing = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return TextButton(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(

          border: Border.all(color: Style.Blue),
            color: isFollowing ? Style.Blue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20)),
        child: Text(
          isFollowing ? "Following" : "Follow",
          style: theme.textTheme.button.copyWith(color: isFollowing ? Colors.white : Style.AccentBlue,
              fontFamily: "InterLight",
              fontSize: 13),
        ),
      ),
    );
  }
}
