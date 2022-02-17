import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/services/authenticate.dart';
import 'package:gisthouse/util/style.dart';

class InviteOnly extends StatelessWidget {
  const InviteOnly({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg.png",),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Sorry ${Get.put(UserController()).user.firstname}",
                      style: TextStyle(fontSize: 21, color: Colors.white),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Your account has been disabled, for more information contact our support team at support@gisthouse.com",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),

                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: () {
                  AuthService().signOut();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Style.AccentBlue.withOpacity(0.6)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Wait Outside?",
                          style: (TextStyle(fontSize: 16, color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
