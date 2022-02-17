
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

//firesore references
final _firestore =  FirebaseFirestore.instance;
final chatsRef = _firestore.collection('chats');
final messagenotificationsRef = _firestore.collection('messagenotifications');
final usersRef = _firestore.collection('users');
final roomsRef = _firestore.collection('rooms');
final clubRef = _firestore.collection('clubs');
final interestsRef = _firestore.collection('interests');
final settingsRef = _firestore.collection('settings');

//firebase initialize storage
final storageRef = FirebaseStorage.instance.ref();
//firebase initialize message
FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//firebase initialize notification topics
String all = "all";
String roomtopic = "roomtopic";
String trendingtopic = "trendingtopic";
String otherstopic = "otherstopic";

