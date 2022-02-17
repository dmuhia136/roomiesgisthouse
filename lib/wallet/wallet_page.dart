import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/database_api/user_api.dart';
import 'package:gisthouse/services/wallet.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/wallet/transaction_list.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'search_wallet_users.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  UserModel user = Get.find<UserController>().user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUserFromApi();
  }

  getUserFromApi() async {
    var userFromApi = await UserApi().getUserById(user.uid);
    user = UserModel.fromJson(userFromApi);
    setState(() {});

    if (user.coinsEnabled == false) {
      blockCheck();
    }
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
                      Navigator.pop(context);
                    }),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    var date1 = DateFormat("dd-MM-yyyy h:mma").parse(
        DateFormat("dd-MM-yyyy h:mma")
            .format(DateTime.fromMicrosecondsSinceEpoch(user.membersince)));

    var date2 = DateFormat("dd-MM-yyyy h:mma").parse(
        DateFormat("dd-MM-yyyy h:mma").format(
            DateTime.fromMicrosecondsSinceEpoch(
                DateTime.now().microsecondsSinceEpoch)));

    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Style.AccentBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(
          "Wallet".toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            color: Style.AccentBlue,
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Wallet Balance",
                      style: theme.textTheme.caption
                          .copyWith(fontSize: 13, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${user.gchtml()}",
                          style: theme.textTheme.headline5.copyWith(
                              fontSize: 23,
                              fontFamily: "LucidaGrande",
                              color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(height: 10),
                user.coinsEnabled == false
                    ? Container()
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                  onTap: () {
                                    if (user.coinsEnabled == true) {
                                      Functions.showPaymentOptions(context);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: Color(0XFF00FFB0),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.asset("assets/icons/eicon.png"),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text("Deposit",
                                            style: TextStyle(fontSize: 18))
                                      ],
                                    ),
                                  )),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: InkWell(
                                  onTap: () {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          CupertinoActionSheet(
                                              title: Text("Transfer.."),
                                              actions: [
                                                CupertinoActionSheetAction(
                                                  child: Text("Send",
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  onPressed: () {
                                                    Get.back();
                                                    if (user.coinsEnabled == true) {
                                                      Get.to(() =>
                                                          SearchWalletUsers());
                                                    } else {
                                                      blockCheck();
                                                    }
                                                  },
                                                ),
                                                CupertinoActionSheetAction(
                                                  child: Text("Withdraw",
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  onPressed: () {
                                                    Get.back();
                                                    if (user.coinsEnabled == true) {
                                                      topTrayPopup(
                                                          "Coming Soon..");
                                                    } else {
                                                      blockCheck();
                                                    }
                                                    // Get.to(() => WithdrawFunds());
                                                  },
                                                )
                                              ],
                                              cancelButton:
                                                  CupertinoActionSheetAction(
                                                child: Text('Cancel',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.red)),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              )),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: Color(0XFF6236FF),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.asset("assets/icons/dicon.png"),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text("Transfer",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white))
                                      ],
                                    ),
                                  )),
                            )
                          ],
                        ),
                      ),
                SizedBox(height: 18),
                TransactionList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  onButtonPressed(type, amount) {
    if (type == "Stripe") {
      // payViaNewCard(context, amount);
      Get.back();
    }
  }

// payViaNewCard(BuildContext context, amount) async {
//   Functions.debug((double.parse(amount) * 100).toStringAsFixed(0));
//   ProgressDialog dialog = new ProgressDialog(context);
//   dialog.style(message: 'Please wait...');
//   await dialog.show();
//   var response = await StripeService.payWithNewCard(
//       amount: (double.parse(amount) * 100).toStringAsFixed(0),
//       currency: 'USD',
//       loading: true,
//       context: context);
//   await dialog.hide();
//   Get.back();
//   Functions.debug(response.message);
//   if (response.message == "Ok") {
//     //add user transactions
//     Database.updateProfileData(
//         user.uid, {"mbalance": user.mbalance + double.parse(amount)});
//
//     Database().addTransactions(
//         userModel: user,
//         txtReason: "Deposited from Stripe",
//         amount: "USD $amount",
//         type: "1");
//
//     //show alert message
//     topTrayPopup("You have successfully deposited USD ${amount}",
//         bgcolor: Colors.green);
//   } else {
//     topTrayPopup("Deposit failed");
//   }
// }
}

class CustomDialogBox extends StatefulWidget {
  final String amount;

  const CustomDialogBox({Key key, this.amount}) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  var email = TextEditingController();
  var password = TextEditingController();
  var paymentrespose;
  var confirmationresponse;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Style.DarkBlue,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "$gccurrency${widget.amount}",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Fund Gistcoin Wallet",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              if (confirmationresponse != null)
                Container(
                  child: Text(
                      "You have successfully deposited $gccurrency${widget.amount}"),
                ),
              Positioned(
                  right: 10,
                  top: 10,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                  ))
            ],
          ),
          if (paymentrespose != null)
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Style.AccentBlue, width: 0.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: Column(children: [
                    Text(
                      "Logged in as ${paymentrespose["wallet"]["name"]}",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                        "Wallet balance $gccurrency${paymentrespose["wallet"]["balance"]}")
                  ]),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(children: [
                    Text("Pay GistHouse", style: TextStyle(fontSize: 15)),
                    Text("$gccurrency ${widget.amount}",
                        style: TextStyle(fontSize: 25))
                  ]),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Style.DarkBlue),
                      borderRadius: BorderRadius.circular(5),
                      color: Style.AccentBrown),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: TextButton(
                    onPressed: () async {
                      loading = true;
                      setState(() {});
                      confirmationresponse = await Wallet.depositInit(
                          ref: paymentrespose["data"]["reference"]);

                      if (confirmationresponse["success"] == true) {
                        UserModel user = Get.find<UserController>().user;

                        Get.back();
                        //add user transactions
                        Database.updateProfileData(user.uid, {
                          "gcbalance":
                              user.gcbalance + double.parse(widget.amount)
                        });
                        Get.find<UserController>().user.gcbalance =
                            Get.find<UserController>().user.gcbalance +
                                double.parse(widget.amount);

                        Database().addTransactions(
                            userid: user.uid,
                            txtReason: "Deposited GC",
                            amount: "$gccurrency ${widget.amount}",
                            type: "1");

                        //show alert message
                        topTrayPopup(
                            "You have successfully deposited $gccurrency ${widget.amount}",
                            bgcolor: Colors.green);
                      } else {
                        topTrayPopup("Deposit failed");
                      }
                      // paymentrespose = null;
                      loading = false;
                      setState(() {});
                    },
                    child: loading == true
                        ? CircularProgressIndicator()
                        : Text("Confirm Payment",
                            style:
                                TextStyle(fontSize: 18, color: Style.indigo)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          if (paymentrespose == null)
            Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Text("Login to your GistWallet to pay"),
                SizedBox(
                  height: 15,
                ),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Style.DarkBlue),
                          borderRadius: BorderRadius.circular(5)),
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: email,
                        autocorrect: false,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          hintStyle:
                              TextStyle(fontSize: 17, color: Style.AccentBrown),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: Style.DarkBlue),
                          borderRadius: BorderRadius.circular(5)),
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: password,
                        autocorrect: false,
                        obscureText: true,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'password',
                          hintStyle:
                              TextStyle(fontSize: 17, color: Style.AccentBrown),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Style.DarkBlue),
                      borderRadius: BorderRadius.circular(5),
                      color: Style.AccentBrown),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: TextButton(
                    onPressed: () async {
                      loading = true;
                      setState(() {});
                      paymentrespose = await Wallet.depositGistCoins(
                          amount: widget.amount,
                          email: email.text,
                          password: password.text);
                      loading = false;
                      setState(() {});
                    },
                    child: loading == true
                        ? CircularProgressIndicator()
                        : Text(
                            paymentrespose != null
                                ? "Confirm Payment"
                                : "Pay $gccurrency${widget.amount}",
                            style:
                                TextStyle(fontSize: 18, color: Style.indigo)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    if (await canLaunch(
                        "https://dashboard.gistcoinico.com/login"))
                      await launch("https://dashboard.gistcoinico.com/login");
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "You dont have an Account? ",
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                          text: "Signup Here",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            )
        ],
      ),
    );
  }
}
