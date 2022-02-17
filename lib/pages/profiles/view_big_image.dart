/*
      user profile photo
   */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/util/utils.dart';

viewUserBigPhoto(BuildContext context, String imageurl) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Style.LightBrown,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        )),
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
                initialChildSize: 0.9,
                expand: false,
                builder:
                    (BuildContext context,
                    ScrollController scrollController) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () => Get.back(),
                              child: Icon(
                                Icons.close,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              height: 250,
                              width: 250,
                              decoration: BoxDecoration(
                                color: Colors.grey[350],
                                borderRadius: BorderRadius.circular(100),
                                image: imageurl.isNotEmpty
                                    ? DecorationImage(
                                  image: NetworkImage(imageurl),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                            ),
                          ),
                        ),

                        Spacer(),
                      ],
                    ),
                  );
                });
          });
    },
  );
}
