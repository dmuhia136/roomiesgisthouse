import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/onboarding/email_verification.dart';
import 'package:gisthouse/services/authenticate.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailPassword extends StatefulWidget {
  const EmailPassword({Key key}) : super(key: key);

  @override
  _EmailPasswordState createState() => _EmailPasswordState();
}

class _EmailPasswordState extends State<EmailPassword> {
  final _formKey = GlobalKey<FormState>();
  String error = "";
  final _emailController = TextEditingController();
  UserModel user = Get.put(OnboardingController()).onboardingUser;
  final _passwordController = TextEditingController();
  Function onSignUpButtonClick;
  String verificationId;
  String countrycode;
  String countryname;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _success;
  String _userEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    _auth
        .createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text)
        .then((value) {

      loading = false;
      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = value.user.email;
          user.email = value.user.email;
        });
      } else {
        setState(() {
          _success = true;
        });
      }
      if (FirebaseAuth.instance.currentUser.displayName == null ||
          FirebaseAuth.instance.currentUser.displayName == "" &&
              FirebaseAuth.instance.currentUser.emailVerified == false) {
        FirebaseAuth.instance.currentUser.sendEmailVerification();
        return Get.offAll(() => EmailVerification());
      }else{
        AuthService.loginRedirect(value.user, "email");
      }

    }).catchError((onError) async {
      _auth
          .signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )
          .then((value) {
        if (value.user != null) {
          if(value.user.emailVerified == false){
            Get.snackbar("", "",
                snackPosition: SnackPosition.TOP,
                borderRadius: 0,
                titleText: Text(
                  "Email not verified",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: "InterBold"),
                ),
                margin: EdgeInsets.all(0),
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: Duration(days: 365),
                messageText: Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Column(
                    children: [
                      Text("You have not verified your email, please check your email for a confirmatiion link, if you did not get it click on resend"),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            color: Colors.white70,
                            text: "Dismiss",
                            txtcolor: Colors.white,
                            fontSize: 16,
                            onPressed: () {
                              Get.back();
                            },
                          ),
                          SizedBox(width: 50,),
                          CustomButton(
                            color: Colors.white70,
                            text: "Resend",
                            txtcolor: Colors.white,
                            fontSize: 16,
                            onPressed: () {
                              FirebaseAuth.instance.currentUser.sendEmailVerification();
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
          }else{
            AuthService.loginRedirect(value.user, "email");
          }
        }

        setState(() {
          loading = false;
          // error = "Email already exists";
        });
      }).catchError((errorr, stackTrace) {
                setState(() {
                  loading = false;
                  // error = errorr.toString();
                  error = "Password is wrong";
                });
                // Functions.debug(onError.toString())
              });
    });
  }

  var loading = false, passwordchanged = false;

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            passwordchanged == false
                ? 'Enter Email and Password'
                : "Check your email and change password",
            style: TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 50,
        ),
        buildForm(),
        Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Center(
            child: Text(
              error,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
        // Spacer(),
        buildBottom(),
      ],
    ),
        ),
      ),
    ));
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  @override
  Future<void> resetPassword(String email) async {
    setState(() {
      loading = true;
    });
    _auth.sendPasswordResetEmail(email: email);
    setState(() {
      passwordchanged = true;
      loading = false;
    });
  }

  Widget buildForm() {
    return Column(
      children: [
        if (passwordchanged == false)
          Container(
            width: 330,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Form(
                    child: TextFormField(
                      onChanged: (value) {
                        _formKey.currentState.validate();
                      },
                      controller: _emailController,
                      autocorrect: false,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        hintStyle: TextStyle(
                          fontSize: 20,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      keyboardType: TextInputType.emailAddress,
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
          ),
        SizedBox(
          height: 30,
        ),
        Container(
          width: 330,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
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
                    controller: _passwordController,
                    autocorrect: false,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        fontSize: 20,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    obscureText: true,
                    enableSuggestions: false,
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
        ),
        SizedBox(
          height: 15,
        ),
        if (passwordchanged == false)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 35),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () async {
                  setState(() {
                    error = "";
                  });
                  if (_emailController.text.isEmpty ||
                      !isEmail(_emailController.text)) {
                    setState(() {
                      error = "Enter Valid Email Address";
                    });
                  } else {
                    resetPassword(_emailController.text);
                  }
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _success == null
                ? ''
                : (_success
                    ? 'Successfully signed in ' + _userEmail
                    : 'Sign in failed'),
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );
  }

  Widget buildBottom() {
    return Column(
      children: [
        Text(
          'By entering your number, you\'re agreeing to our \n',
          style: TextStyle(
            color: Colors.white,
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
                style: TextStyle(color: Colors.blue),
              ),
            ),
            Text(' and', style: TextStyle(color: Colors.white)),
            InkWell(
              onTap: () async {
                await launch("https://gisthouse.com/privacy-policy");
              },
              child: Text(' Privacy Policy.',
                  style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        CustomButton(
          color: Color(0XFF00FFB0),
          minimumWidth: 230,
          // disabledColor: Style.AccentBlue.withOpacity(0.3),
          onPressed: onSignUpButtonClick,
          radius: 10,
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
                      color: Style.AccentBrown,
                      fontSize: 20,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  signUp() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        error = "Enter Email Address";
      });
    } else if (_passwordController.text.isEmpty) {
      setState(() {
        error = "Enter Password";
      });
    } else {
      setState(() {
        loading = true;
        error = "";
      });
    }

    if (_formKey.currentState.validate()) {
      _register();
    }
  }
}
