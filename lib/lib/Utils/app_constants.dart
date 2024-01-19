import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_colors.dart';

class AppConstants {
  static showCustomSnackBar(String message, {bool isError = true}) {
    if (message.isNotEmpty) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: isError ? AppColors.green : AppColors.green,
        message: message,
        maxWidth: double.maxFinite,
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        margin: EdgeInsets.all(15.w),
        borderRadius: 10,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      ));
    }
  }
}
