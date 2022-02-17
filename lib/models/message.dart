
import 'package:flutter_chat_types/flutter_chat_types.dart' as User;

class MessageItem{

  User.User author;

  // {
  // "author": {
  // "firstName": "John",
  // "id": "b4878b96-efbc-479a-8291-474ef323dec7",
  // "imageUrl": "https://avatars.githubusercontent.com/u/14123304?v=4"
  // },
  // "createdAt": 1598438797000,
  // "id": "e7a673e9-86eb-4572-936f-2882b0183cdc",
  // "status": "seen",
  // "text": "https://flyer.chat",
  // "type": "text"
  // },


  // factory MessageItem.fromJson(DocumentSnapshot json) {
  //   return MessageItem(
  //     chatid: json.id,
  //     lastmessage: json.data()["lastmessage"],
  //     timestamp: json.data()["creationTimestamp"],
  //     users: getChatUsers(List<String>.from(json.data()["users"].map((item) => item))),//_chatUserFromFirebaase(List<ChatUser>.from(e.data()["users"].map((item) => item)))
  //   );
  // }

}