import 'package:get/get.dart';
import 'package:gisthouse/pages/onboarding/phone_number_page.dart';
import 'package:gisthouse/services/dynamic_link_service.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:gisthouse/widgets/round_button.dart';
import 'package:gisthouse/util/style.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Data.addInterests();
  }

  Future handleStartUpLogic() async {
    // call handle dynamic links
    await DynamicLinkService().handleDynamicLinks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      handleStartUpLogic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.themeColor,
      // appBar: AppBar(),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 1.7,
            width: double.infinity,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: buildTitle()),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 60),
                child: buildBottom(context)),
          ),
        ],
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      'Welcome to GistHouse!',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  // Widget buildContents() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Roomy hold professional, social and political talks with Roomy :)',
  //           style: TextStyle(
  //             height: 1.8,
  //             fontSize: 15,
  //           ),
  //         ),
  //         SizedBox(
  //           height: 40,
  //         ),
  //         Text(
  //           'Roomy doesnt discriminate, join anywhere you are, hold any kind of talk shows, invite your friends and much much more :)',
  //           style: TextStyle(
  //             height: 1.8,
  //             fontSize: 15,
  //           ),
  //         ),
  //         SizedBox(
  //           height: 40,
  //         ),
  //         Text(
  //           '🎙 Patrick, Reginah & the Roomy team',
  //           style: TextStyle(
  //             fontSize: 15,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget buildBottom(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Container(
        //   margin: EdgeInsets.only(bottom: 10),
        //   child: Align(
        //     alignment: Alignment.centerLeft,
        //     child: Text(
        //       'Get started with...',
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontSize: 14,
        //       ),
        //     ),
        //   ),
        // ),
        CustomButton(
          color: Style.Blue,
          radius: 50,
          txtcolor: Style.AccentBrown,
          onPressed: () {
            Get.to(() => PhoneScreen());
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🎉 Get Started',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Style.White,
                    fontSize: 20,
                  ),
                ),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
        // Container(
        //   margin: EdgeInsets.symmetric(vertical: 5),
        //   child: Text(
        //     'Or',
        //     style: TextStyle(
        //       color: Colors.white,
        //       fontSize: 14,
        //     ),
        //   ),
        // ),
        // CustomButton(
        //   color: Color(0XFF00FFB0),
        //   radius: 10,
        //   txtcolor: Style.AccentBrown,
        //   onPressed: () {
        //     Get.to(() => EmailPassword());
        //   },
        //   child: Container(
        //     padding: EdgeInsets.symmetric(vertical: 0),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.max,
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Text(
        //           'Email Address',
        //           style: TextStyle(
        //             color: Style.AccentBrown,
        //             fontSize: 20,
        //           ),
        //         )
        //       ],
        //     ),
        //   ),
        // ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
