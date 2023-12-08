import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Views/Login/login.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import 'package:velocity_x/velocity_x.dart';
// import 'package:safepackage/Utils/app_images.dart';
// import 'package:safepackage/Widgets/custom_appbar.dart';

import '../../Utils/app_colors.dart';
import '../../Widgets/custom_sized_box.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/drawer.dart';
import '../OrderPackage/order_package.dart';

class AddPackageGuard extends StatefulWidget {
  const AddPackageGuard({super.key});

  @override
  State<AddPackageGuard> createState() => _AddPackageGuardState();
}

class _AddPackageGuardState extends State<AddPackageGuard> {
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
      body: Column(
        children: [
          CustomAppBar(image: profileImage, title: '${userData['Name']}',
),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                CustomText(
                  title: 'Add Package Guard',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyblue,
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: 358.w,
                  height: 152.h,
                  child: Stack(
                    
                    children: [
                      Container(
                        width: 358.w,
                        height: 49.h,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: ShapeDecoration(
                          color: const Color(0x2B15508D),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1.w, color: const Color(0x7F15508D)),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                        ),
                        child: 
                        Row(
                          children: [
                            Container(
                              width: 39.w,
                              height: 37.h,
                              decoration: ShapeDecoration(
                                color: const Color(0xB515508D),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.r)),
                              ),
                              child: Center(
                                child: CustomText(
                                  title: '1',
                                  fontSize: 15.sp,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 15.w),
                            CustomText(
                              title:
                                  'Press the RESET button on the \n bottom of the unit TWICE',
                              fontSize: 12.sp,
                              color: AppColors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                       
                      Positioned(
                        top: 30,
                        left:150,
                        child: Image.asset(
                          AppImages.guard,
                          height: 120.h,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: 358.w,
                  height: 49.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: ShapeDecoration(
                    color: const Color(0x2B15508D),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 1.w, color: const Color(0x7F15508D)),
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 39.w,
                        height: 37.h,
                        decoration: ShapeDecoration(
                          color: const Color(0xB515508D),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9.r)),
                        ),
                        child: Center(
                          child: CustomText(
                            title: '2',
                            fontSize: 15.sp,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      CustomText(
                        title:
                            'Wait as the app connects with the\n unit via Bluetooth',
                        fontSize: 12.sp,
                        color: AppColors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: 358.w,

                  //  height: 49.h,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                  decoration: ShapeDecoration(
                    color: const Color(0x2B15508D),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 1.w, color: const Color(0x7F15508D)),
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: 39.w,
                              height: 37.h,
                              decoration: ShapeDecoration(
                                color: const Color(0xB515508D),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.r)),
                              ),
                              child: Center(
                                child: CustomText(
                                  title: '3',
                                  fontSize: 15.sp,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 260.w,
                            height: 70.h,
                            child: 
                            CustomText(
                              
                              title:
                                  'Receive a READY notification. \nCheck your list of devices.\n\nFor troubleshooting, go to:',
                                  
                              fontSize: 12.sp,
                              color: AppColors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          CustomText(
                            title: 'www.thepackageguard.com/support',
                            fontSize: 12.sp,
                            color: AppColors.navyblue,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomSizeBox(height: 150.h),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const OrderPackage());
                  },
                  child: Container(
                    //  height: 30.h,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    width: 390.w,
                    decoration: BoxDecoration(
                        color: AppColors.navyblue,
                        borderRadius: BorderRadius.circular(8.r)),
                    child: Center(
                      child: CustomText(
                        title: "Access Phone Contact",
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}