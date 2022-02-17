import 'package:gisthouse/models/models.dart';

class RoomItem{
  final String image;
  final String text;
  final Club club;
  final String type;
  final String selectedMessage;
  String slogan;

  RoomItem({this.image,this.text,this.club,this.selectedMessage,this.slogan,this.type});

  factory RoomItem.fromJson(Map map) {
    return RoomItem(
        image: map['image'],
        text: map['text'],
        slogan: map['slogan'] ?? "",
        type: map['type'],
        club: map['club'],
        selectedMessage: map['selectedMessage'],
    );
  }
  List<RoomItem> lobbyBottomSheets = [];
  List<RoomItem> getItems(){
    Map map = {
      'image': 'assets/icons/public.png',
      'text': 'Public',
      'type': 'public',
      'club': null,
      'slogan': "",
      "location": false,
      'selectedMessage': 'Start a room open to everyone',
    };
    RoomItem roomItem = RoomItem.fromJson(map);
    lobbyBottomSheets.add(roomItem);
    Map map1 = {
      'image': 'assets/icons/sociale.png',
      'text': 'Social',
      'type': 'social',
      'slogan': "",
      'club': null,
      "location": false,
      'selectedMessage': 'Start a room with people I follow',
    };
    RoomItem roomItem1 = RoomItem.fromJson(map1);
    lobbyBottomSheets.add(roomItem1);


    Map map2 = {
      'image': 'assets/icons/private.png',
      'text': 'Private',
      'type': 'private',
      'club': null,
      'slogan': "",
      "location": false,
      'selectedMessage': 'Start a room for people I choose',
    };

    RoomItem roomItem2 = RoomItem.fromJson(map2);
    lobbyBottomSheets.add(roomItem2);

    Map map4 = {
      'image': 'assets/icons/paid.png',
      'text': 'Paid',
      'type': 'public',
      'slogan': "",
      'club': null,
      "location": false,
      'selectedMessage': 'Start a paid room',
    };
    RoomItem roomItem4 = RoomItem.fromJson(map4);
    lobbyBottomSheets.add(roomItem4);
    return lobbyBottomSheets;
  }
}