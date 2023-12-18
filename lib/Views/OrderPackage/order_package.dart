import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Views/AddPackageGuard/Bluetooth.dart';
import 'package:packageguard/Views/Login/login.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import 'package:packageguard/Widgets/custom_text.dart';
import 'package:packageguard/screens/scan_screen.dart';

import '../../Widgets/drawer.dart';

class OrderPackage extends StatefulWidget {
  const OrderPackage({super.key});

  @override
  State<OrderPackage> createState() => _OrderPackageState();
}

class _OrderPackageState extends State<OrderPackage> {
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
      body: Column(children: [
        CustomAppBar(image: profileImage, title: '${userData['Name']}'),
        Column(
          children: [
            SizedBox(height: 20.h),
            Container(
              width: 345.w,
              //height: 359.h,
              decoration: ShapeDecoration(
                color: const Color(0x2B15508D),
                // image: DecorationImage(
                //   image: AssetImage(AppImages.hose),
                //   fit: BoxFit.fill,

                // ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
              ),
              child: Column(
                children: [
                  Image.asset(
                    AppImages.hose,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        SizedBox(
                          width: 400.w,
                          height: 70.h,
                          child: CustomText(
                            title: "Secure your Package Guard today!",
                            fontSize: 20.sp,
                            color: AppColors.navyblue,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        CustomText(
                          title:
                              "Get your Package Guard today, you receive 20% off.",
                          fontSize: 14.sp,
                          color: AppColors.navyblue,
                          fontWeight: FontWeight.w400,
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 10.h),
                        GestureDetector(
                          onTap: () {

                            // Get.to(BluetoothPage());
                            Get.to(ScanScreen());
                          },
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              height: 40.h,
                              width: 180.w,
                              decoration: BoxDecoration(
                                  color: AppColors.navyblue,
                                  borderRadius: BorderRadius.circular(8.r)),
                              child: Center(
                                child: CustomText(
                                  title: "Scan with Bluetooth",
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            )
          ],
        )
      ]),
    ));
  }
}
