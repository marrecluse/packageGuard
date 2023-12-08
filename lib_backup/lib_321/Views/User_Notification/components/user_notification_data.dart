import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Utils/app_colors.dart';
import '../../../Utils/app_images.dart';
import '../../../Widgets/custom_text.dart';
import 'time_row.dart';

// ignore: use_key_in_widget_constructors
class UserNotificationData extends StatelessWidget {
  final List _notificationList = [
    'A package has arrived',
    'A package has been retrieved',
    'A package has arrived',
    'You have added George Smith to your Safe Circle',
    'You have added George Smith to your Safe Circle',
    'You have ARMED your Package Guard',
    'A package has arrived',
    'A package has been retrieved',
    'A package has arrived',
    'You have added George Smith to your Safe Circle',
    'You have added George Smith to your Safe Circle',
    'You have ARMED your Package Guard',
    'A package has arrived',
    'A package has been retrieved',
    'A package has arrived',
    'You have added George Smith to your Safe Circle',
    'You have added George Smith to your Safe Circle',
    'You have ARMED your Package Guard',
    'A package has arrived',
    'A package has been retrieved',
    'A package has arrived',
    'You have added George Smith to your Safe Circle',
    'You have added George Smith to your Safe Circle',
    'You have ARMED your Package Guard',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.h),
      height: 520.h,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9.r),
        color: Colors.blueGrey.shade100,
        border: Border.all(color: AppColors.navyblue.withOpacity(0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              title: 'User Notification',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.navyblue,
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 450.h,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _notificationList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                index == 2 ||
                                        index == 8 ||
                                        index == 14 ||
                                        index == 20
                                    ? AppImages.redIcon
                                    : index == 0 ||
                                            index == 6 ||
                                            index == 12 ||
                                            index == 18
                                        ? AppImages.diamondImg
                                        : index == 5 ||
                                                index == 11 ||
                                                index == 17
                                            ? AppImages.greenIcon
                                            : AppImages.checkMark,
                                height: 23.h,
                                width: 23.w,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              CustomText(
                                title: _notificationList[index],
                                fontSize: 10.sp,
                                color: const Color(0xff3D3C3C),
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          index == 0 ||
                                  index == 1 ||
                                  index == 2 ||
                                  index == 6 ||
                                  index == 7 ||
                                  index == 8 ||
                                  index == 12 ||
                                  index == 13 ||
                                  index == 14
                              ? const TimeRow()
                              : const Text(''),
                        ],
                      ),
                      Divider(thickness: 1.w),
                    ],
                  );
                },
              ),
            ),
            // CustomButton(
            //   btnText: 'Go to Safe Circle Notification',
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => SafeCircleNotification(),
            //       ),
            //     );
            //   },
            //   btnColor: AppColors.appBlueColor,
            // ),
          ],
        ),
      ),
    );
  }
}
