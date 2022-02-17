import 'package:get/get.dart';
import 'package:gisthouse/models/models.dart';
/*
  type : Class
  packages used: Getx
  function: this is the controller class that listens to user object changes
 */
class SelectedUserController extends GetxController {
  Rx<List<UserModel>> _usersModel = Rx<List<UserModel>>([]);

  List<UserModel> get users => _usersModel.value;

  set user(List<UserModel> value) => this._usersModel.value = value;

  void change(UserModel user) => _usersModel.value.add(user);
}