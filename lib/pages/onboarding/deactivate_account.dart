import 'package:flutter/material.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/round_button.dart';

class DeactivateAccount extends StatefulWidget {
  const DeactivateAccount();

  @override
  _DeactivateAccountState createState() => _DeactivateAccountState();
}

class _DeactivateAccountState extends State<DeactivateAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.themeColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Style.themeColor,
        elevation: 0,
        title: Text(
          "DEACTIVATE",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Text(
              "This will deactivate your account",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Your profile will no longer be shown anywhere within GistHouse",
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "You have 30 days to reactivate it",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Log back in to your account at any time in the next 30 mdays and your account will return back to normal. You can only deactivate once per week",
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "After that, deactivation is permanent",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "If your account stays deactivated for 30 days, we will permanently disable your account. After that you will not able to recover your followers or club admin status",
              // style: TextStyle(color: Colors.black),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton(
                minimumWidth: MediaQuery.of(context).size.width,
                color: Colors.red,
                disabledColor: null,
                onPressed: () {
                  Database().deactivateAccount(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text("I understand. Deactivate Account",
                  style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
