import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Utils/app_colors.dart';

// ignore: must_be_immutable
class LabelText extends StatelessWidget {
  String title;
  LabelText({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 13.sp,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          color: AppColors.text1color,
        ),
      ),
    );
  }
}
