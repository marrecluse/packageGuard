// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
 
 
//  class PushNotify extends StatefulWidget {
//   const PushNotify({super.key});

//   @override
//   State<PushNotify> createState() => _PushNotifyState();
// }

// class _PushNotifyState extends State<PushNotify> {
//  String? mtoken='';
//  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin= FlutterLocalNotificationsPlugin();
//   TextEditingController username = TextEditingController();
//   TextEditingController title = TextEditingController();
//   TextEditingController body = TextEditingController();

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     requestPermission();
//     getToken();
//     //initInfo();

//   }

// void getToken() async{
//   await FirebaseMessaging.instance.getToken().then((token){
//     setState(() {
//       mtoken= token;
//       print('My token: $mtoken');
//     });
//     saveToken(token);
//   });
// }

// void saveToken(String? token) async{
//   await FirebaseFirestore.instance.collection("UserTokens").doc("User2").set({
//     'token':token,
//   });
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



//  initInfo() {
//   var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher');
//   var initializationSettings = InitializationSettings(android: androidInitialize);
//   flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onSelectNotification : (String? payload) async {
//        try{
//         if(payload!=null&& payload.isNotEmpty){
          
//         }else{

//         }
//        }
//        catch(e){
//           return;
//        }
//     }
//   );
//   FirebaseMessaging.onMessage.listen(RemoteMessage message) async{
// print("onMessage");
// print("onMessage:${message.notification?.title}/${message.notification?.body}");
// BigTextStyleInformation bigTextStyleInformation=BigTextStyleInformation(
// message.notification!.body.toString(),htmlFormatContentTitle: true
// );
// AndroidNotificationDetails androidPlatformChannelSpecific=AndroidNotificationDetails('dbfood','dbfood',importance: Importance.max,
// styleInformation: bigTextStyleInformation,priority: Priority.max,playSound: false
// );

// NotificationDetails plateformChannelSpacefic=NotificationDetails(android:androidPlatformChannelSpecific);
// await flutterLocalNotificationsPlugin.show(0, message.notification?.title, message.notification?.body,plateformChannelSpacefic,payload: message.data['title']);

//   }
// }







//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             TextFormField(
//               controller: username,
//             ), TextFormField(
//               controller: title,
//             ), TextFormField(
//               controller: body,
//             ),

//             Container(
//               margin: const EdgeInsets.all(20),
//               height: 40,
//               width: 200,

//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.red,
//                   )
//                 ]
//               ),
//               child: const Center(child: Text("Button"),
//               ),


//             ),

//           ],
//         ),
//       ),
//     );
//   }
// }