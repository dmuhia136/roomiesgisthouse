import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/pages/clubs/view_club.dart';
import 'package:gisthouse/util/utils.dart';

class CategoryRow extends StatelessWidget {
  final List<String> category;
  final List<String> ids;
  Color color = Colors.white;

  CategoryRow({this.ids, this.category, this.color});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.02,

      child: Container(
        height: MediaQuery.of(context).size.height * 0.02,
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: category
                .map(
                  (e) => InkWell(
                    onTap: () {
                      Get.back();
                      Get.to(() => ViewClub(
                            clubid: ids[
                                category.indexWhere((element) => element == e)],
                          ));
                    },
                    child: Row(
                      children: [
                        Text(
                          e,
                          style: TextStyle(
                              color: Style.AccentGrey,
                              fontSize: 12,
                              fontFamily: "InterBold"),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Icon(
                          Icons.home,
                          color: Style.AccentGreen,
                          size: 18,
                        ),
                        if (category.length > 1)
                          Text(
                            ", ",
                            style: TextStyle(color: color),
                          ),
                      ],
                    ),
                  ),
                )
                .toList()),
      ),
      // child: ListView(
      //   scrollDirection: Axis.horizontal,
      //   // shrinkWrap: true,
      //   children: ids
      //       .map(
      //         (e) => InkWell(
      //             onTap: () {
      //               Get.back();
      //               Get.to(() => ViewClub(
      //                 clubid: e,
      //               ));
      //             },
      //             child: Container(
      //               height: 30,
      //               child: Row(
      //                 children: [
      //                   Flexible(
      //                     child: Text(
      //                       category.join(","),
      //                       style: TextStyle(color: color),
      //                     ),
      //                   ),
      //                   SizedBox(width: 8),
      //                   SmallIcon(Icons.home, color: theme.primaryColor),
      //                 ],
      //               ),
      //             )),
      //       )
      //       .toList(),
      // ),
      //   )
      // : InkWell(
      //     onTap: () {
      //       Functions.debug("ids.first ${ids.first}");
      //       Get.back();
      //       Get.to(() => ViewClub(
      //             clubid: ids.first,
      //           ));
      //     },
      //     child: Row(
      //       children: [
      //         Flexible(
      //           child: Text(
      //             category.join(","),
      //             style: TextStyle(color: color),
      //           ),
      //         ),
      //         SizedBox(width: 8),
      //         SmallIcon(Icons.home, color: theme.primaryColor),
      //       ],
    );
  }
}
