// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Views/AddPackageGuard/Bluetooth.dart';
import 'package:packageguard/Views/Wifi_Connect/wifi_connect.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../Utils/app_colors.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/drawer.dart';
import '../DeviceDetails/device_detail.dart';
import '../Login/login.dart';
import 'components/add_package_gaurd.dart';
import 'components/notification_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  


// Access user data
  Map<String, dynamic> userData = {};
  String empty = '';
  List<Map<String, dynamic>> devices = [];

  bool isAlarming = false;

  void storeAlarmStatus(bool alarmStatus) {
    isAlarming = alarmStatus;

    print("app: $isAlarming");
  }

  void getAlarmStatus() {
    print("function started");

    DatabaseReference alarmRef = FirebaseDatabase.instance
        .ref('devices/SN83C048DF9D4/alerts/ALARM_SCALERMOVED');
    alarmRef.onValue.listen((DatabaseEvent event) {
      setState(() {
        final alarmStatus = event.snapshot.value as bool;
        // final alarmStatus = true;

        storeAlarmStatus(alarmStatus);
        if (alarmStatus) {
          turnOnAlarm();
          print("server: ${alarmStatus}");
        }
      });
    });
  }

  void turnOffAlarm() async {
    DatabaseReference armedRef =
        FirebaseDatabase.instance.ref("devices/SN83C048DF9D4_status/");
    await armedRef.update({
      "alarm": false,
    });
  }

  void turnOnAlarm() async {
    DatabaseReference armedRef =
        FirebaseDatabase.instance.ref("devices/SN83C048DF9D4_status/");
    await armedRef.update({
      "alarm": true,
    });
  }

  @override
  void initState() {
    super.initState();
    getAlarmStatus();
            final userController = Get.find<UserController>();



    // Access user data in initState or another method
    userData = userController.userData as Map<String, dynamic>;
    print('user details are: $userData');
    print('user profile ${userData['ProfileImage']}');
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = userData['ProfileImage'].toString().trim();
    
 UserCredential? userCredential = Get.arguments as UserCredential?;
    
    String userEmail = userCredential?.user?.email ?? 'No email available';
    String userName = userCredential?.user?.displayName ?? 'No name available';
    String guserPicture = userCredential?.user?.photoURL ?? 'No picture available';

    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                image:profileImage,
                // image: userData['method']=='emailAndPass' ? emailprofileImage : guserPicture,
                title: '${userData['Name'] ?? 'User'} ',

                // title: 'Abdul',
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    NotificationSection(),
                    SizedBox(height: 12.h),
                    
                    GestureDetector(
                      onTap: () {
                        Get.to(() => BluetoothPage());
                      },
                      child: Container(
                        // height: 30.h,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        width: 393.w,
                        decoration: BoxDecoration(
                            color: AppColors.navyblue,
                            borderRadius: BorderRadius.circular(8.r)),
                        child: Center(
                          child: CustomText(
                            title: "Add Package Guard",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.btntext,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    isAlarming
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                turnOffAlarm();
                              });
                            },
                            child: Container(
                              color: Colors.red,
                              child: Column(children: [
                                const Text(
                                  'DEVICE IS ALARMING...Turn Off Alarm',
                                  style: TextStyle(fontSize: 15.0),
                                ),
                                Icon(Icons.notifications_off, size: 50.0),
                              ]),
                            ),
                          )
                        : SizedBox(),
                    GestureDetector(
                        onTap: () {
                          Get.to(DeviceDetails());
                        },
                        child: AddPackageGaurd()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
