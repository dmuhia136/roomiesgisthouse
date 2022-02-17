import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RoundImage extends StatelessWidget {
  final String url;
  final String path;
  final String txt;
  final double width;
  final bool clickacle;
  final double height;
  final double txtsize;
  final EdgeInsets margin;
  final double borderRadius;
  final double opacity;

  const RoundImage(
      {Key key,
      this.txtsize = 23,
      this.txt,
      this.clickacle = true,
      this.url = "",
      this.path = "",
      this.margin,
      this.width = 40,
      this.height = 40,
      this.borderRadius = 40,
        this.opacity = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey[350],
          borderRadius: BorderRadius.circular(borderRadius),
          image: url != null && url.isNotEmpty || path.isNotEmpty
              ? DecorationImage(
                  image: path.isNotEmpty ? AssetImage(path) : NetworkImage(url),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: url != null && url.isEmpty
            ? Center(
                child: Text(
                txt != null && txt.length > 1
                    ? txt.substring(0, 2).toUpperCase()
                    : txt.length <= 1
                        ? txt
                        : "",
                style: TextStyle(
                    fontSize: txtsize,
                    color: Colors.black,
                    fontFamily: "InterBold"),
              ))
            : new CircleAvatar(
                backgroundColor: Colors.grey.withOpacity(0.1),
                backgroundImage: new CachedNetworkImageProvider(
                  url,
                ),
                // child: Text(
                //   txt != null && txt.length > 1
                //       ? txt.substring(0, 2).toUpperCase()
                //       : txt.length <= 1
                //           ? txt
                //           : "",
                //   style: TextStyle(
                //       fontSize: txtsize,
                //       color: Colors.black,
                //       fontFamily: "InterBold"),
                // ),
              ),
      ),
    );
  }
}
