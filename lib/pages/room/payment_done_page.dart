import 'package:flutter/material.dart';
import 'package:gisthouse/widgets/widgets.dart';

class PaymentDonePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Completed", style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Spacer(flex: 4),
            Icon(Icons.thumb_up, size: 80, color: Colors.amber,),
            Spacer(),
            Text(
              "Ticked bought successfuly",
              style: theme.textTheme.subtitle1,
            ),
            SizedBox(height: 16),
            Text("you can now join the room", style: theme.textTheme.caption),
            Spacer(flex: 4),
            CustomButton(
              text: "Join Room Now",
              onPressed: () => Navigator.pop(context),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
