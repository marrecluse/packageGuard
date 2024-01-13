import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../Utils/app_colors.dart';
import '../../../Utils/app_images.dart';
import '../../../Widgets/custom_text.dart';
import 'time_row.dart';

// ignore: use_key_in_widget_constructors

class UserNotificationData extends StatefulWidget {
  const UserNotificationData({super.key});

  @override
  State<UserNotificationData> createState() => _UserNotificationDataState();
}

class _UserNotificationDataState extends State<UserNotificationData> {
  @override
  void initState() {
    super.initState();
    fetchUserNotification();
    print("hello"); // Call the method to fetch data
  }

  List<Map<String, dynamic>> notificationList = [];
  bool isLoading = true;
  // final List _notificationList = [

  // 'A package has arrived',
  // 'A package has been retrieved',
  // 'A package has arrived',
  // 'You have added George Smith to your Safe Circle',
  // 'You have added George Smith to your Safe Circle',
  // 'You have ARMED your Package Guard',
  // 'A package has arrived',
  // 'A package has been retrieved',
  // 'A package has arrived',
  // 'You have added George Smith to your Safe Circle',
  // 'You have added George Smith to your Safe Circle',
  // 'You have ARMED your Package Guard',
  // 'A package has arrived',
  // 'A package has been retrieved',
  // 'A package has arrived',
  // 'You have added George Smith to your Safe Circle',
  // 'You have added George Smith to your Safe Circle',
  // 'You have ARMED your Package Guard',
  // 'A package has arrived',
  // 'A package has been retrieved',
  // 'A package has arrived',
  // 'You have added George Smith to your Safe Circle',
  // 'You have added George Smith to your Safe Circle',
  // 'You have ARMED your Package Guard',
  // ];

  Future<void> fetchUserNotification() async {
    final firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    try {
      final notificationCollection = firestore
          .collection('notifications')
          .doc(user?.uid)
          .collection("userNotification");

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
            isLoading = false; // Set loading to false in case of an error
            print("Notifications ; ${notificationList}");
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
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.h),
      height: 520.h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9.r),
        color: Colors.blueGrey.shade100,
        border: Border.all(color: AppColors.navyblue.withOpacity(0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomText(
            title: 'User Notification',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.navyblue,
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 450.h,
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("alerts")
                    .doc(user!.uid)
                    .collection('alertsLog')
                    .snapshots(),
                builder: (context, alertsSnapshot) {
                  if (alertsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (alertsSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${alertsSnapshot.error}'),
                    );
                  } else {
                    List<DocumentSnapshot> alertDocuments =
                        alertsSnapshot.data!.docs;
                    print("alerts documents: $alertDocuments");

                    return StreamBuilder<QuerySnapshot>(
                        // Stream for userNotification collection
                        stream: FirebaseFirestore.instance
                            .collection("notifications")
                            .doc(user!.uid)
                            .collection('userNotification')
                            .snapshots(),
                        builder: (context, userNotificationSnapshot) {
                          if (userNotificationSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (userNotificationSnapshot.hasError) {
                            return Center(
                              child: Text(
                                  'Error: ${userNotificationSnapshot.error}'),
                            );
                          } else {
                            List<DocumentSnapshot> userNotificationDocuments =
                                userNotificationSnapshot.data!.docs;
                            print(
                                "notifiction data: ${userNotificationDocuments}");

                            // Combine both sets of documents
                            List<DocumentSnapshot> allDocuments = [];
                            allDocuments.addAll(alertDocuments);
                            allDocuments.addAll(userNotificationDocuments);

                            // Sort combined documents by timestamp if they have a timestamp field
                            allDocuments.sort((a, b) =>
                                a['timestamp'].compareTo(b['timestamp']));

                            return ListView.builder(
                              itemCount: allDocuments.length,
                              itemBuilder: (context, index) {
                                String documentId = allDocuments[index].id;
                                Timestamp timestamp = allDocuments[index][
                                    'timestamp']; // Replace with your timestamp field
Map notificationTitles= allDocuments[index].data() as Map;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Image.asset(
                                    AppImages.checkMark,
                                    height: 23.h,
                                    width: 23.w,
                                  ),
                                  title: CustomText(
                                    title:'${notificationTitles['notification']}',
                                    fontSize: 10.sp,
                                              color: const Color(0xff3D3C3C),
                                              fontWeight: FontWeight.w600,),
                                  trailing: CustomText(
                                    title:'${timestamp.toDate()}',
                                    fontSize: 10.sp,
                                    
                                    ),
                                );

                                //  Column(
                                //   children: [
                                //     Row(
                                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //       children: [
                                //         Row(
                                //           children: [
                                //             Image.asset(
                                //               // index == 2 ||
                                //               //         index == 8 ||
                                //               //         index == 14 ||
                                //               //         index == 20
                                //               //     ? AppImages.redIcon
                                //               //     : index == 0 ||
                                //               //             index == 6 ||
                                //               //             index == 12 ||
                                //               //             index == 18
                                //               //         ? AppImages.diamondImg
                                //               //         : index == 5 ||
                                //               //                 index == 11 ||
                                //               //                 index == 17
                                //               //             ? AppImages.greenIcon
                                //               //             : AppImages.checkMark,
                                //                AppImages.checkMark,
                                //               height: 23.h,
                                //               width: 23.w,
                                //             ),
                                //             SizedBox(
                                //               width: 3.w,
                                //             ),
                                //             CustomText(
                                //               title:'ji',
                                //               fontSize: 10.sp,
                                //               color: const Color(0xff3D3C3C),
                                //               fontWeight: FontWeight.w600,
                                //             ),
                                //           ],
                                //         ),
                                //         // index == 0 ||
                                //         //         index == 1 ||
                                //         //         index == 2 ||
                                //         //         index == 6 ||
                                //         //         index == 7 ||
                                //         //         index == 8 ||
                                //         //         index == 12 ||
                                //         //         index == 13 ||
                                //         //         index == 14
                                //         //     ? const TimeRow()
                                //         //     : const Text(''),
                                //       ],
                                //     ),
                                //     Divider(thickness: 1.w),
                                //   ],
                                // );
                              },
                            );
                          }
                        });
                  }
                }),
          )
        ]),
      ),
      // CustomButton(
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
    );
  }
}


































// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:velocity_x/velocity_x.dart';

// import '../../../Utils/app_colors.dart';
// import '../../../Utils/app_images.dart';
// import '../../../Widgets/custom_text.dart';
// import 'time_row.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // ignore: use_key_in_widget_constructors

// class UserNotificationData extends StatefulWidget {
//   const UserNotificationData({super.key});

//   @override
//   State<UserNotificationData> createState() => _UserNotificationDataState();
// }

// class _UserNotificationDataState extends State<UserNotificationData> {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   @override
//   void initState() {
//     super.initState();
//     fetchUserNotification();
//     print("hello"); // Call the method to fetch data
//   }

//   // List<DatabaseReference> databaseRefs = [
//   //   FirebaseDatabase.instance
//   //       .ref('packageGuard/userId1/devices/deviceId1/timestamps'),
//   //   FirebaseDatabase.instance
//   //       .ref('packageGuard/userId1/devices/deviceId1/data/alerts'),
//   //   FirebaseDatabase.instance
//   //       .ref('packageGuard/userId1/devices/deviceId1/data/alerts'),
//   //   // Add more references as needed
//   // ];
//   DatabaseReference ref = FirebaseDatabase.instance
//       .ref("packageGuard/userId1/devices/deviceId1/data");

//   final DatabaseReference reference = FirebaseDatabase.instance.ref();
//   Future<List<String>> getDataFromReferences() async {
//     List<String> data = [];

//     // Replace 'reference1' and 'reference2' with your actual database references
//     // DatabaseEvent snapshot1 = await.ref('packageGuard/userId1/devices/deviceId1/timestamps').once(),
//     // DataSnapshot snapshot2 = await reference.child('reference2').once();

//     // // Extract data from snapshots
//     // data.addAll(List<String>.from(snapshot1.value));
//     // data.addAll(List<String>.from(snapshot2.value));

//     return data;
//   }

//   List<Map<String, dynamic>> notificationList = [];
//   bool isLoading = true;
//   // final List _notificationList = [

//   // 'A package has arrived',
//   // 'A package has been retrieved',
//   // 'A package has arrived',
//   // 'You have added George Smith to your Safe Circle',
//   // 'You have added George Smith to your Safe Circle',
//   // 'You have ARMED your Package Guard',
//   // 'A package has arrived',
//   // 'A package has been retrieved',
//   // 'A package has arrived',
//   // 'You have added George Smith to your Safe Circle',
//   // 'You have added George Smith to your Safe Circle',
//   // 'You have ARMED your Package Guard',
//   // 'A package has arrived',
//   // 'A package has been retrieved',
//   // 'A package has arrived',
//   // 'You have added George Smith to your Safe Circle',
//   // 'You have added George Smith to your Safe Circle',
//   // 'You have ARMED your Package Guard',
//   // 'A package has arrived',
//   // 'A package has been retrieved',
//   // 'A package has arrived',
//   // 'You have added George Smith to your Safe Circle',
//   // 'You have added George Smith to your Safe Circle',
//   // 'You have ARMED your Package Guard',
//   // ];

//   Future<void> fetchUserNotification() async {
//     final firestore = FirebaseFirestore.instance;
//     User? user = FirebaseAuth.instance.currentUser;

//     try {
//       final notificationCollection = firestore
//           .collection('notifications')
//           .doc(user?.uid)
//           .collection("userNotification");

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
//             isLoading = false; // Set loading to false in case of an error
//             print("Notifications ; ${notificationList}");
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
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 15.h),
//       height: 520.h,
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(9.r),
//         color: Colors.blueGrey.shade100,
//         border: Border.all(color: AppColors.navyblue.withOpacity(0.3)),
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CustomText(
//               title: 'User Notification',
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w700,
//               color: AppColors.navyblue,
//             ),
//             SizedBox(height: 10.h),
//             SizedBox(
//               height: 450.h,
//               child: StreamBuilder(
//                   stream: ref.onValue,
//                   builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//                     if (!snapshot.hasData) {
//                       return Container();
//                     } else {
//                       Map<dynamic, dynamic> map =
//                           snapshot.data!.snapshot.value as dynamic;

//                       List<dynamic> list = map.values.toList();

//                       Map<dynamic, dynamic> alertList = list[0];

//                       List<Widget> notification = [];

//                       alertList.forEach((key, value) {
//                         if ((key as String) == "packageMoved" &&
//                             value == true) {
//                           notification.add(
//                             Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset(
//                                       // index == 2 ||
//                                       //         index == 8 ||
//                                       //         index == 14 ||
//                                       //         index == 20
//                                       //     ? AppImages.redIcon
//                                       //     : index == 0 ||
//                                       //             index == 6 ||
//                                       //             index == 12 ||
//                                       //             index == 18
//                                       //         ? AppImages.diamondImg
//                                       //         : index == 5 ||
//                                       //                 index == 11 ||
//                                       //                 index == 17
//                                       //             ? AppImages.greenIcon
//                                       //             : AppImages.checkMark,
//                                       AppImages.redIcon,
//                                       height: 23.h,
//                                       width: 23.w,
//                                     ),
//                                     SizedBox(
//                                       width: 3.w,
//                                     ),
//                                     SizedBox(
//                                       width: 300,
//                                       child: CustomText(
//                                         title: "A package has been moved",
//                                         fontSize: 11.sp,
//                                         color: const Color(0xff3D3C3C),
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Divider(
//                                   color: Vx.black,
//                                 )
//                               ],
//                             ),
//                           );
//                         }
//                         if ((key as String) == "alarm" && value == true) {
//                           notification.add(
//                             Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset(
//                                       // index == 2 ||
//                                       //         index == 8 ||
//                                       //         index == 14 ||
//                                       //         index == 20
//                                       //     ? AppImages.redIcon
//                                       //     : index == 0 ||
//                                       //             index == 6 ||
//                                       //             index == 12 ||
//                                       //             index == 18
//                                       //         ? AppImages.diamondImg
//                                       //         : index == 5 ||
//                                       //                 index == 11 ||
//                                       //                 index == 17
//                                       //             ? AppImages.greenIcon
//                                       //             : AppImages.checkMark,
//                                       AppImages.checkMark,
//                                       height: 23.h,
//                                       width: 23.w,
//                                     ),
//                                     SizedBox(
//                                       width: 3.w,
//                                     ),
//                                     SizedBox(
//                                       width: 300,
//                                       child: CustomText(
//                                         title: "Alarm has been activated",
//                                         fontSize: 11.sp,
//                                         color: const Color(0xff3D3C3C),
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Divider(
//                                   color: Vx.black,
//                                 )
//                               ],
//                             ),
//                           );
//                         }
//                         Divider(
//                           color: Vx.black,
//                         );

//                         if ((key as String) == "packageRemoved" &&
//                             value == true) {
//                           notification.add(
//                             Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset(
//                                       // index == 2 ||
//                                       //         index == 8 ||
//                                       //         index == 14 ||
//                                       //         index == 20
//                                       //     ? AppImages.redIcon
//                                       //     : index == 0 ||
//                                       //             index == 6 ||
//                                       //             index == 12 ||
//                                       //             index == 18
//                                       //         ? AppImages.diamondImg
//                                       //         : index == 5 ||
//                                       //                 index == 11 ||
//                                       //                 index == 17
//                                       //             ? AppImages.greenIcon
//                                       //             : AppImages.checkMark,
//                                       AppImages.redIcon,
//                                       height: 23.h,
//                                       width: 23.w,
//                                     ),
//                                     SizedBox(
//                                       width: 3.w,
//                                     ),
//                                     SizedBox(
//                                       width: 300,
//                                       child: CustomText(
//                                         title: "A package has been removed",
//                                         fontSize: 11.sp,
//                                         color: const Color(0xff3D3C3C),
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Divider(
//                                   color: Vx.black,
//                                 )
//                               ],
//                             ),
//                           );
//                         }

//                         if ((key as String) == "packageAdded" &&
//                             value == true) {
//                           notification.add(
//                             Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset(
//                                       // index == 2 ||
//                                       //         index == 8 ||
//                                       //         index == 14 ||
//                                       //         index == 20
//                                       //     ? AppImages.redIcon
//                                       //     : index == 0 ||
//                                       //             index == 6 ||
//                                       //             index == 12 ||
//                                       //             index == 18
//                                       //         ? AppImages.diamondImg
//                                       //         : index == 5 ||
//                                       //                 index == 11 ||
//                                       //                 index == 17
//                                       //             ? AppImages.greenIcon
//                                       //             : AppImages.checkMark,
//                                       AppImages.diamondImg,
//                                       height: 23.h,
//                                       width: 23.w,
//                                     ),
//                                     SizedBox(
//                                       width: 3.w,
//                                     ),
//                                     SizedBox(
//                                       width: 300,
//                                       child: CustomText(
//                                         title: "A package has been arrived",
//                                         fontSize: 11.sp,
//                                         color: const Color(0xff3D3C3C),
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Divider(
//                                   color: Vx.black,
//                                 )
//                               ],
//                             ),
//                           );
//                         }
//                         if ((key as String) == "armedStatus" && value == true) {
//                           notification.add(
//                             Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Image.asset(
//                                       // index == 2 ||
//                                       //         index == 8 ||
//                                       //         index == 14 ||
//                                       //         index == 20
//                                       //     ? AppImages.redIcon
//                                       //     : index == 0 ||
//                                       //             index == 6 ||
//                                       //             index == 12 ||
//                                       //             index == 18
//                                       //         ? AppImages.diamondImg
//                                       //         : index == 5 ||
//                                       //                 index == 11 ||
//                                       //                 index == 17
//                                       //             ? AppImages.greenIcon
//                                       //             : AppImages.checkMark,
//                                       AppImages.greenIcon,
//                                       height: 23.h,
//                                       width: 23.w,
//                                     ),
//                                     SizedBox(
//                                       width: 3.w,
//                                     ),
//                                     SizedBox(
//                                       width: 300,
//                                       child: CustomText(
//                                         title:
//                                             "You have Armed your package package",
//                                         fontSize: 11.sp,
//                                         color: const Color(0xff3D3C3C),
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Divider(
//                                   color: Vx.black,
//                                 )
//                               ],
//                             ),
//                           );
//                         }
//                       });

//                       print('the list values is $list');
//                       return Column(
//                         children: [
//                           ListView.builder(
//                             shrinkWrap: true,
//                             physics: const BouncingScrollPhysics(),
//                             itemCount: notification.length,
//                             itemBuilder: (context, index) {
//                               return notification[index];
//                             },
//                           ),
//                         ],
//                       );
//                     }
//                   }),
//             ),
//             // CustomButton(
//             //   btnText: 'Go to Safe Circle Notification',
//             //   onPressed: () {
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(
//             //         builder: (context) => SafeCircleNotification(),
//             //       ),
//             //     );
//             //   },
//             //   btnColor: AppColors.appBlueColor,
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
