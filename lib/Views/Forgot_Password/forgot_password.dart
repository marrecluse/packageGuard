import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:packageguard/Views/Login/login.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/app_constants.dart';
import '../../Widgets/custom_sized_box.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/custom_text_foam_field.dart';
import '../../Widgets/label_text.dart';
import '../../Widgets/myapp_bar.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(children: [
        const MyAppBar(),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CustomText(
                        title: "Forgot Password",
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                    CustomSizeBox(height: 21.h),
                    LabelText(title: "Email"),
                    CustomSizeBox(height: 5.h),
                    CustomTextFoamField(
                      controller: emailController,
                      hintText: "Email",
                    ),
                    CustomSizeBox(height: 29.h),
                    Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              fixedSize: Size(198.w, 40.h),
                              backgroundColor: AppColors.green),
                          onPressed: () {
                            FirebaseAuth.instance
                                .sendPasswordResetEmail(
                                    email: emailController.text)
                                .then((value) {
                              AppConstants.showCustomSnackBar(
                                  "OTP send on your email!");
                            });
                          },
                          child: CustomText(
                            title: "Submit",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.btntext,
                          )),
                    ),
                    CustomSizeBox(height: 10.h),
                    Center(
                        child: CustomText(
                      title: "or",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    )),
                    CustomSizeBox(height: 10.h),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const SignIn());
                      },
                      child: Center(
                          child: CustomText(
                        title: "Sign In",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w300,
                        color: AppColors.black,
                        decoration: TextDecoration.underline,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ]),
    ));
  }
}
