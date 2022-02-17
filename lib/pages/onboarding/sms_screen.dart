import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gisthouse/services/authenticate.dart';
import 'package:gisthouse/services/database_api/auth_api.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/round_button.dart';

class SmsScreen extends StatefulWidget {
  String verificationId;
  final String phoneNumber;

  SmsScreen({Key key, this.verificationId, this.phoneNumber}) : super(key: key);

  @override
  _SmsScreenState createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  final _smsController = TextEditingController();
  bool loading = false;
  String errortxt = "";

  Timer _timer;
  int _start = 300;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        if (mounted) {
          setState(() {
            timer.cancel();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage(
      //       "assets/images/bg.png",
      //     ),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        backgroundColor: Style.themeColor,
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 5, bottom: 60),
            child: Column(
              children: [
                title(),
                SizedBox(height: 80),
                form(),
                SizedBox(
                  height: 50.0,
                ),
                loading == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : bottom(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Padding(
      padding: const EdgeInsets.only(left: 80.0, right: 80.0),
      child: Text(
        'Enter the code we just texted you',
        style: TextStyle(fontSize: 25, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget form() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Form(
              child: TextFormField(
                textAlign: TextAlign.center,
                controller: _smsController,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: '••••••',
                  hintStyle: TextStyle(fontSize: 20, color: Colors.black54),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          SizedBox(height: 15.0),
          if (errortxt.isNotEmpty)
            Text(
              errortxt,
              style: TextStyle(color: Colors.red),
            ),
          Container(
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                Text(
                  "Didn't receive the code?",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () async {
                    if (_start == 0) {
                      String requestId = await AuthAPI()
                          .sendVerificationCode(widget.phoneNumber);
                      widget.verificationId = requestId;
                      _start = 300;
                      startTimer();
                    }
                  },
                  child: Text(
                    _start != 0
                        ? "${Duration(seconds: _start).inMinutes}:${Duration(seconds: _start).inSeconds.remainder(60)}"
                        : "Resend code?",
                    style: TextStyle(
                      color: Colors.blue.withOpacity(0.7),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget bottom() {
    return Column(
      children: [
        SizedBox(height: 30),
        CustomButton(
          color: Style.Blue,
          minimumWidth: 230,
          disabledColor: Style.Blue.withOpacity(0.3),
          onPressed: () async {
            errortxt = "";
            setState(() {
              loading = true;
            });
            await AuthService()
                .signInWithOTP(context, _smsController.text,
                    widget.verificationId, "phonenumber", widget.phoneNumber)
                .then((value) {
              if (value == "null") {
                errortxt = "Otp is not valid";
                setState(() {
                  loading = false;
                });
              } else {
                setState(() {
                  loading = false;
                });
              }
            });
          },
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next  ',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Icon(Icons.arrow_right_alt, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
