import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Views/Safe_Circle_Notification/safe_circle_notification.dart';
import 'package:velocity_x/velocity_x.dart';

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
    List<String> titleName = title.split(' ');
    print("Title last: ${titleName.last} Name: $title");

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
                                child: userData['method'] == 'emailAndPass'
                                    ? Image.network(
                                        image.toString(),
                                        
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Icon(Icons
                                                .person_2_outlined), // Use the network URL directly
                                        height: 50.h,
                                        width: 50.h,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        image,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Icon(Icons
                                                .person_2_outlined), // Use the network URL directly
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
                                  style: FontStyle.italic,
                                  title: "Welcome",
                                  fontSize: 11.sp,
                                  
                                  color: AppColors.white,
                                ),
                                SizedBox(height: 0.5.w),
                                SizedBox(
                                  width:85,
                                  child: CustomText(
                                    lines: 2,
                                    title: title.length > 16 ? titleName.first : title,
                                    fontSize:
                                        title.length > 13 ? 9.sp : 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
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
