// import 'dart:html';

import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/round_button.dart';
import 'package:gisthouse/util/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'username_page.dart';

class FullNamePage extends StatefulWidget {
  @override
  _FullNamePageState createState() => _FullNamePageState();
}

class _FullNamePageState extends State<FullNamePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameFormKey = GlobalKey<FormState>();
  final _lastNameFormKey = GlobalKey<FormState>();
  Function onNextButtonClick;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Get.put(OnboardingController());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage("assets/images/bg.png",),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Scaffold(
        backgroundColor: Style.themeColor,
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only( bottom: 20),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: buildTitle(),
                  ),
                  SizedBox(
                    height: 70,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                    ),
                    child: buildForm(),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: buildDescription(),
                  ),

                   Spacer(),

                  buildBottom(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// top part builder
  Widget buildTitle() {
    return Text(
      'What\'s your full name?',
      style: TextStyle(
        fontSize: 25,
        color: Colors.black,
      ),
    );
  }

//  form builder
  Widget buildForm() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Form(
              key: _firstNameFormKey,
              child: TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  _firstNameFormKey.currentState.validate();
                },
                validator: (value) {
                  if (value.isNotEmpty) {
                    if (_lastNameController.text.isNotEmpty) {
                      setState(() {
                        onNextButtonClick = next;
                      });
                    }
                  } else {
                    setState(() {
                      onNextButtonClick = null;
                    });
                  }

                  return null;
                },
                controller: _firstNameController,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'First',
                  hintStyle: TextStyle(fontSize: 20, color: Style.BlackFade),
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
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Form(
              key: _lastNameFormKey,
              child: TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  _lastNameFormKey.currentState.validate();
                },
                validator: (value) {
                  if (value.isNotEmpty) {
                    if (_firstNameController.text.isNotEmpty) {
                      setState(() {
                        onNextButtonClick = next;
                      });
                    }
                  } else {
                    setState(() {
                      onNextButtonClick = null;
                    });
                  }

                  return null;
                },
                controller: _lastNameController,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Last',
                  hintStyle: TextStyle(fontSize: 20, color: Style.BlackFade),
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
          ),
        )
      ],
    );
  }

// description builder
  Widget buildDescription() {
    return Text(
      "People use their real names on GistHouse",
      style: TextStyle(color: Style.BlackFade, fontSize: 15.0),
    );
  }

// button builder
  Widget buildBottom() {
    return CustomButton(
      color: Style.Blue,
      minimumWidth: 230,
      disabledColor: Style.Blue.withOpacity(0.3),
      onPressed: onNextButtonClick,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Icon(
                Icons.arrow_right_alt,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  next() {
    Get.find<OnboardingController>().firstname = _firstNameController.text;
    Get.find<OnboardingController>().lastname = _lastNameController.text;
    Get.to(() => UsernamePage());
  }
}
