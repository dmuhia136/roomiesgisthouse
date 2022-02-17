import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:gisthouse/widgets/frosted_container.dart';
import 'package:gisthouse/widgets/widgets.dart';

class MoreContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 100),
      child: FadedScaleAnimation(
        child: FrostedContainer(
          borderRadius: BorderRadius.circular(20),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextTile(
                "Wallet Balance",
                onTap: (){},
              ),
              SizedBox(height: 16),
              TextTile(
                "GistCoin",
                onTap: () {},
              ),
              SizedBox(height: 16),
              TextTile(
                "PayPal",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
