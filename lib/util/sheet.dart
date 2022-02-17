import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/util/utils.dart';

class Sheet {
  static open(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Style.DarkBlue,
      builder: (context) => sheet,
    );
  }

  static openDrag(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Style.DarkBlue,
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.4,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return sheet;
          }),
    ).whenComplete(() => Get.back());
  }

  static openFrosted(BuildContext context, Widget sheet) {
    showBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => sheet,
    );
  }
}
