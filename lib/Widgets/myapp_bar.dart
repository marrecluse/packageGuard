import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Utils/app_colors.dart';
import '../Utils/app_images.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

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
              )
            ],
          ),
        ),
        Positioned(
            top: 23.h,
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
