 
// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;


// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//     print('Title: ${message.notification?.title}');
//     print('Body: ${message.notification?.body}');
//     print('Payload: ${message.data}');
// }

// class pushNotification{

//   void sendPushMessage(String userID, String title, String body) async{
//     final fCMToken=await _FirebaseMessaging.getToken();

// try {
//   await http.post(
//     Uri.parse('https://fcm.googleapis.com/fcm/send'),
//     headers: <String,String>{
//       'Content_Type':'application/json',
//       'Authorization': 'key=AAAA7uEFuE0:APA91bGrr2KX44UfRmYqbVpU5YCv7KIwJWi1cRxiq0dF7sMv2N5yT6paJTHXhdH9xUc7gd02Yhaa76TlsZmCLI1CQAxtBDkw2ylEKC6i6rPqdqaiy-OdJkFVhsYSShDmRfNXJ45pi8mq'

//     },
//     body: jsonEncode(
//       <String,dynamic>{
//         'priority':'high',
//         'data':<String,dynamic>{
//           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//           'status':'done',
//           'body':body,
//           'title':title,
//         },

//         "notification":<String,dynamic>{
//           "title":title,
//           "body":body,
//           "android_channel_id":"dbfood"
//         },
//         "to":'$fCMToken'

//       }
//     )
//   );


// } catch (e) {
//   print(e);
  
// }




//   }






//   final _FirebaseMessaging=FirebaseMessaging.instance;
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();

//   Future<void> initNotifications() async{
//     await _FirebaseMessaging.requestPermission();
//     final fCMToken=await _FirebaseMessaging.getToken();
//     print('Token: $fCMToken');
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//  await FirebaseFirestore.instance.collection("UserTokens").doc("User1").set({
//       'token': fCMToken
//     });

//   }



  
// }


// Future<void> requestPermission() async{
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true
//   );

//   if (settings.authorizationStatus == AuthorizationStatus.authorized){

//   print('User granted permission');
  
// } 
// else if (settings.authorizationStatus == AuthorizationStatus.provisional){
//       print('User granted provisional permission');

// }
// else{
//   print('User declined the permission');
// }


// }


