import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gisthouse/models/models.dart';
import 'dart:math';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:gisthouse/pages/room/payment_done_page.dart';

import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/widgets.dart';

import 'more_container.dart';

class ConfirmPaymentPage extends StatefulWidget {
  final Room room;
  ConfirmPaymentPage({this.room});

  @override
  _ConfirmPaymentPageState createState() => _ConfirmPaymentPageState();
}

class _ConfirmPaymentPageState extends State<ConfirmPaymentPage> {
  bool showMoreContainer = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment".toUpperCase(), style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Spacer(),
              buildColumn(
                theme,
                "Wallet ${widget.room.currency =="\$" ? "Fiat " : "GistCoin "}Balance",
                t2: "${widget.room.currency} 58.00",
                fontsize: 20,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              Spacer(flex: 2),
              CustomButton(
                text: "Depost",
                color: Colors.green,
                onPressed: () => Get.to(() => PaymentDonePage()),
              ),
              Expanded(
                  flex: 5,
                  child: Image.asset(Assets.wallet, scale: 2.8)),
              Spacer(),
              Text("Confirm Ticket Purchase", style: theme.textTheme.subtitle1),
              Spacer(flex: 2),
              FadedSlideAnimation(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.room.title,
                        style: theme.textTheme.subtitle1,
                      ),
                      SizedBox(height: 4),
                      CategoryRow(category: widget.room.clubListNames,color:Style.indigo,ids: widget.room.clubListNames,),
                      SizedBox(height: 30),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildColumn(
                            theme,
                            "Total ${widget.room.currency == "\$" ? "Amount" : widget.room.currency} to pay",
                            fontsize: 18,
                            t2: "${widget.room.currency}9.00",
                          ),
                          CustomButton(
                            text: "Pay Via",
                            disabledColor: Colors.grey,
                            color: Colors.green,
                            onPressed: (){
                              setState(() {
                                  showMoreContainer = !showMoreContainer;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [

                        ],
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
                beginOffset: Offset(0.0, 0.2),
                endOffset: Offset.zero,
              ),
            ],
          ),

          if (showMoreContainer)
            Align(
              alignment: Alignment.bottomCenter,
              child: MoreContainer(),
            ),
        ],
      ),
    );
  }

  Column buildColumn(
    ThemeData theme,
    String t1, {
    String t2,
    IconData icon,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
        double fontsize
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(t1, style: TextStyle(fontSize: fontsize)),
        SizedBox(height: 4),
        if (t2 != null) Text(t2, style: TextStyle(fontSize: fontsize)),
        if (icon != null)
          Transform.rotate(
            angle: -pi / 8,
            child: Icon(
              icon,
              color: theme.primaryColor,
            ),
          ),
      ],
    );
  }
}
