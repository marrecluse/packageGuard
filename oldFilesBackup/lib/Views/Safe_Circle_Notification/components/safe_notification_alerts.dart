import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Views/DeviceDetails/device_detail.dart';
import 'package:packageguard/Views/Home_Screen/backup/add_package_gaurd.dart';
import 'package:packageguard/Views/Home_Screen/components/notification_section.dart';
import 'package:packageguard/Views/Login/login.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import 'package:packageguard/Widgets/custom_text.dart';
import 'package:packageguard/Widgets/drawer.dart';
// import 'package:packageguard/Utils/app_images.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userController = Get.find<UserController>();

// Access user data
  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> devices = [];

  @override
  void initState() {
    super.initState();
    // Access user data in initState or another method
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
          child: Column(
            children: [
              CustomAppBar(
                image:profileImage,
                title: '${userData['Name']}',
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
                        Get.to(() => const DeviceDetails());
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
                     AddPackageGaurd(),
              
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
