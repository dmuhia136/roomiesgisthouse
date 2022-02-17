import 'package:gisthouse/services/database_api/util/db_base.dart';
import 'package:gisthouse/services/database_api/util/db_utils.dart';

class TransactionApi {

  getUserTransactions(String id) async {

    return await DbBase().databaseRequest(TRANSACTIONS_FOR_USER + id, DbBase().getRequestType);

  }

  saveTransaction(Map<String, dynamic> data) async {
    try{
      await DbBase().databaseRequest(SAVE_TRANSACTIONS, DbBase().postRequestType, body: data);

    } catch(e) {
    }
  }

}