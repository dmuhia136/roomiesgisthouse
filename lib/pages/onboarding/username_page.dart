import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/widgets/round_button.dart';
import 'package:gisthouse/util/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/widgets/widgets.dart';

import 'pick_photo_page.dart';

class UsernamePage extends StatefulWidget {
  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final _userNameController = TextEditingController();
  final _userNameformKey = GlobalKey<FormState>();
  bool loading = false;
  Function onNextButtonClick;

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
        backgroundColor: Style.themeColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          toolbarHeight: 30.0,
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          child: Column(
            children: [
              buildTitle(),
              SizedBox(
                height: 40,
              ),
              buildForm(),
              Spacer(),
              buildBottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      'Pick a username',
      style: TextStyle(
        fontSize: 28,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        letterSpacing: 0.5

      ),
    );
  }
  String toSpaceSeparatedString(String s) {
    const n = 4;
    assert(s.length % n == 0);
    var i = s.length - n;
    while (i > 0) {
      s = s.replaceRange(i, i, ' ');
      i -= n;
    }
    return s;
  }

  Widget buildForm() {
    return Container(
      width: 330,
      padding: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: _userNameformKey,
        child: TextFormField(
          textAlign: TextAlign.center,
          onChanged: (value) {
            _userNameformKey.currentState.validate();
          },
          validator: (value) {
            if (value.isEmpty) {
              setState(() {
                onNextButtonClick = null;
              });
            } else {
              setState(() {
                onNextButtonClick = next;
              });
            }
            return null;
          },
          controller: _userNameController,
          autocorrect: false,
          autofocus: false,
          decoration: InputDecoration(
            hintText: '@username',
            hintStyle: TextStyle(
              fontSize: 20,
                color: Colors.black
            ),
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
    );
  }

  Widget buildBottom() {
    return loading == true ? Center(
      child: CircularProgressIndicator(),
    ) : CustomButton(
      color: Style.Blue,
      minimumWidth: 230,
      disabledColor: Style.Blue.withOpacity(0.3),
      onPressed: onNextButtonClick,
      child: Container(
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
    );
  }

  next() {
    setState(() {
      loading = true;
    });
    Database.checkUsername(_userNameController.text).then((value){
      if(value == 0){
        setState(() {
          onNextButtonClick = next;
          Get.find<OnboardingController>().username = _userNameController.text;
          Get.to(() => PickPhotoPage());
        });
      }else{
        topTrayPopup("Username is already taken");
      }

      setState(() {
        loading = false;
      });
    });

  }
}
