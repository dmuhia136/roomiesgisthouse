import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gisthouse/services/database.dart';

class ScreenHolder extends StatefulWidget{
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;
  final Widget body;
  final Color color;
  final FloatingActionButton floatingActionButton;

  const ScreenHolder(
      {Key key,
        @required this.scaffoldKey,
        @required this.color,
        this.title,
        @required this.body,
        this.floatingActionButton})
      : super(key: key);

  @override
  ScreenHolderState createState() => ScreenHolderState();
}

class ScreenHolderState extends State<ScreenHolder> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  bool isTimerRunning = false;

  startTimeout([int milliseconds]) {
    isTimerRunning = true;
    Timer.periodic(new Duration(seconds: 2), (time) {
      isTimerRunning = false;
      time.cancel();
    });

  }


  void _showAppExitWarning(BuildContext context) {

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Are you sure you want to Exit'),
          content: Text("If you leave the app, you'll be removed from all your rooms"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false), // passing false
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext, true);
                //leave any existing room
                 await Database().leaveActiveRoom();
                 exit(0);
                }, // passing true
              child: Text('Yes'),
            ),
          ],
        );
      }
    );
  }

  Future<bool> _willPopCallback() async {

    if (!Navigator.canPop(context)) {
      if (!isTimerRunning) {
        startTimeout();
        _showAppExitWarning(context);
        return false;
      } else
        return true;
    } else {
      isTimerRunning = false;
      return true;
    }
  }


  @override
  didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        await Database().leaveActiveRoom();
        break;
      case AppLifecycleState.resumed:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.paused:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          backgroundColor: widget.color,
          body: widget.body,
      ),
      onWillPop: _willPopCallback,
    );
  }
}