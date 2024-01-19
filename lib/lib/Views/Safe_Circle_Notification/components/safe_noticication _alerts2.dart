// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:packageguard/Utils/app_images.dart';
// import 'package:packageguard/Views/Login/login.dart';
// import 'package:packageguard/Widgets/custom_text.dart';
// import 'package:velocity_x/velocity_x.dart';

// class SafeNOtificationsAlerts2 extends StatefulWidget {
//   const SafeNOtificationsAlerts2({super.key});

//   @override
//   State<SafeNOtificationsAlerts2> createState() =>
//       _SafeNOtificationsAlerts2State();
// }

// class _SafeNOtificationsAlerts2State extends State<SafeNOtificationsAlerts2> {
//   final userController = Get.find<UserController>();
//   Map<String, dynamic> userData = {};
//   User? user;
//   bool accept = false;
//   bool isAlarmActive = false;
//   final auth = FirebaseAuth.instance;
//   final ref = FirebaseDatabase.instance.ref('packageGuard/userId1/devices/');

//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     fetchSafeCircleNotification();
//     clearNotificationList();
//   }

//   List<Map<String, dynamic>> notificationList = [];
//   bool isLoading = true;
//   String? senderId;
//   Future<void> updateAcceptStatus(
//       bool acceptStatus, String notificationTitle) async {
//     user = FirebaseAuth.instance.currentUser;
//     await FirebaseFirestore.instance
//         .collection('safeCircle')
//         .doc('Ag1O02cdXwgF8DEehiuXfkdXHbq1')
//         .collection('circlePersons')
//         .doc('f3bnEz3b43ctJQyFCta417hTu7P2')
//         .update({'acceptStatus': acceptStatus});
//   }

//   void clearNotificationList() {
//     notificationList.clear();
//   }

//   Future<void> fetchSafeCircleNotification() async {
//     final firestore = FirebaseFirestore.instance;
//     setState(() {
//       user = FirebaseAuth.instance.currentUser;
//     });
//     print("Current user: ${user?.uid.toString()}");

//     try {
//       final notificationCollection = firestore
//           .collection('notifications')
//           .doc(user?.uid)
//           .collection("safeCircleNotification")
//           .where('userId', isEqualTo: user?.uid.toString());

//       final querySnapshot = await notificationCollection.get();
//       if (querySnapshot.docs.isNotEmpty) {
//         List<Map<String, dynamic>> filteredList = [];

//         for (var document in querySnapshot.docs) {
//           final notificationData = document.data() as Map<String, dynamic>;

//           // Check if the "userId" matches your UID

//           filteredList.add(notificationData);

//           // print(filterednotification);
//         }

//         if (filteredList.isNotEmpty) {
//           setState(() {
//             notificationList.addAll(filteredList);
//             isLoading = false;

//             // Set loading to false in case of an error
//             print("Notifications ; ${notificationList.toString()}");
//           });
//         } else {
//           print("No devices found in Firestore.");
//           isLoading = false; // Set loading to false in case of an error
//         }
//         //     } else {
//         //       print("No devices found in Firestore for UID: $uid");
//         //       isLoading = false; // Set loading to false in case of an error
//       }
//     } catch (e) {
//       print("Error fetching devices: $e");
//       isLoading = false; // Set loading to false in case of an error
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text("Hiiiiiiiiiiii"),
//           // StreamBuilder(
//           //     stream: ref.onValue,
//           //     builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//           //       if (!snapshot.hasData) {
//           //         return Container();
//           //       } else {
//           //         Map<dynamic, dynamic> map =
//           //             snapshot.data!.snapshot.value as dynamic;
//           //         List list = map.keys.toList();
//           //         // print('the value of the $list is');

//           //         Map deviceIds = map["deviceId1"];

//           //         Map deviceData = deviceIds['data'];
//           //         // Map data = deviceData['alerts'];

//           //         Map data =
//           //             deviceData['alerts'] is Map ? deviceData['alerts'] : {};
//           //         print('the data is $data');
//           //         return ListView.builder(
//           //           shrinkWrap: true,
//           //           itemCount: list.length,
//           //           itemBuilder: (context, index) {
//           //             return ListTile(
//           //               title: Text('the alarm status is ${data['alarm']}'),
//           //             );
//           //           },
//           //         );
//           //       }
//           //     }),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: ListView.builder(
//               physics: const BouncingScrollPhysics(),
//               itemCount: notificationList.length,
//               // itemCount: 5,
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 String notificationTitle =
//                     notificationList[index]['notification'];
//                 return Container(
//                   height: context.screenWidth * .30,
//                   margin: EdgeInsets.only(top: 5.h),
//                   padding:
//                       EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(9.r),
//                     color: const Color(0xffD7E1EC),
//                   ),
//                   child: Row(
//                     children: [
//                       Image.asset(AppImages.checkMark),
//                       SizedBox(width: 20.w),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             width: context.screenWidth * .6,
//                             child: CustomText(
//                               // title:'You have been added to Benjamin’s Safe\nCircle for Package Protection',
//                               title: notificationTitle,
//                               fontSize: 10.sp,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black,
//                             ),
//                           ),
//                           SizedBox(height: 10.h),
//                           Row(
//                             children: [
//                               Container(
//                                 height: context.screenWidth * 0.1,
//                                 width: context.screenWidth * 0.19,
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       primary: Color(
//                                           0xff3FCE33) // Set your desired background color here
//                                       ),
//                                   onPressed: () async {
//                                     setState(() {
//                                       accept = true;
//                                     });
//                                     updateAcceptStatus(
//                                         accept, notificationTitle);
//                                   },
//                                   child: Text(
//                                     'Accept',
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: context.screenWidth * 0.05,
//                                 height: context.screenWidth * 0.05,
//                               ),
//                               Container(
//                                 height: context.screenWidth * 0.08,
//                                 width: context.screenWidth * 0.19,
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       primary: Colors
//                                           .red // Set your desired background color here
//                                       ),
//                                   onPressed: () async {
//                                     accept = false;
//                                     print("updating status");
//                                     updateAcceptStatus(
//                                         accept, notificationTitle);
//                                   },
//                                   child: Text(
//                                     'Reject',
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
