import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:http/io_client.dart';

class Wallet {
  static depositGistCoins(
      {String amount, String email, String password}) async {
    try {
      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = new IOClient(ioc);
      var url = Uri.parse(
          '$gistcoindeposit?reference=${DateTime.now().millisecondsSinceEpoch}&userId=${Get.find<UserController>().user.uid}&merchantId=$merchantId&publicKey=$publicKey&amount=$amount&email=$email&password=$password');
      final response = await http.post(
        url,
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load token');
      }
    } catch (e) {
    }
  }

  static depositInit(
      {String ref}) async {
    try {
      final ioc = new HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = new IOClient(ioc);
      var url = Uri.parse(
          '$depositfinalize?reference=$ref');
      final response = await http.post(
        url,
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load token');
      }
    } catch (e) {
    }
  }
}
