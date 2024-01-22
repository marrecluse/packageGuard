import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Views/Login/login.dart';
import 'package:packageguard/Views/Safe_Circle_Notification/components/safe_circle_container.dart';
import 'package:packageguard/Widgets/custom_text.dart';
import 'package:rxdart/rxdart.dart';
import 'package:velocity_x/velocity_x.dart';

class SafeNOtificationsAlerts2 extends StatefulWidget {
  const SafeNOtificationsAlerts2({super.key});

  @override
  State<SafeNOtificationsAlerts2> createState() =>
      _SafeNOtificationsAlerts2State();
}

class _SafeNOtificationsAlerts2State extends State<SafeNOtificationsAlerts2> {
  late Timer _timer;
  List<Map<String, dynamic>> safeCircleNotifications = [];

  final userController = Get.find<UserController>();
  Map<String, dynamic> userData = {};
  User? user;
  bool accept = false;
  bool isAlarmActive = false;
  String notificationTitle = '';
  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('packageGuard/userId1/devices/');

  void initState() {
    // TODO: implement initState
    super.initState();
    // Start the timer when the widget initializes

    fetchSafeCircleNotification();
    clearNotificationList();
  }

  List<Map<String, dynamic>> notificationList = [];
  bool isLoading = true;
  String? senderId;
  // Future<void> updateAcceptStatus(bool acceptStatus, String notificationTitle) async {
  // user = FirebaseAuth.instance.currentUser;
  // await FirebaseFirestore.instance
  //     .collection('status')
  //     .doc(user?.uid)
  //     .collection('notifications')
  //     .doc(notificationTitle)
  //     .set({'accept': acceptStatus});
  // }
  Future<String> getSenderId() async {
    user = FirebaseAuth.instance.currentUser;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .doc(user?.uid)
          .collection('safeCircleNotification')
          .where('notification', isEqualTo: notificationTitle)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print(
            'Sender id iss: ${querySnapshot.docs.first.get('senderId') as String}');
        return querySnapshot.docs.first.get('senderId') as String;
      }
    } catch (e) {}

    return '';
  }

  Future<void> deleteNotification(String notificationTitle, int index) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(user?.uid)
              .collection('safeCircleNotification')
              .where('notification', isEqualTo: notificationTitle)
              .get();

      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
      setState(() {
        notificationList.removeAt(index);
      });
    } catch (e) {
      print(e);
    }
  }

  Stream<List<Map<String, dynamic>>> streamNotifications() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String currentUser_uid = currentUser!.uid;
    print('uid: $currentUser_uid');
    Stream<List<Map<String, dynamic>>> theftAlertNotificationsStream =
        FirebaseFirestore.instance
            .collection('alerts')
            .doc(currentUser_uid)
            .collection('alertsLog')
            .where("alertType", isEqualTo: "ALARM_SCALEREMOVED")
            .snapshots()
            .map((querySnapshot) => _processSnapshots(querySnapshot));

    Stream<List<Map<String, dynamic>>> addRequestNotificationsStream =
        FirebaseFirestore.instance
            .collection('notifications')
            .doc(currentUser_uid)
            .collection('safeCircleNotification')
            .where('userId', isEqualTo: user?.uid.toString())
            .snapshots()
            .map((querySnapshot) => _processSnapshots(querySnapshot));

    return theftAlertNotificationsStream
        .mergeWith([addRequestNotificationsStream]);
  }

  List<Map<String, dynamic>> _processSnapshots(
      QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      safeCircleNotifications.add(doc.data());
    });

    // Sort notifications by timestamp if needed
    safeCircleNotifications
        .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    return safeCircleNotifications;
  }

  // Function to fetch user data based on device IDs
  Future<List<Map<String, dynamic>>> getUserData(List<String> deviceIds) async {
    List<Map<String, dynamic>> userDataList = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('devices', arrayContainsAny: deviceIds)
          .get();
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> userDetails = {
          'devices': List.from(doc['devices']),
          'Name': doc['Name'],
          'Address': doc['Address'],
        };
        userDataList.add(userDetails);
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }

    return userDataList;
  }

  Future<void> updateAcceptStatus(
      bool acceptStatus, String notificationTitle) async {
    user = FirebaseAuth.instance.currentUser;
    String senderId = await getSenderId();
    print("in update: $senderId");
    await FirebaseFirestore.instance
        .collection('safeCircle')
        .doc(senderId)
        .collection('circlePersons')
        .doc(user?.uid)
        .update({'acceptStatus': acceptStatus});
  }

  void clearNotificationList() {
    notificationList.clear();
  }

// Function to remove duplicates based on a specific field
  List<Map<String, dynamic>> removeDuplicates(
      List<Map<String, dynamic>> list, String fieldName) {
    List<Map<String, dynamic>> uniqueList = [];
    Set<String> uniqueIds = Set();

    for (var item in list) {
      String id = item[fieldName].toString();
      if (!uniqueIds.contains(id)) {
        uniqueList.add(item);
        uniqueIds.add(id);
      }
    }

    return uniqueList;
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
          .doc(user!.uid)
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

  @override
  void dispose() {
    // Dispose the timer when the widget is removed from the tree
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // StreamBuilder(
          //     stream: ref.onValue,
          //     builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          //       if (!snapshot.hasData) {
          //         return Container();
          //       } else {
          //         Map<dynamic, dynamic> map =
          //             snapshot.data!.snapshot.value as dynamic;
          //         List list = map.keys.toList();
          //         // print('the value of the $list is');

          //         Map deviceIds = map["deviceId1"];

          //         Map deviceData = deviceIds['data'];
          //         // Map data = deviceData['alerts'];

          //         Map data =
          //             deviceData['alerts'] is Map ? deviceData['alerts'] : {};
          //         print('the data is $data');
          //         return ListView.builder(
          //           shrinkWrap: true,
          //           itemCount: list.length,
          //           itemBuilder: (context, index) {
          //             return ListTile(
          //               title: Text('the alarm status is ${data['alarm']}'),
          //             );
          //           },
          //         );
          //       }
          //     }),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            // child: notificationList == null || notificationList.isEmpty
            child: false
                ? Column(
                    children: [
                      Center(
                          child: CustomText(
                        title: 'No Notifications',
                      )),
                    ],
                  )
                : Column(
                    children: [
                      //StreamBuilder for SafeCircle Add
                      // StreamBuilder<DatabaseEvent>(
                      //     stream: FirebaseDatabase.instance
                      //         .ref()
                      //         .child('safeCircle')
                      //         .child(user!.uid)
                      //         .child('circlePersons')
                      //         .onValue,
                      //     builder: (BuildContext context, snapshot) {
                      //       if (snapshot.hasData &&
                      //           snapshot.data!.snapshot.value != null) {
                      //         Map<dynamic, dynamic> safePersons = snapshot.data!
                      //             .snapshot.value as Map<dynamic, dynamic>;
                      //         List<Widget> alarmWidgets = [];
                      //         print("safe Persons: $safePersons");
                      //       }

                      //       return ListView.builder(
                      //         physics: const BouncingScrollPhysics(),
                      //         itemCount: notificationList.length,
                      //         // itemCount: 5,
                      //         shrinkWrap: true,
                      //         itemBuilder: (context, index) {
                      //           print(
                      //               'Notification list:  ${notificationList}');
                      //           notificationTitle =
                      //               notificationList[index]['notification'];
                      //           var notificationIndex = index;
                      //           return Container(
                      //             height: context.screenWidth * .30,
                      //             margin: EdgeInsets.only(top: 5.h),
                      //             padding: EdgeInsets.symmetric(
                      //                 horizontal: 10.w, vertical: 10.h),
                      //             decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(9.r),
                      //               color: const Color(0xffD7E1EC),
                      //             ),
                      //             child: Row(
                      //               children: [
                      //                 Image.asset(AppImages.checkMark),
                      //                 SizedBox(width: 20.w),
                      //                 Column(
                      //                   crossAxisAlignment:
                      //                       CrossAxisAlignment.start,
                      //                   children: [
                      //                     SizedBox(
                      //                       width: context.screenWidth * .6,
                      //                       child: CustomText(
                      //                         // title:'You have been added to Benjamin’s Safe\nCircle for Package Protection',
                      //                         title: notificationTitle,
                      //                         fontSize: 10.sp,
                      //                         fontWeight: FontWeight.w500,
                      //                         color: Colors.black,
                      //                       ),
                      //                     ),
                      //                     SizedBox(height: 10.h),
                      //                     Row(
                      //                       children: [
                      //                         Container(
                      //                           height:
                      //                               context.screenWidth * 0.1,
                      //                           width: 90,
                      //                           child: ElevatedButton(
                      //                             style: ElevatedButton.styleFrom(
                      //                                 primary: Color(
                      //                                     0xff3FCE33) // Set your desired background color here
                      //                                 ),
                      //                             onPressed: () async {
                      //                               accept = true;
                      //                               // var index= notificationList[index]['notification'];
                      //                               updateAcceptStatus(accept,
                      //                                   notificationTitle);
                      //                               deleteNotification(
                      //                                   notificationTitle,
                      //                                   index);
                      //                             },
                      //                             child: Text(
                      //                               'Accept',
                      //                               style:
                      //                                   TextStyle(fontSize: 15),
                      //                             ),
                      //                           ),
                      //                         ),
                      //                         SizedBox(
                      //                           width:
                      //                               context.screenWidth * 0.05,
                      //                           height:
                      //                               context.screenWidth * 0.05,
                      //                         ),
                      //                         Container(
                      //                           height: 35,
                      //                           width: 80,
                      //                           child: ElevatedButton(
                      //                             style: ElevatedButton.styleFrom(
                      //                                 primary: Colors
                      //                                     .red // Set your desired background color here
                      //                                 ),
                      //                             onPressed: () async {
                      //                               accept = false;
                      //                               print("updating status");
                      //                               deleteNotification(
                      //                                   notificationTitle,
                      //                                   index);
                      //                             },
                      //                             child: Text(
                      //                               'Reject',
                      //                               style:
                      //                                   TextStyle(fontSize: 14),
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ],
                      //                 )
                      //               ],
                      //             ),
                      //           );
                      //         },
                      //       );
                      //     }),

                      //stream builder safe circle notifications

                      StreamBuilder<List<Map<String, dynamic>>>(
                          stream: streamNotifications(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else if (!snapshot.hasData) {
                              print('No data in snapshot');
                              return Text('No data ');
                            } else {
                              List<Map<String, dynamic>> notifications =
                                  snapshot.data ?? [];
                              // Filter out duplicates based on deviceId
                              notifications =
                                  removeDuplicates(notifications, 'deviceId');
                              print("Notification list : ${notifications}");

                              return FutureBuilder<List<Map<String, dynamic>>>(
                                  future: getUserData(notifications
                                      .map((e) => e['deviceId'] as String)
                                      .toList()),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.hasError) {
                                      return Center(
                                        child: Text(
                                            'Error: ${userSnapshot.error}'),
                                      );
                                    } else {
                                      List<Map<String, dynamic>> userDataList =
                                          userSnapshot.data ?? [];
                                      print(
                                          "userData and Device details: $userDataList");
                                          String? userName = userDataList.isNotEmpty ? userDataList.first["Name"] : null;
String userAddress=userDataList.isNotEmpty ? userDataList.first["Address"] : null;
                                      return Column(
                                        children: [

                                          notifications[0]['alertValue']
                                              ? SafeCircleContainer(
                                                userName: userName ?? '',
                                                userAddress: userAddress,
                                                  titleText:
                                                      'PACKAGE THEFT ALERT',
                                                  subTitleText:
                                                      'A package is being retrieved without authorization at:',
                                                  leadingImg: AppImages.redIcon,
                                                  containerColor:
                                                      const Color(0xffC58888),
                                                  titleColor:
                                                      const Color(0xffCE3333),
                                                )
                                              : SizedBox(),
                                        ],
                                      );
                                    }
                                  });
                            }
                          }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
