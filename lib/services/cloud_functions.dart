
import 'database_api/util/db_base.dart';
import 'database_api/util/db_utils.dart';

var _roomUserAnalytics = "https://us-central1-gisthouse-887e3.cloudfunctions.net/updateRoomStats";
var _checkuserVerification = "https://us-central1-gisthouse-887e3.cloudfunctions.net/checkUserVerification";


class CloudFunctions {


  roomUserAnalytics({String user,
    String roomid,
    String usertype,
    String action}) async {

    var body = {
      "userid": user,
      "roomid": roomid,
      "usertype" : usertype,
      "action" : action
    };
    var response = await DbBase().databaseRequest(UPDATE_ROOM_STATS, DbBase().postRequestType, body: body);

    return response;
  }


  checkUserverification(String userId, String phone) async {
    var body = {
      "uid" : userId,
      "phonenumber" : phone
    };
    var response = await DbBase().databaseRequest(USER_VERIFICATION, DbBase().postRequestType, body: body);

    return response.body;
  }

  sendMoney(String senderId, String receiverId, int amount) async {
    var body = {
      "senderId": senderId,
      "amount" : amount,
      "receiverId" : receiverId
    };
    var response = await DbBase().databaseRequest(SEND_MONEY, DbBase().postRequestType, body: body);


    return response.statusCode;
  }

  depositToClub(String senderId, String clubId, String amount) async {
    var body = {
      "senderId": senderId,
      "amount": double.parse(amount),
      "clubid": clubId
    };
    var response = await DbBase().databaseRequest(DEPOSIT_TO_CLUB, DbBase().postRequestType, body: body);


    return response.statusCode;
  }

  payForRoom(String userId, double amount, String roomId, String roomOwner) async {
    var body = {
      "uid" : userId,
      "amount" : amount,
      "roomId" : roomId,
      "roomOwner" : roomOwner
    };

    var response = await DbBase().databaseRequest(PAY_FOR_ROOM, DbBase().postRequestType, body: body);

    return response.statusCode;
  }

  upgradeToPremium(String userId, int amount) async {
    var body = {
      "uid" : userId,
      "amount" : amount,
    };
    var response = await DbBase().databaseRequest(UPGRADE, DbBase().postRequestType, body: body);

    return response.statusCode;
  }
}