import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Views/DeviceDetails/Device_alerts_data.dart';
import 'package:packageguard/Views/Login/login.dart';
import 'package:packageguard/Views/Safe_Circle_Notification/safe_circle_notification.dart';
import 'package:packageguard/Views/User_Notification/components/user_notification_data.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import 'package:packageguard/Widgets/custom_text.dart';
import 'package:packageguard/Widgets/drawer.dart';

class DeviceHistory extends StatefulWidget {
  const DeviceHistory({super.key});

  @override
  State<DeviceHistory> createState() => _DeviceHistoryState();
}

class _DeviceHistoryState extends State<DeviceHistory> {
  final userController = Get.find<UserController>();
  Map<String, dynamic> userData = {};
  @override
  void initState() {
    super.initState();

    userData = userController.userData as Map<String, dynamic>;
    print(userData);
    print(userData['ProfileImage']);
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = userData['ProfileImage'].toString().trim();

    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              CustomAppBar(
                image: profileImage,
                title: '${userData['Name'] ?? 'User'}',
              ),
              GestureDetector(
                  onTap: () {
                    //  Get.to(() => const SafeCircleNotification());
                  },
                  child: DeviceAlertsData()),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  Get.to(() => const SafeCircleNotification());
                },
                child: Container(
                  //height: 30.h,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  width: 350.w,
                  decoration: BoxDecoration(
                      color: AppColors.navyblue,
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Center(
                    child: CustomText(
                      title: "Safe Circle Notification",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.btntext,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
