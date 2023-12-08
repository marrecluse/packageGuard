// ignore_for_file: dead_code

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Utils/app_constants.dart';
import 'package:packageguard/Views/Login/login.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../Utils/app_images.dart';
import '../../../Widgets/custom_text.dart';
import 'safe_circle_container.dart';

class SafeNotificationAlerts extends StatefulWidget {
  const SafeNotificationAlerts({super.key});

  @override
  State<SafeNotificationAlerts> createState() => _SafeNotificationAlertsState();
}

final userController = Get.find<UserController>();
Map<String, dynamic> userData = {};

class _SafeNotificationAlertsState extends State<SafeNotificationAlerts> {
  User? user;
  bool accept = false;
  final auth = FirebaseAuth.instance;
  DatabaseReference ref =
      FirebaseDatabase.instance.ref("packageGuard/deviceId1/data/alerts/");

  // final ref2 = FirebaseDatabase.instance.ref();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserAddress();
    fetchSafeCircleNotification();
    clearNotificationList();
  }

  List<Map<String, dynamic>> notificationList = [];
  bool isLoading = true;
  String? senderId;

  Future<void> updateAcceptStatus(bool acceptStatus) async {
    user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('status')
        .doc(user?.uid)
        .set({'accept': acceptStatus});
  }

  void clearNotificationList() {
    notificationList.clear();
  }

  Future<void> fetchUserAddress() async {
    final firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    try {
      final notificationCollection =
          firestore.collection('users').doc(user?.uid);

      final querySnapshot = await notificationCollection.get();
      print('The user address is   ${querySnapshot['Address']}');
    } catch (e) {
      print("Error fetching devices: $e");
      isLoading = false; // Set loading to false in case of an error
    }
  }

  Future<void> fetchSafeCircleNotification() async {
    final firestore = FirebaseFirestore.instance;
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
    print("Current user: ${user?.uid.toString()}");

    try {
      final notificationCollection = firestore
          .collection('notifications')
          .doc(user?.uid)
          .collection("safeCircleNotification")
          .where('userId', isEqualTo: user?.uid.toString());

      final querySnapshot = await notificationCollection.get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> filteredList = [];

        for (var document in querySnapshot.docs) {
          final notificationData = document.data() as Map<String, dynamic>;

          // Check if the "userId" matches your UID

          filteredList.add(notificationData);

          // print(filterednotification);
        }

        if (filteredList.isNotEmpty) {
          setState(() {
            notificationList.addAll(filteredList);
            isLoading = false;

            // Set loading to false in case of an error
            print("Notifications ; ${notificationList.toString()}");
          });
        } else {
          print("No devices found in Firestore.");
          isLoading = false; // Set loading to false in case of an error
        }
        //     } else {
        //       print("No devices found in Firestore for UID: $uid");
        //       isLoading = false; // Set loading to false in case of an error
      }
    } catch (e) {
      print("Error fetching devices: $e");
      isLoading = false; // Set loading to false in case of an error
    }
  }

  bool isAlarmActive = false; // Initialize with a default value

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('hello world'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              5.heightBox,
              StreamBuilder(
                  stream: ref.onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    } else {
                      Map<dynamic, dynamic> map =
                          snapshot.data!.snapshot.value as dynamic;
                      List list = map.keys.toList();
                      // print('the value of the $list is');

                      // Map deviceIds = map["deviceId1"];

                      // Map deviceData = deviceIds['data'];
                      // print('here the battery is ${deviceData['battery']}');

                      // Map data = deviceData['alerts'] is Map
                      //     ? deviceData['alerts']
                      //     : {};

                      // print('the value of the map is ${data['armedStatus']}');

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (context, index) {},
                      );
                    }
                  }),

              // StreamBuilder(
              //   stream: ref.onValue,
              //   builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              //     if (!snapshot.hasData) {
              //       return Center(child: LinearProgressIndicator());
              //     } else {
              //       Map<dynamic, dynamic> map =
              //           snapshot.data!.snapshot.value as dynamic;
              //       List<dynamic> list = map.values.toList();
              //       print("Data from Snapshot: $map");
              //       return ListView.builder(
              //         shrinkWrap: true,
              //         itemCount: snapshot.data!.snapshot.children.length,
              //         itemBuilder: (context, index) {
              //           // Assuming "package_guard_info" is a child node of the current device
              //           Map<dynamic, dynamic> packageGuardInfo =
              //               list[index]['SN83C048DF9D4'] ?? {};
              //           // Assuming "armed_status" is a boolean attribute
              //           bool armedStatus =
              //               packageGuardInfo['armed_status'] ?? false;

              //           return armedStatus
              //               ? Container()
              //               : SafeCircleContainer(
              //                   titleText: 'ALERT RESOLUTION',
              //                   subTitleText:
              //                       'Thank you. The package alarm has been silenced at:',
              //                   leadingImg: AppImages.checkMark,
              //                   containerColor: const Color(0xff8DC588),
              //                   titleColor: const Color(0xff009045),
              //                 );
              //         },
              //       );
              //     }
              //   },
              // ),
              // StreamBuilder(
              //   stream: ref.onValue,
              //   builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              //     if (!snapshot.hasData) {
              //       return Center();
              //     } else {
              //       Map<dynamic, dynamic> map =
              //           snapshot.data!.snapshot.value as dynamic;
              //       List<dynamic> list = map.values.toList();
              //       print("Data from Snapshot: $map");
              //       return ListView.builder(
              //         shrinkWrap: true,
              //         itemCount: snapshot.data!.snapshot.children.length,
              //         itemBuilder: (context, index) {
              //           // Assuming "package_guard_info" is a child node of the current device
              //           Map<dynamic, dynamic> packageGuardInfo =
              //               list[index]['package_guard_info'] ?? {};
              //           // Assuming "armed_status" is a boolean attribute
              //           bool armedStatus =
              //               packageGuardInfo['armed_status'] ?? false;

              //           return armedStatus
              //               ? Container()
              //               : SafeCircleContainer(
              //                   titleText: 'PACKAGE THEFT ALERT',
              //                   subTitleText:
              //                       'A package is being retrieved without authorization at:',
              //                   leadingImg: AppImages.redIcon,
              //                   containerColor: const Color(0xffC58888),
              //                   titleColor: const Color(0xffCE3333),
              //                 );
              //         },
              //       );
              //     }
              //   },
              // ),

              SizedBox(
                // height: 200.h,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: notificationList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      height: context.screenWidth * .22,
                      margin: EdgeInsets.only(top: 5.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9.r),
                        color: const Color(0xffD7E1EC),
                      ),
                      child: Row(
                        children: [
                          Image.asset(AppImages.checkMark),
                          SizedBox(width: 20.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: context.screenWidth * .6,
                                child: CustomText(
                                  // title:'You have been added to Benjamin’s Safe\nCircle for Package Protection',
                                  title: notificationList[index]
                                      ['notification'],
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                height: 25,
                                width: 80,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Color(
                                          0xff3FCE33) // Set your desired background color here
                                      ),
                                  onPressed: () async {
                                    accept = true;
                                    updateAcceptStatus(accept);
                                  },
                                  child: Text(
                                    'Accept',
                                  ),
                                ),
                                //   child: CustomButton(
                                //       btnText: 'Accept',
                                //       onPressed: () {},
                                //       btnColor: Color(0xff3FCE33)),
                                //
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              // // CustomButton(
              //   btnText: 'Go to Safe Circle Notification',
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => SafeCircleNotification(),
              //       ),
              //     );
              //   },
              //   btnColor: AppColors.appBlueColor,
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

// @override
// Widget build(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 15),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [

//         // SafeCircleContainer(
//         //   titleText:  'PACKAGE THEFT ALERT',
//         //   subTitleText:
//         //       'A package is being retrieved without authorization at:',
//         //   leadingImg: AppImages.redIcon,
//         //   containerColor: const Color(0xffC58888),
//         //   titleColor: const Color(0xffCE3333),
//         // ),

//         // SafeCircleContainer(
//         //   titleText: 'ALERT RESOLUTION',
//         //   subTitleText: 'Thank you. The package alarm has been silenced at:',
//         //   leadingImg: AppImages.checkMark,
//         //   containerColor: const Color(0xff8DC588),
//         //   titleColor: const Color(0xff009045),
//         // ),

//           Container(
//             height: 73,
//             margin: EdgeInsets.only(top: 5.h),
//             padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(9.r),
//               color: const Color(0xffD7E1EC),
//             ),
//             child: Row(
//               children: [
//                 Image.asset(AppImages.checkMark),
//                 SizedBox(width: 20.w),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomText(
//                       title:'You have been added to Benjamin’s Safe\nCircle for Package Protection',
//                       // title: notificationList[index]['notification'],
//                       fontSize: 10.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                     ),
//                     SizedBox(height: 5.h),
//                     // Container(
//                     //   height: 20,
//                     //   width: 73,
//                     //   child: CustomButton(
//                     //       btnText: 'Accept',
//                     //       onPressed: () {},
//                     //       btnColor: Color(0xff3FCE33)),
//                     // )
//                   ],
//                 )
//               ],
//             ),
//           ),
//       ]
//     ),
//   );
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 15),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SafeCircleContainer(
//           titleText: 'PACKAGE THEFT ALERT',
//           subTitleText:
//               'A package is being retrieved without authorization at:',
//           leadingImg: AppImages.redIcon,
//           containerColor: const Color(0xffC58888),
//           titleColor: const Color(0xffCE3333),
//         ),
//         SafeCircleContainer(
//           titleText: 'ALERT RESOLUTION',
//           subTitleText: 'Thank you. The package alarm has been silenced at:',
//           leadingImg: AppImages.checkMark,
//           containerColor: const Color(0xff8DC588),
//           titleColor: const Color(0xff009045),
//         ),

//         Container(
//           height: 73,
//           margin: EdgeInsets.only(top: 5.h),
//           padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(9.r),
//             color: const Color(0xffD7E1EC),
//           ),
//           child: Row(
//             children: [
//               Image.asset(AppImages.checkMark),
//               SizedBox(width: 20.w),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CustomText(
//                     title:
//                         'You have been added to Benjamin’s Safe\nCircle for Package Protection',
//                     fontSize: 10.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black,
//                   ),
//                   SizedBox(height: 5.h),
//                   // Container(
//                   //   height: 20,
//                   //   width: 73,
//                   //   child: CustomButton(
//                   //       btnText: 'Accept',
//                   //       onPressed: () {},
//                   //       btnColor: Color(0xff3FCE33)),
//                   // )
//                 ],
//               )
//             ],
//           ),
//         )
//       ],
//     ),
//   );
// }
