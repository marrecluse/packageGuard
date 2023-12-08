import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import 'package:packageguard/Widgets/custom_text.dart';

import '../../Widgets/drawer.dart';

class OrderPackage extends StatefulWidget {
  const OrderPackage({super.key});

  @override
  State<OrderPackage> createState() => _OrderPackageState();
}

class _OrderPackageState extends State<OrderPackage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      drawer: MyDrawer(),
      body: Column(children: [
        CustomAppBar(image: AppImages.profile, title: "shees "),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Container(
                width: 359.w,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(AppImages.hose),
                    SizedBox(height: 10.h),
                    CustomText(
                      title: "   Secure your Package Guard today!",
                      fontSize: 18.sp,
                      color: AppColors.navyblue,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 10.h),
                    CustomText(
                      title:
                          "   Get your Package Guard today, you receive 20% off.",
                      fontSize: 14.sp,
                      color: AppColors.navyblue,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.only(left: 7.w),
                      child: GestureDetector(
                        onTap: () {
                          // Get.to(() => const OrderPackage());
                        },
                        child: Container(
                          height: 30.h,
                          width: 180.w,
                          decoration: BoxDecoration(
                              color: AppColors.navyblue,
                              borderRadius: BorderRadius.circular(8.r)),
                          child: Center(
                            child: CustomText(
                              title: "Reserve yours today",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              )
            ],
          ),
        )
      ]),
    ));
  }
}
