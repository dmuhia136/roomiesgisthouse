import 'package:gisthouse/models/user_model.dart';
import 'package:gisthouse/pages/home/search_view.dart';
import 'package:gisthouse/pages/upcomingrooms/upcoming_roomsreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/pages/room/notifications.dart';
import 'package:gisthouse/services/dynamic_link_service.dart';
import 'package:gisthouse/wallet/wallet_page.dart';
import 'package:gisthouse/pages/profiles/widgets/user_profile_image.dart';
import 'package:share/share.dart';

class HomeAppBar extends StatelessWidget {
  final UserModel profile;
  final Function onProfileTab;

  const HomeAppBar({Key key, this.profile, this.onProfileTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
// app bar widgets
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

//search Icon
//           child: IconButton(
//             onPressed: () {
//               Get.to(() => SearchView());
//             },
//             iconSize: 30,
//             icon: Icon(
//               Icons.search,
//               color: Colors.black,
//             ),
//           ),

        Spacer(),
        Row(
          children: [
// Invites Icon
            InkWell(
              onTap: () {
                final RenderBox box = context.findRenderObject();
                DynamicLinkService()
                    .createGroupJoinLink(profile.uid, "invite")
                    .then((value) async {
                  await Share.share(value,
                      subject: "Join GistHouse",
                      sharePositionOrigin:
                      box.localToGlobal(Offset.zero) & box.size);
                });
              },
              child: Image.asset(
                "assets/icons/invites.png",
                width: 25,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 40,
            ),
//upcoming groups Icon
            InkWell(
              onTap: () {
                Get.to(() => UpcomingRoomScreen());
              },
              child:
              Image.asset(
                "assets/icons/upcomin.png",
                width: 25,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 40,
            ),
//notification Icon
            InkWell(
              onTap: () {
                Get.to(() => NotificationActivities());
              },
              child: Container(
                // margin: EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/icons/notification.png",
                      width: 23,
                      color: Colors.black,
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.red[600]),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 40,
            ),
//wallet icon
//             InkWell(
//               onTap: () {
//                 Get.to(() => WalletPage());
//               },
//               child: Image.asset(
//                 "assets/icons/walleticon.png",
//                 width: 35,
//                 color: Colors.black
//               ),
//             ),
//             SizedBox(
//               width: 20,
//             ),
//profile logo
            GestureDetector(
              onTap: onProfileTab,
              child: profile.smallimage == null
                  ? Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(profile.firstname.substring(0, 2)))
                  : UserProfileImage(
                      user: profile,
                      borderRadius: 20,
                      width: 40,
                      height: 40,
                    ),
            )
          ],
        ),
      ],
    );
  }
}
