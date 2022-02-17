import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/upcomingrooms/widgets/upcomingroom_card.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';

final eventcontroller = TextEditingController();
final descriptioncontroller = TextEditingController();

bool showdatecalendarpicker = false,
    publish = false,
    loading = false,
    showtimecalendarpicker = false;
// String timedisplay = "", datedisplay = "";
// int timeseconds;

class UpcomingRoomScreen extends StatefulWidget {
  final UpcomingRoom room;

  const UpcomingRoomScreen({this.room});

  @override
  _UpcomingRoomScreenState createState() => _UpcomingRoomScreenState();
}

class _UpcomingRoomScreenState extends State<UpcomingRoomScreen> {
  String show = "";
  bool keyboardup = false;

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _modalBottomSheetMenu();
    }
  }

  void _modalBottomSheetMenu() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await upcomingroomBottomSheet(context, widget.room, loading, keyboardup);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData (
          color: Colors.black
        ),
        backgroundColor: Style.LightBrown,
        title: Row(
          children: [
            Expanded(
              child: Container(
                  child: InkWell(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                        title: Text('What would you like to see?'),
                        actions: [
                          CupertinoActionSheetAction(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: const Text('Upcoming For You',
                                      style: TextStyle(fontSize: 16, color: Colors.black)),
                                ),
                                if (show != "mine")
                                  Icon(
                                    Icons.check,
                                    color: Colors.blue,
                                  )
                              ],
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                show = "";
                              });
                            },
                            isDefaultAction: true,
                          ),
                          CupertinoActionSheetAction(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: const Text('My Events',
                                      style: TextStyle(fontSize: 16)),
                                ),
                                if (show == "mine")
                                  Icon(
                                    Icons.check,
                                    color: Colors.blue,
                                  )
                              ],
                            ),
                            onPressed: () {
                              setState(() {
                                show = "mine";
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          child: Text(
                            'Cancel',
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      show == "mine" ? "MY EVENTS" : "UPCOMING FOR YOU",
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: Colors.black
                    )
                  ],
                ),
              )),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                CupertinoIcons.calendar_badge_plus,
                size: 35,
                color: Colors.black,
              ),
              onPressed: () {
                createUpcomingRoomSheet(context, false);
              },
            )
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: Database.getEvents(show),
                builder: (context, snapshot) {
                  // Handling errors from firebase
                  if (snapshot.connectionState == ConnectionState.waiting)
                    Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (snapshot.data == null || snapshot.data.length == 0) {
                    return Container(
                        margin: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                            child: Text(
                          "No Rooms yet",
                          style:
                              TextStyle(fontSize: 21, color: Style.AccentBrown),
                        )));
                  }

                  return snapshot.hasData
                      ?
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListView.separated(
                          separatorBuilder: (context, index){
                            return Container(height: 0,);
                          },
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index){


                            return UpcomingRoomCard(
                              room: UpcomingRoom.fromJson(snapshot.data[index]),
                            );
                          }
                        ),
                      )
                  // GroupedListView<dynamic, String>(
                  //         elements: snapshot.data.docs,
                  //         groupBy: (element) {
                  //           var date = DateFormat("yyyy-MM-dd").format(
                  //               DateTime.fromMillisecondsSinceEpoch(
                  //                   element['eventdatetimestamp']));
                  //
                  //           var time = DateFormat("H:mm").format(
                  //               DateTime.fromMillisecondsSinceEpoch(
                  //                   element['eventtimetimestamp']));
                  //           // DateTime combinedDate = DateTime
                  //           //     .parse(date.toString()
                  //           //     + " " + time.toString());
                  //           return Functions.timeFutureSinceDate(
                  //               timestamp: element['eventdatetimestamp'],
                  //               alphas: true);
                  //         },
                  //         groupSeparatorBuilder: (String value) => Container(
                  //           width: MediaQuery.of(context).size.width,
                  //           margin: EdgeInsets.symmetric(vertical: 10),
                  //           decoration: BoxDecoration(color: Colors.grey),
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: Text(
                  //             value == "a"
                  //                 ? "Today"
                  //                 : value == "b"
                  //                     ? "Tomorrow"
                  //                     : value,
                  //             style: TextStyle(
                  //                 fontSize: 20, fontWeight: FontWeight.bold),
                  //           ),
                  //         ),
                  //         itemBuilder: (context, dynamic element) =>
                  //             UpcomingRoomCard(
                  //           room: UpcomingRoom.fromJson(element),
                  //         ),
                  //         itemComparator: (item1, item2) =>
                  //             item1['eventtimetimestamp']
                  //                 .compareTo(item2['eventtimetimestamp']),
                  //         // optional
                  //         useStickyGroupSeparators: true,
                  //         // optional
                  //         floatingHeader: true,
                  //         // optional
                  //         order: GroupedListOrder.ASC, // optional
                  //       )
                      : Center(
                          child: CircularProgressIndicator(),
                        );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
