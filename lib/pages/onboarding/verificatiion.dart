import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/loading.dart';
import 'package:gisthouse/widgets/top_tray_popup.dart';
import 'package:gisthouse/widgets/widgets.dart';

class Verificatio extends StatefulWidget {
  const Verificatio({Key key}) : super(key: key);

  @override
  _VerificatioState createState() => _VerificatioState();
}

class _VerificatioState extends State<Verificatio> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  UserModel user = Get.find<UserController>().user;

  bool loading = false;

  String texterror = "";

  String errorp = "";

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth.instance.currentUser.updateEmail("ggg@gmail.com");
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
        backgroundColor: Style.themeColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text(
            "Verification".toUpperCase(),
            style: TextStyle(color: Colors.black,
            letterSpacing: 0.8
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: loading
              ? loadingWidget(context)
              : Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      if (user.email != null)
                        Container(
                          padding: EdgeInsets.only(left: 30),
                          alignment: Alignment.topLeft,
                          child: Text(user.email,
                              style: TextStyle(color: Colors.white)),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Email Verification",
                            style: TextStyle(color: Colors.black,
                            fontSize: 17.0,
                              letterSpacing: 0.5
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: user.emailverified == true
                                  ? Style.Blue
                                  : Style.Blue.withOpacity(0.5)
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            child: Text(
                              user.emailverified == true ? "Passed" : "Pending",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                      if (user.emailverified == false)
                        Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Click the link in your email to verify your account",
                              softWrap: true,
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                  color: Colors.white),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _emailController,
                                      autocorrect: false,
                                      autofocus: false,
                                      decoration: InputDecoration(
                                        hintText: 'email@gmail.com',
                                        hintStyle: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Colors.black45),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      texterror = "";
                                      setState(() {
                                        loading = true;
                                      });
                                      if (_emailController.text.isEmpty ||
                                          !isEmail(_emailController.text)) {
                                        texterror = "Enter valid email";
                                      } else {
                                        setState(() {
                                          loading = true;
                                        });
                                        sendVerificationEmail(
                                            _emailController.text);
                                      }
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 8),
                                      child: Text(
                                        "Resend Email",
                                        style:
                                            TextStyle(color: Color(0XFF096bc0)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Text(
                              texterror,
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  String countrycode;
  String countryname;
  Function phoneverifyButtonClick;

  Widget buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0XFF081327),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                CountryCodePicker(
                  initialSelection: 'US',
                  showCountryOnly: false,
                  alignLeft: false,
                  onInit: (code) {
                    countrycode = code.dialCode;
                    countryname = code.name;
                  },
                  padding: const EdgeInsets.all(8),
                  onChanged: (code) {
                    countrycode = code.dialCode;
                    countryname = code.name;
                  },
                  textStyle: TextStyle(fontSize: 20, color: Colors.white),
                  dialogTextStyle:
                      TextStyle(fontSize: 20, color: Style.AccentBlue),
                  searchStyle: TextStyle(fontSize: 20, color: Style.AccentBlue),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _phoneNumberController,
                    autocorrect: false,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.white),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              phoneVerify();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Text(
                "Send Code",
                style: TextStyle(color: Color(0XFF096bc0)),
              ),
            ),
          )
        ],
      ),
    );
  }

  sendVerificationEmail(String email) async {
    var userm = FirebaseAuth.instance.currentUser;
    String code = "";
    await userm.updateEmail(email).onError((error, b) {
      code = error.code;
      if (error.code == "email-already-in-use") {
        topTrayPopup(error.message, bgcolor: Colors.red);
      }
      if (error.code == "too-many-requests") {
        topTrayPopup(error.message, bgcolor: Colors.red);
      }
      if (error.code == "requires-recent-login") {
        topTrayPopup("Verify Phone Number First");
        Database.updateProfileData(FirebaseAuth.instance.currentUser.uid,
            {"phonenumberverified": false});
        setState(() {
          user.phonenumberverified = false;
        });
      }
    });
    if (code.isEmpty) {
      await userm.sendEmailVerification();
      Get.snackbar("", "",
          snackPosition: SnackPosition.TOP,
          borderRadius: 0,
          titleText: Text(
            "Check your email for a confirmation link, once you click then link, come back and reopen your wallet page again to refresh the email confirmation.",
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontFamily: "InterBold"),
          ),
          margin: EdgeInsets.all(0),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(days: 365),
          messageText: Container(
            margin: EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  color: Colors.white70,
                  text: "Okay",
                  txtcolor: Colors.white,
                  fontSize: 16,
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ));
      Database.updateProfileData(user.uid, {"email": email});
    }
  }

  String error = "";
  bool verifynow = false;
  String verificationId;

  phoneVerify() async {
    if (_phoneNumberController.text.isEmpty) {
      setState(() {
        error = "Enter Phone Number";
      });
    } else {
      setState(() {
        loading = true;
        verifynow = false;
        error = "";
      });
      verifyPhone(countrycode + "" + _phoneNumberController.text);
    }
  }

  Future<void> verifyPhone(phoneNumber) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {};

    final PhoneVerificationFailed verificationfailed = (authException) {
      setState(() {
        loading = false;
        error =
            "Error verifying Your Phone Number, try again later or try another phone number";
      });
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      setState(() {
        loading = false;
        verifynow = true;
      });
      topTrayPopup("Otp Sent to your phone number", bgcolor: Colors.green);
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };
    await FirebaseAuth.instance.verifyPhoneNumber(

        /// Make sure to prefix with your country code
        phoneNumber: phoneNumber,

        ///No duplicated SMS will be sent out upon re-entry (before timeout).
        timeout: const Duration(seconds: 5),

        /// If the SIM (with phoneNumber) is in the current device this function is called.
        /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
        /// When this function is called there is no need to enter the OTP, you can click on Login button to sigin directly as the device is now verified
        verificationCompleted: verified,

        /// Called when the verification is failed
        verificationFailed: verificationfailed,

        /// This is called after the OTP is sent. Gives a `verificationId` and `code`
        codeSent: smsSent,

        /// After automatic code retrival `tmeout` this function is called
        codeAutoRetrievalTimeout: autoTimeout);
  }
}
