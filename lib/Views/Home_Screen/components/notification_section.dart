// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
  @override
  // final ref = FirebaseDatabase.instance
  //     .ref('packageGuard/userId1/devices/deviceId1/data');

        
        
        
          // final ref2 = FirebaseDatabase.instance
  //     .ref('packageGuard/userId1/devices/deviceId1/timestamps');
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
  @override
  @override
  Widget build(BuildContext context) {
  final user=FirebaseAuth.instance.currentUser;
    final ref = FirebaseDatabase.instance
        .ref()
        .child('packageGuard')
        .child(user!.uid.toString())
        .child('devices')
        .child('SN83C048DF9D4')
        .child('alerts');
        
        

    return Container(
        height: 200.h,
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

            StreamBuilder(
                stream: ref.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    Map<dynamic, dynamic> map =
                        snapshot.data!.snapshot.value as dynamic;
                    // Map deviceData = map['data'];
                    // Map<dynamic, dynamic> alertsData = deviceData['alerts'];

                    // Map deviceData = map['deviceId1'];

                    Map<dynamic, dynamic> alertsData = map['alerts'];

                    // bool alarmStatus = alertsData['alarm'];
                    String alertTimestamp = alertsData['timeStamp'];
                    debugPrint("alertTime: ${alertsData['timeStamp']}");

                    // debugPrint('the alarmdata is $alarmStatus');

                    // Map timeStamps = map['deviceId1']['timestamps'];
                    // print("Timestamps are $timeStamps");

                    // List<dynamic> timestampValues = alertsData['timeStamp'].toList();

                    List<dynamic> itemList = [];
                    List<dynamic> alertTime = [];
                    bool packageAdded = alertsData['ALERT_SCALEADDED'];
                    
    int epochTimeInSeconds = int.parse(alertTimestamp);
                          DateTime dateTime =
                              DateTime.fromMillisecondsSinceEpoch(
                                  epochTimeInSeconds * 1000);
                          String formattedTime = timeago.format(
                            dateTime,
                            // locale: 'en_short',
                          );
            
                    void addItemToList() {
                        itemList.add("package arrived");
                        alertTime.add(formattedTime);
                        debugPrint('Item list: ${itemList}');
                        debugPrint('Item list length: ${itemList.length}');
                      
                    }

                    if (packageAdded) {
                      addItemToList();

                      alertsData['ALERT_SCALEADDED'] = false;

                      debugPrint(
                          'after updating, package added status is ${alertsData['ALERT_SCALEADDED']}');
                    }

                    // List<dynamic> itemList = [];
                    // bool packageAdded = alertsData['packageAdded'];

                    // debugPrint('the package added status is $packageAdded');
                    // print('time stamps status: $timeStamps');
                    // if (packageAdded) {
                    //   itemList.add("New Item");
                    //   packageAdded = false;
                    //   debugPrint(
                    //       'after updating, package added status is ${alertsData['packageAdded']}');
                    //   // updateAlertData();
                    //   debugPrint('Item list length: ${itemList.length}');
                    // }
                    // setState(() {
                    //   alertsData['packageAdded'] = false;
                    // });

                    // List<dynamic> list = map.values.toList();

                    return Expanded(
                      child: ListView.builder(
                        // physics: const BouncingScrollPhysics(),

                        itemCount: itemList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          // DateTime timestamp =
                          //     // DateTime.parse(timestampValues[index]);
                          //     DateTime.parse(alertTimestamp);
                          // // Format timestamp using timeago
                          // String formattedTime = timeago.format(
                          //   timestamp,
                          //   // locale: 'en_short',
                          // );

                      

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
                                                  title: itemList[index],
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
                                      title: alertTime[index],
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
                        },
                      ),
                    );
                  }
                }),

            // StreamBuilder(
            //     stream: ref.onValue,
            //     builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            //       if (!snapshot.hasData) {
            //         return Container();
            //       } else {
            //         List<Widget> notification = [];
            //         Map<dynamic, dynamic> map =
            //             snapshot.data!.snapshot.value as dynamic;

            //         // List<dynamic> list = map.values.toList();

            //         List<dynamic> list = map.values.toList();

            //         Map<dynamic, dynamic> alertList = list[0];

            //         alertList.forEach((key, value) {
            //           if ((key as String) == "packageAdded" && value == true) {
            //             notification.add(
            //               Column(
            //                 children: [
            //                   Row(
            //                     children: [
            //                       Row(
            //                         children: [
            //                           Image.asset(
            //                             'assets/images/diamond.png',
            //                             height: 18.h,
            //                             width: 17.w,
            //                           ),
            //                           SizedBox(
            //                             width: 5.w,
            //                           ),
            //                           InkWell(
            //                             autofocus: false,
            //                             // focusColor: Colors.amber,
            //                             highlightColor: Colors.amber,
            //                             onTap: () {
            //                               // changeColor();

            //                               Get.to(() => UserNotification());
            //                             },

            //                             child: CustomText(
            //                               title: notification.toString(),
            //                               fontWeight: FontWeight.w600,
            //                               fontSize: 11.sp,
            //                               color: AppColors.black,
            //                             ),
            //                           ),
            //                         ],
            //                       ),
            //                       Text(
            //                         "The package has been arrived",
            //                         style: TextStyle(
            //                           fontWeight: FontWeight.w400,
            //                           fontSize: 12.sp,
            //                           fontFamily: 'Inter',
            //                           color: const Color(0xff4F4F4F),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ],
            //               ),
            //             );
            //           }
            //         });

            //         return Column(
            //           children: [
            //             ListView.builder(
            //               physics: const BouncingScrollPhysics(),
            //               itemCount: notification.length,
            //               shrinkWrap: true,
            //               itemBuilder: (context, index) {
            //                 return notification[index];
            //               },
            //             ),
            //             Divider(
            //               color: Vx.black,
            //             )
            //           ],
            //         );
            //       }
            //     }),
          ],
        ));
  }
}
