import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:gisthouse/models/InboxItem.dart';
import 'package:gisthouse/models/models.dart';
import 'package:gisthouse/pages/chats/chat_screen.dart';
import 'package:gisthouse/pages/home/follower_page.dart';
import 'package:gisthouse/pages/home/home_page.dart';
import 'package:gisthouse/pages/onboarding/email_verification.dart';
import 'package:gisthouse/pages/onboarding/sms_screen.dart';
import 'package:gisthouse/pages/profiles/user_profile_page.dart';
import 'package:gisthouse/pages/room/lounge_screen.dart';
import 'package:gisthouse/pages/upcomingrooms/upcoming_roomsreen.dart';
import 'package:gisthouse/services/authenticate.dart';
import 'package:gisthouse/services/database.dart';
import 'package:gisthouse/services/dynamic_link_service.dart';
import 'package:gisthouse/util/configs.dart';
import 'package:gisthouse/util/firebase_refs.dart';
import 'package:gisthouse/util/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bindings.dart';
import 'controllers/controllers.dart';
import 'pages/clubs/view_club.dart';

final navigatorKey = GlobalKey<NavigatorState>();

AndroidNotificationChannel channel;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// To verify things are working, check out the native platform logs.
_firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await redirectToRooms(message.data);
}

Future<void> handleNotification(RemoteMessage message) async {
  if (message.data['screen'] == "invitedasspeaker") {
    // displaysnackbacks(message);
  } else {
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    if (notification != null && android != null) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: '@mipmap/ic_launcher',
              ),
            ),
            payload: message.data['screen'] +
                " " +
                message.data['id'] +
                " " +
                (message.data['paidroom'] != null
                    ? message.data['paidroom']
                    : "")
        );
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance.getInitialMessage();
  fireNotiInit();
  notificationDefaultSettings();
  runApp(MyApp());

  if (Platform.isAndroid) {
    // maybeStartFGS();
  } else if (Platform.isIOS) {
    // iOS-specific code
  }
  //
}

fireNotiInit() async {
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    // description
    importance: Importance.high,
  );
  var initializationSettingsAndroid =
      AndroidInitializationSettings('flutter_devs');
  var initializationSettingsIOs = IOSInitializationSettings();
  var initSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
  flutterLocalNotificationsPlugin.initialize(initSettings,
      onSelectNotification: onSelectNotification);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

notificationDefaultSettings() async {
  RemoteMessage message = await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    await _firebaseMessagingBackgroundHandler(message);
  }

/*  FirebaseMessaging.instance
      .getInitialMessage().then((value) {
        if(value != null) {
         // Get.to(() => UpcomingRoom());
        }
  });*/

  FirebaseMessaging.onBackgroundMessage(handleNotification);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {

    handleNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleNotification(message);
    _firebaseMessagingBackgroundHandler(message);
  });
}

goToPageFromNotification(var payload) async {
  String screen;
  String id;
  bool paidroom = false;

  if (payload == null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var combinedString = prefs.getString("from_notification_class");
    var a = combinedString.split(" ");
    screen = a[0];
    id = a[1];
  } else {
    var a = payload.split(" ");
    screen = a[0];
    id = a[1];
    if (a.length > 2) {
      paidroom = a[2] == "false" ? false : true;
    }
  }
  var msg = {"screen": screen, "id": id, "paidroom": paidroom};
  await redirectToRooms(msg);
}

bool showloading = false;

Future redirectToRooms(Map<String, dynamic> mess) async {
  String screen = mess["screen"];
  String id = mess["id"];

  if (screen == 'ChatPage') {
    InboxItem item = await Database.getInboxItem(id);
    Get.to(() => ChatPage(item: item, chatusers: item.users,));
  } else if (screen == "ProfilePage") {
    UserModel userModel = await Database.getUserProfile(id);
    Get.to(() => ProfilePage(
          profile: userModel,
          fromRoom: false,
        ));
  } else if (screen == "ViewClub") {
    Club club = await Database().getClubByIdDetails(id);
    Get.to(() => ViewClub(club: club));
  } else if (screen == "RoomScreen") {
    showloading = true;
    joinexistingroom(
        roomid: id,
        currentUser: Get.find<UserController>().user,
        paidroom: mess["paidroom"] == "true" ? true : false,
        context: GlobalKey<ScaffoldState>().currentContext);
  }else if (screen == 'UpcomingRoomScreen') {
    Get.to(() => UpcomingRoomScreen());
  }
}

Future onSelectNotification(String payload) async {
  goToPageFromNotification(payload);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<DocumentSnapshot> streamSubscription;

  static const methodChannel = const MethodChannel('com.tarazgroup');

  _MyAppState() {
    methodChannel.setMethodCallHandler((call) {
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    handleStartUpLogic();
    getSettings();
  }

  Future handleStartUpLogic() async {
    // call handle dynamic links
    await DynamicLinkService().handleDynamicLinks();
  }
  @mustCallSuper
  @protected
  void dispose() {
    if (streamSubscription != null) {
      streamSubscription.cancel();
    }

    super.dispose();
  }

  getSettings() {
    settingsRef.get().then((value) {
      if (value != null && value.docs.length > 0) {
        APPROVE_ONLY = value.docs[0].data()["approve_only"];
        ACTIVE_ROOM_UPDATE = value.docs[0].data()["active_room_update_interval"];
        FORCE_MEMBERSHIP = value.docs[0].data()["force_membership"];
        USER_TRIAL_PERIOD = value.docs[0].data()["user_trial_period"];
        APP_ID = value.docs[0].data()["APP_ID"];
        TRIAL_DAYS = value.docs[0].data()["trial_days"];
        MAIN_CLUB_ID = value.docs[0].data()["main_club_id"];
        AWARD_COINS = value.docs[0].data()["award_coins"];
        PREMIUM_UPGRADE_COINS_AMOUNT =
            value.docs[0].data()["premium_upgrade_coins_amount"];
        if (AWARD_COINS == true) {
          SING_UP_COINS = value.docs[0].data()["sign_up_coins"];
        }
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'GistHouse',
      theme: ThemeData(
        scaffoldBackgroundColor: Style.themeColor,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        fontFamily: "RobotoRegular",
        appBarTheme: AppBarTheme(
          color: Style.black,
          textTheme: TextTheme(
            bodyText1: TextStyle(fontSize: 21, fontFamily: "InterBold"),
          ),
          elevation: 0.0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      initialBinding: AuthBinding(),
      home: AuthService().handleAuth(),
    );
  }

  bool isTimerRunning = false;

  startTimeout([int milliseconds]) {
    isTimerRunning = true;
    var timer = new Timer.periodic(new Duration(seconds: 2), (time) {
      isTimerRunning = false;
      time.cancel();
    });
  }

}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
}
