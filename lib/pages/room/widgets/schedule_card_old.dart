import 'package:flutter/material.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';
import 'package:intl/intl.dart';

class ScheduleCardOld extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Database.getEvents("", 4),
        builder: ( context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.data != null && snapshot.data.length == 0) {
            return Container();
          }
          return snapshot.hasData
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10
                    // vertical: 5
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                          right: 0,
                          bottom: 0,
                          top: 0,
                          child: Image.asset(
                            "assets/icons/upcomingbg.png",
                            width: 80,
                          )),
                      Container(
                        margin: EdgeInsets.only(right: 90),
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: snapshot.data
                              .map(( document) {
                            UpcomingRoom room =
                                UpcomingRoom.fromJson(document);
                            return buildScheduleItem(room);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget buildScheduleItem(UpcomingRoom room) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(right: 10,top: 6),
          child: Text(
            DateFormat("h:mm a").format(DateTime.fromMillisecondsSinceEpoch(room.eventtime)),
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              room.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        )
        // Flexible(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       // room.clubname.isNotEmpty
        //       //     ? Container(
        //       //       child: Wrap(
        //       //           children: [
        //       //             Text(
        //       //               room.clubname,
        //       //               style: TextStyle(
        //       //                 color: Colors.white,
        //       //                 fontSize: 12,
        //       //               ),
        //       //             ),
        //       //             SizedBox(
        //       //               width: 5,
        //       //             ),
        //       //             Icon(
        //       //               Icons.home,
        //       //               color: Colors.white,
        //       //               size: 10,
        //       //             )
        //       //           ],
        //       //         ),
        //       //     )
        //       //     : Container(),
        //       Text(
        //         room.title,
        //         overflow: TextOverflow.ellipsis,
        //         style: TextStyle(
        //           color: Colors.white,
        //         ),
        //       )
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
