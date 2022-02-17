import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/functions/functions.dart';
import 'package:gisthouse/pages/home/home_page.dart';
import 'package:gisthouse/pages/onboarding/full_name_page.dart';
import 'package:gisthouse/pages/onboarding/welcome_page.dart';
import 'package:gisthouse/services/authenticate.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';

class EmailVerification extends StatefulWidget {
  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  var user = Get.find<AuthController>();
  bool loading = false;

  // Timer timer;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/images/bg.png",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Verify Your Email",
                  style: TextStyle(color: Colors.white),
                ),
                FlatButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () async {
                    await AuthService().signOut();
                    // timer.cancel();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WelcomeScreen()),
                        ModalRoute.withName("/Welcome"));
                  },
                  child: Icon(
                    Icons.logout,
                    color: Colors.blueAccent,
                  ),
                )
              ],
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: loading == true
              ? loadingWidget(context)
              : SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Text(
                          "We just sent you an email! Just making sure this email belongs to you. After you’ve opened the link in your email, click the button below! 🥳",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'RaleWay',
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                      Container(
                        child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            await FirebaseAuth.instance.currentUser
                                .sendEmailVerification()
                                .onError((error, stackTrace) => Functions.debug(error));
                            setState(() {
                              loading = false;
                            });
                          },
                          child: Text(
                            "Resend verification",
                            style: TextStyle(
                                fontSize: 16, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: CustomButton(
                          color: Color(0XFF00FFB0),
                          radius: 10,
                          txtcolor: Style.AccentBrown,
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            await FirebaseAuth.instance.currentUser.reload();
                            var user = await FirebaseAuth.instance.currentUser;
                            if (user.emailVerified) {
                              await Database.getUserProfile(user.uid)
                                  .then((value) async {
                                if (value != null) {
                                  await Database.updateProfileData(user.uid, {
                                    'emailVerified': true,
                                  });
                                  Get.offAll(() => HomePage());
                                } else {
                                  Get.offAll(() => FullNamePage());
                                }
                              });
                            } else {
                              topTrayPopup('Email not verified yet');
                            }
                            setState(() {
                              loading = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "I’ve verified my email!",
                                  style: TextStyle(
                                    color: Style.AccentBrown,
                                    fontSize: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
    );
  }
}
