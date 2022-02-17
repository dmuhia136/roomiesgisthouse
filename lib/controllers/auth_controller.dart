import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/*
  type : Class
  packages used: Getx
  function: this is the controller class that listens to Authentication object changes
 */

class AuthController extends GetxController{
  Rx<User> _firebaseUser = Rx<User>();
  User get user => _firebaseUser.value;

}