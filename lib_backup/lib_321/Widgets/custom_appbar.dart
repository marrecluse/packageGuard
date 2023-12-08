import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Utils/app_colors.dart';
import '../Utils/app_images.dart';
import '../Views/Profile_Page/profile_page.dart';
import 'custom_text.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget {
  String image;
  String title;
  CustomAppBar({
    Key? key,
    required this.image,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: 393.w,
          height: 167.h,
          child: Column(
            children: [
              Container(
                width: 393.w,
                height: 100.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.navyblue,
                      AppColors.darkblue,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => ProfilePage());
                            },
                            child: CircleAvatar(
                              radius: 25.r,
                              child: ClipOval(
                                child: Image.network(
                                  image, // Use the network URL directly
                                  height: 50.h,
                                  width: 50.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          // CircleAvatar(
                          //   radius: 25.r,

                          //   backgroundImage: AssetImage(
                          //     image,

                          //   ),
                          // ),
                          SizedBox(width: 10.w),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  title: "Welcome",
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                                SizedBox(height: 6.w),
                                CustomText(
                                  title: title,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ])
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: Icon(
                          Icons.menu,
                          size: 25.sp,
                          color: AppColors.white,
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
            top: 42.h,
            left: -50.w,
            right: -50.w,
            child: Center(
              child: Image.asset(
                AppImages.logo,
                height: 120.h,
              ),
            ))
      ],
    );
  }
}
