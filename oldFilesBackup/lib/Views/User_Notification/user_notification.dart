import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_images.dart';
import '../../Utils/app_colors.dart';
import '../../Widgets/custom_appbar.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/drawer.dart';
import '../Login/login.dart';
import '../Safe_Circle_Notification/safe_circle_notification.dart';
import 'components/user_notification_data.dart';

class UserNotification extends StatefulWidget {
  const UserNotification({super.key});

  @override
  State<UserNotification> createState() => _UserNotificationState();
}


// Access user data



class _UserNotificationState extends State<UserNotification> {
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
                image:profileImage,
                title: '${userData['Name']}',
              ),
              GestureDetector(
                  onTap: () {
                    //  Get.to(() => const SafeCircleNotification());
                  },
                  child: UserNotificationData()),
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
