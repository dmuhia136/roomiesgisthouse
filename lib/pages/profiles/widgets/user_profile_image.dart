import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';

class UserProfileImage extends StatelessWidget {
  final String type;
  final Color bordercolor;
  final UserModel user;
  final String txt;
  final double txtsize;
  final double width;
  final bool clickacle;
  final double height;
  final double borderRadius;

  const UserProfileImage({
    Key key,
    @required this.user,
    this.height,
    this.txt,
    this.clickacle,
    this.txtsize,
    this.width,
    this.borderRadius,
    this.type = "header",
    this.bordercolor = const Color(0xFFFFFFFF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: clickacle == false
          ? null
          : () {
              Get.to(
                () => ProfilePage(
                  profile: user,
                  fromRoom: false,
                  isMe: user.uid == Get.find<UserController>().user.uid,
                ),
              );
            },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey[350],
            border: Border.all(
                color: bordercolor ?? Color(0xFFFFFFFF),
                width: type == "header" ? 0 : 5),
            borderRadius: BorderRadius.circular(borderRadius),
            // image: user.imageurl != null && user.imageurl.isNotEmpty
            //     ? DecorationImage(
            //         image: user.imageurl.isNotEmpty ? AssetImage(user.imageurl) : CachedNetworkImageProvider(
            //           imageUrl: user.imageurl,
            //           progressIndicatorBuilder:
            //               (context, url, downloadProgress) =>
            //                   CircularProgressIndicator(
            //                       value: downloadProgress.progress),
            //           errorWidget: (context, url, error) => Icon(Icons.error),
            //         ),
            //         fit: BoxFit.cover,
            //       )
            //     : null,

            // image: user.imageurl.isNotEmpty?  DecorationImage(
            //   image: NetworkImage(user.imageurl),
            //   fit: BoxFit.cover,
            // ) : null,
          ),
          child: user.smallimage.isEmpty
              ? Center(
                  child: Text(
                  user.firstname != null && user.firstname.length > 2
                      ? user.firstname.substring(0, 2).toUpperCase()
                      : "",
                  style: TextStyle(
                      fontSize: txtsize,
                      color: Colors.black,
                      fontFamily: "InterBold"),
                ))
              : new CircleAvatar(
              backgroundImage: new CachedNetworkImageProvider(
                user.smallimage,
              )
          ),
        ),
      ),
    );
  }
}
