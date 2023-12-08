// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:packageguard/Views/User_Notification/user_notification.dart';
import '../../../Utils/app_colors.dart';
import '../../../Widgets/custom_text.dart';

class NotificationSection extends StatelessWidget {
List<String> packageList = [
    "Package1 has arrived",
    "Package2 has arrived",
    "Package3 has arrived",
    "Package4 has arrived",
    "Package5 has arrived",
    "Package6 has arrived",
  ];


  String text = '23 mins agooo';
  TextStyle textStyle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 8.sp,
    fontFamily: 'Inter',
    color: Color(0xff4F4F4F),
  );

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: packageList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                                 autofocus: false,
                                // focusColor: Colors.amber,
                                highlightColor: Colors.amber,
                                 onTap: (){
                                  // changeColor();

                              Get.to(() => UserNotification());
                                },
                                
                                child: CustomText(
                                  title: packageList[index],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.sp,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "23 mins ago",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 9.sp,
                              fontFamily: 'Inter',
                              color: const Color(0xff4F4F4F),
                            ),
                          ),
                        ],
                      ),
                      Divider(thickness: 1.5.w),
                    ],
                  );
                },
              ),
            ),
          ],
        ));
  }
}
