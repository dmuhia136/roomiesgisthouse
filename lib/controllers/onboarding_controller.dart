import 'dart:io';

import 'package:gisthouse/models/models.dart';
import 'package:get/get.dart';
/*
  type : Class
  packages used: Getx
  function: this is the controller class that listens to user object changes when user is registering
 */
class OnboardingController extends GetxController{
  Rx<UserModel> _user = UserModel().obs;
  UserModel get onboardingUser => _user.value;
  set onboardata(UserModel value) => this._user.value = value;
  RxBool loading = false.obs;

  set imageurl(String value) => this._user.value.smallimage = value;
  set imageFile(File value) => this._user.value.imagefile = value;
  set firstname(String value) => this._user.value.firstname = value;
  set lastname(String value) => this._user.value.lastname = value;
  set username(String value) => this._user.value.username = value;
  set phonenumber(String value) => this._user.value.phonenumber = value;
  set referrerid(String value) => this._user.value.referrerid = value;
}