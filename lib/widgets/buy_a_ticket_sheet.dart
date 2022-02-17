import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/home/home_page.dart';
import 'package:gisthouse/pages/room/lounge_screen.dart';
import 'package:gisthouse/pages/room/more_container.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';

class BuyATicketSheet extends StatefulWidget {
  final Room room;
  final bool isAll;

  BuyATicketSheet(this.room, this.isAll);

  @override
  _BuyATicketSheetState createState() => _BuyATicketSheetState();
}

class _BuyATicketSheetState extends State<BuyATicketSheet> {
  bool showMoreContainer = false;
  UserModel user = Get.find<UserController>().user;

  final globalScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWalletBal();
  }

  getWalletBal() {
    return user.gchtml();
  }

  // joinRoom() async {
  //   Get.back();
  //   Get.back();
  //
  //   if(user.activeroom !=null && user.activeroom.isNotEmpty){
  //     await Functions.leaveChannel(
  //         quit: false, roomid: user.activeroom, currentUser: user, context: context);
  //   }
  //
  //
  //   await Database().addUserToRoom(room: widget.room, user: user);
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (rc) {
  //       return RoomScreen(
  //         roomid: widget.room.roomid,
  //       );
  //     },
  //   );
  // }

  // payViaNewCard(BuildContext context, amount) async {
  //   ProgressDialog dialog = new ProgressDialog(context);
  //   dialog.style(message: 'Please wait...');
  //   await dialog.show();
  //   var response = await StripeService.payWithNewCard(
  //       amount: (amount * 100).toStringAsFixed(0), currency: 'USD', loading: true, context: context);
  //   await dialog.hide();
  //   Get.back();
  //   if (response.message == "Ok") {
  //
  //     //join room
  //     joinRoom();
  //
  //     //update user data with the joined class key
  //     Database.updateProfileData(user.uid, {
  //       "paidrooms" : FieldValue.arrayUnion([widget.room.roomid]),
  //     });
  //
  //     //add user transactions
  //     Database().addTransactions(
  //         userModel: Get.find<UserController>().user,
  //         txtReason: "Joined Room (${widget.room.title}) using stripe",
  //         amount: "USD ${amount}",
  //         type: "0"
  //     );
  //
  //     //show alert message
  //     topTrayPopup(
  //         "You have successfully deposited USD ${amount}", bgcolor: Colors.green);
  //   }else{
  //     topTrayPopup("Deposit failed");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    "Buy Ticket to join this GistRoom",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    physics: BouncingScrollPhysics(),
                    children: [
                      SizedBox(height: 8),
                      Text(
                        widget.room.title,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      if (widget.room.clubListNames.isNotEmpty)
                        CategoryRow(category: widget.room.clubListNames, color:Style.indigo, ids: widget.room.clubListIds,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildColumn(
                theme,
                t1: "${widget.room.currency}${widget.room.amount}",
                t2: "Ticket Charge",
              ),
              SizedBox(
                width: 80,
              ),
              Expanded(
                child: FloatingActionButton.extended(
                  onPressed: () {
                   if(Get.find<UserController>().user.coinsEnabled == true ) {
                     showCupertinoModalPopup(
                       context: context,
                       builder: (BuildContext context) => CupertinoActionSheet(
                           title: Text('Wallet Balance (${getWalletBal()})'),
                           actions: [
                             CupertinoActionSheetAction(
                               child: Text(
                                   'Amount to be deducted (${widget.room.currency} ${widget.room.amount})',
                                   style: TextStyle(fontSize: 16)),
                               onPressed: () async {},
                             ),
                           ],
                           cancelButton: CupertinoActionSheetAction(
                             child: Text('Confirm',
                                 style:
                                 TextStyle(fontSize: 16, color: Colors.red)),
                             onPressed: () {
                               Navigator.pop(context);
                               if ((Database().chargeWallet( widget.room, user) ==
                                   true)) {

                                 Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                     HomePage()), (Route<dynamic> route) => false);

                                 joinRoom(
                                   context,
                                   user,
                                   roomid: widget.room.roomid,
                                   roomIdToLeave: user.activeroom,
                                 );
                               }
                             },
                           )),
                     );
                   } else {
                     blockCheck();
                   }
                  },
                  // onPressed: () => Get.to(() => ConfirmPaymentPage(room: room,)),
                  label: Text(
                      widget.room.ownerid != Get.find<UserController>().user.uid
                          ? "Buy Ticket"
                          : "Edit"),
                  // icon: Icon(isAll ? Icons.add : Icons.edit, size: 16),
                  foregroundColor: Colors.white,
                  backgroundColor: Style.AccentGreen,
                ),
              ),
            ],
          ),
        ),
        if (showMoreContainer)
          Align(
            alignment: Alignment.bottomCenter,
            child: MoreContainer(),
          ),
      ],
    );
  }

  Widget buildColumn(
    ThemeData theme, {
    String t1,
    String t2,
    IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (t1 != null) Text(t1, style: TextStyle(color: Colors.white)),
        if (icon != null) Icon(icon, color: Colors.white),
        SizedBox(height: 4),
        Text(
          t2,
          style: theme.textTheme.caption.copyWith(color: Style.indigo),
        ),
      ],
    );
  }

  void blockCheck() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
            onWillPop: () async => false,
            // <-- Prevents dialog dismiss on press of back button.
            child: new CupertinoAlertDialog(
              title: new Text('Wallet Access Denied!'),
              content: new Text(
                  'You have been blocked from accessing your wallet. Contact Admin for more details'),
              actions: <Widget>[
                new CupertinoDialogAction(
                    child: const Text('Okay'),
                    onPressed: () async {
                      Navigator.pop(context);
                    }),
              ],
            )));
  }
}
