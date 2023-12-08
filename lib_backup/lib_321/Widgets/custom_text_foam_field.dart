import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Utils/app_colors.dart';

// ignore: must_be_immutable
class CustomTextFoamField extends StatelessWidget {
  String? hintText;
  Widget? prefixIcon;
  Widget? suffixIcon;
  bool obscureText;
  final TextEditingController controller;
  String? Function(String?)? validator;
  CustomTextFoamField(
      {this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      this.validator,
        this.obscureText = false, // Added the obscureText property
  required this.controller,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 355.w,
      height: 47.h,
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4).r),
        shadows: [
          BoxShadow(
            color: const Color(0x3F000000),
            blurRadius: 5.r,
            offset: const Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText, // Use the obscureText property here
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8),
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.grey, fontSize: 13.sp),
          prefixIcon: prefixIcon,
          suffixIcon: obscureText
              ? GestureDetector(
            onTap: () {
              // Toggle the password visibility when tapped
              obscureText = !obscureText;
            },
            child: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
            ),
          )
              : suffixIcon,
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }
}