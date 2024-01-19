// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:packageguard/Views/DeviceDetails/device_detail.dart';
import 'package:packageguard/Views/User_Notification/user_notification.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../Utils/app_colors.dart';
import '../../../Widgets/custom_text.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationSection extends StatefulWidget {
  const NotificationSection({super.key});

  @override
  State<NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection> {
  List<Map<String, dynamic>> filteredData =
      []; // Global variable to hold fetched data

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchAlertsLog();
    fetchFilteredData();
  }

  // final ref = FirebaseDatabase.instance
  //     .ref('packageGuard/userId1/devices/deviceId1/data');

  // final ref2 = FirebaseDatabase.instance
  //     .ref('packageGuard/userId1/devices/deviceId1/timestamps');






  Stream<List<Map<String, dynamic>>> fetchFilteredAlertsStream() {
    try {
      // Reference to your Firestore collection
      CollectionReference<Map<String, dynamic>> alertsCollection =
          FirebaseFirestore.instance.collection('alerts');

      // Query to get documents where alertType is equal to 'ALERT_SCALEADDED'
      return alertsCollection
          .doc(userController.userData['uid']) // Specific document ID
          .collection('alertsLog') // Subcollection
          .where('alertType', isEqualTo: 'ALERT_SCALEADDED')
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          // Access the timestamp field in each document
          Timestamp timestamp = doc['timestamp'];
          // Convert the timestamp to a DateTime object
          DateTime dateTime = timestamp.toDate();

          // Add the timestamp to the document data
          Map<String, dynamic> dataWithTimestamp = {
            ...doc.data()!,
            'timestamp': dateTime,
          };

          return dataWithTimestamp;
        }).toList();
      });
    } catch (e) {
      // Handle errors here
      print('Error fetching data: $e');
      return Stream.empty(); // Return an empty stream in case of error
    }
  }

  void fetchFilteredData() {
    fetchFilteredAlerts().then((data) {
      // Handle the retrieved data here
      filteredData = data;
      print(
          "filter: $filteredData"); // Store fetched data in the global variable

      for (var doc in data) {
        print("docs are :$doc"); // Process or display the data as needed
      }
    }).catchError((error) {
      // Handle any errors that occurred during the fetch operation
      print('Error: $error');
    });
  }

  Future<void> _refreshData() async {
    initState();
    setState(() {
      userData = userController.userData as Map<String, dynamic>;
    });
  }

  Future<List<Map<String, dynamic>>> fetchFilteredAlerts() async {
    try {
      // Reference to your Firestore collection
      CollectionReference<Map<String, dynamic>> alertsCollection =
          FirebaseFirestore.instance.collection('alerts');

      // Query to get documents where alertType is equal to 'ALERT_SCALEADDED'
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await alertsCollection
          .doc(userController.userData['uid']) // Specific document ID
          .collection('alertsLog') // Subcollection
          .where('alertType', isEqualTo: 'ALERT_SCALEADDED')
          .get();

      // Extract documents from the query snapshot
      List<Map<String, dynamic>> documents =
          querySnapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
        // Access the timestamp field in each document
        Timestamp timestamp = doc['timestamp'];
        // Convert the timestamp to a DateTime object
        DateTime dateTime = timestamp.toDate();

        // Add the timestamp to the document data
        Map<String, dynamic> dataWithTimestamp = {
          ...doc.data()!,
          'timestamp': dateTime,
        };

        return dataWithTimestamp;
      }).toList();

      return documents;
    } catch (e) {
      // Handle errors here
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> fetchAlertsLog() async {
    print('hittttttttt');
    try {
      // Reference to your Firestore collection
      CollectionReference<Map<String, dynamic>> alertsCollection =
          FirebaseFirestore.instance.collection('alerts');

      // Query to get documents from the specified collection
      // Query to get documents where alertType is
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await alertsCollection
          .doc(userController.userData['uid']) // Specific document ID
          .collection('alertsLog') // Subcollection
          .where('alertType', isEqualTo: 'ALERT_SCALEADDED')
          .get();
      // Extract documents from the query snapshot
      List<DocumentSnapshot<Map<String, dynamic>>> documents =
          querySnapshot.docs;
      print('documents  $documents');
      return documents;
    } catch (e) {
      // Handle errors here
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<void> updateAlertData() async {
    DatabaseReference alarmRef = FirebaseDatabase.instance
        .ref("packageGuard/userId1/devices/deviceId1/alerts/");
    await alarmRef.once();

    await alarmRef.update({"ALERT_SCALEADDED": false});
  }

  // String text = '23 mins agooo';
  TextStyle textStyle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 8.sp,
    fontFamily: 'Inter',
    color: Color(0xff4F4F4F),
  );

  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.bluecontainer,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.navyblue, width: 1.w),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            CustomText(
              title: 'Notification',
              color: AppColors.navyblue,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),

            SizedBox(height: 10.h),

            Container(              
              height: 140.h,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: fetchFilteredAlertsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator()); // Show a loading indicator
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Show an error message
                    } else if (snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'No data available',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat'
                                    ),),
                              ],
                            ),
                          ],
                        ),
                      ); // Show a message when no data is available
                    } else {
                      // Data available - use ListView.builder here
                      print("filteredData ${snapshot.data}");
                      return ListView.builder(
                        
                          itemCount:snapshot.data!.length,
                          shrinkWrap: true,
                          itemBuilder: (context, int index) {
                            Map<String, dynamic> document = snapshot.data![index];
                            DateTime timestamps = document['timestamp'];
              
                            // DateTime.parse(timestampValues[index]);
                            // Format timestamp using timeago
                            String formattedTime = timeago.format(
                              timestamps,
                              // locale: 'en_short',
                            );
              
                            return Column(
                              children: [
                                Align(
                                  alignment:
                                      Alignment.centerLeft, // Adjust as needed
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  'assets/images/diamond.png',
                                                  height: 18.h,
                                                  width: 17.w,
                                                ),
                                                SizedBox(
                                                  width: 5.w,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Get.to(
                                                        () => UserNotification());
                                                  },
                                                  child: CustomText(
                                                    title: 'package arrived',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11.sp,
                                                    color: AppColors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      CustomText(
                                        title: formattedTime,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11.sp,
                                        color: AppColors.black,
                                      ),
                                    ],
                                  ),
                                ),
                                Divider()
                              ],
                            );
                          });
                    }
                  }),
            ),
          ],
        ));
  }
}