import 'package:get/get.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/models/room_user.dart';
/*
  type : Class
  packages used: Getx
  function: this is the controller class that listens to room object changes
 */
class CurrentRoomController extends GetxController {
  Rx<Room> _room = Rx<Room>();

  Room get room => _room.value;

  set room(Room room) => this._room.value = room;

  String get roomid => _room.value.roomid;

  Rx<List<RoomUser>> _users = Rx<List<RoomUser>>();

  set roomusers(List<RoomUser> roomusers) => this._users.value = roomusers;

  List<RoomUser> get roomusers => _users.value;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // if(_room.value !=null){
    //   users.bindStream(Database.getroomUsers(roomid));
    // }

  }


}