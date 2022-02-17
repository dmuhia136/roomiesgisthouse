import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gisthouse/controllers/controllers.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/models/transaction.dart';
import 'package:gisthouse/services/database_api/transaction_api.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';

class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  UserModel myProfile = Get.put(UserController()).user;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Style.DarkBlue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20,),
            Text(
              "Recent transactions".toUpperCase(),
              style: theme.textTheme.caption.copyWith(color: Colors.white),
            ),
            Expanded(
              child: FutureBuilder(
                future: TransactionApi().getUserTransactions(myProfile.uid),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return loadingWidget(context);
                  }
                  if(snapshot.hasError){
                    return noDataWidget("Technical error happened");
                  }
                  List query = jsonDecode(snapshot.data);
                  query.sort((a, b) => b['date'].compareTo(a['date']));

                  return ListView.separated(
                    itemCount: query.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      Wtransaction transactions = Wtransaction.fromJson(query[index]);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: RichText(
                          text: TextSpan(
                            style: theme.textTheme.overline,
                            children: [
                              // TextSpan(text:transactions.reason),
                              TextSpan(
                                text: transactions.getDate(),
                                style: theme.textTheme.overline.copyWith(
                                  color: theme.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Text(
                          transactions.reason,
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          "${transactions.amount}",
                          style: theme.textTheme.subtitle1.copyWith(fontSize: 18, fontFamily: "InterBold")
                              .copyWith(color: transactions.type =="0" ? Colors.red : Colors.green),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: theme.scaffoldBackgroundColor,
                        thickness: 3,
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
