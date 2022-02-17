import 'package:get/get.dart';
import 'package:gisthouse/models/models.dart';
/*
  type : Class
  packages used: Getx
  function: this is the controller class that listens to user object changes
 */
class UserController extends GetxController {
  Rx<UserModel> _userModel = UserModel().obs;

  UserModel get user => _userModel.value;

  set user(UserModel value) => this._userModel.value = value;
  // set room(Room room) => this._userModel.value.activeRoom = room;
}