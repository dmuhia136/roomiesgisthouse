import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/services/authenticate.dart';
import 'package:gisthouse/services/database_api/auth_api.dart';
import 'package:gisthouse/util/style.dart';
import 'package:gisthouse/widgets/round_button.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'sms_screen.dart';

class PhoneScreen extends StatefulWidget {
  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Function onSignUpButtonClick;
  UserModel user = Get.put(OnboardingController()).onboardingUser;
  String verificationId;
  String countrycode;
  String countryname;
  String error = "";
  bool loading = false;
  String dummyPhoneNumber = '+254722334455';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      backgroundColor: Style.themeColor,
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
            top: 30,
            bottom: 60,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: buildTitle(),
              ),
              SizedBox(
                height: 100,
              ),
              buildForm(),
              SizedBox(
                height: 5,
              ),
              Text(
                error,
                style: TextStyle(color: Colors.red),
              ),
              buildBottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      'Enter your phone #',
      style: TextStyle(fontSize: 25, color: Colors.black),
    );
  }

  Widget buildForm() {
    return Container(
      width: 330,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CountryCodePicker(
            initialSelection: 'KE',
            showCountryOnly: false,
            alignLeft: false,
            onInit: (code) {
              countrycode = code.dialCode;
              countryname = code.name;
              user.countrycode = code.dialCode;
              user.countryname = code.name;
            },
            padding: const EdgeInsets.all(8),
            onChanged: (code) {
              countrycode = code.dialCode;
              countryname = code.name;
              user.countrycode = code.dialCode;
              user.countryname = code.name;
            },
            textStyle: TextStyle(fontSize: 20, color: Style.AccentBlue),
            dialogTextStyle: TextStyle(fontSize: 20, color: Style.AccentBlue),
            searchStyle: TextStyle(fontSize: 20, color: Style.AccentBlue),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: TextFormField(
                onChanged: (value) {
                  _formKey.currentState.validate();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      onSignUpButtonClick = null;
                    });
                  } else {
                    setState(() {
                      onSignUpButtonClick = signUp;
                    });
                  }
                  return null;
                },
                controller: _phoneNumberController,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(
                    fontSize: 20,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottom() {
    return Column(
      children: [
        Text(
          'By entering your number, you\'re agreeing to our \n',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                await launch("https://gisthouse.com/terms-and-conditions");
              },
              child: Text(
                'Terms and Conditions',
                style: TextStyle(
                    color: Colors.blue.withOpacity(0.7),
                    decoration: TextDecoration.underline),
              ),
            ),
            Text(' and',
                style: TextStyle(
                  color: Colors.black54,
                )),
            InkWell(
              onTap: () async {
                await launch("https://gisthouse.com/privacy-policy");
              },
              child: Text(' Privacy Policy.',
                  style: TextStyle(
                      color: Colors.blue.withOpacity(0.7),
                      decoration: TextDecoration.underline)),
            ),
          ],
        ),
        SizedBox(
          height: 120,
        ),
        CustomButton(
          color: Style.Blue,
          minimumWidth: 230,
          // disabledColor: Style.AccentBlue.withOpacity(0.3),
          onPressed: onSignUpButtonClick,
          radius: 50,
          child: Container(
            child: loading == true
                ? Container(
                    width: 100,
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Style.AccentBrown,
                      ),
                    ),
                  )
                : Text(
                    'Next',
                    style: TextStyle(
                      color: Style.White,
                      fontSize: 20,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  verifyPhone(phoneNumber) async {
    String requestId = await AuthAPI().sendVerificationCode(phoneNumber);
    Get.to(() => SmsScreen(
          verificationId: requestId,
          phoneNumber: phoneNumber,
        ));
    setState(() {
      loading = false;
    });
  }

  String logintype = "";

  signUp() async {
    if (_phoneNumberController.text.isEmpty) {
      setState(() {
        error = "Enter Phone Number";
      });
    } else {
      setState(() {
        loading = true;
        error = "";
      });

      String phoneNumber = countrycode + "" + _phoneNumberController.text;

      if (phoneNumber == dummyPhoneNumber) {
        var token = await AuthAPI().authForTesting(dummyPhoneNumber);
        await AuthService()
            .signInWithCustomToken('phonenumber', dummyPhoneNumber, token);
      } else {
        verifyPhone(phoneNumber);
      }
    }
  }
}
