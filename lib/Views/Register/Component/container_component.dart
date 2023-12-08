import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Utils/app_colors.dart';
import '../../../Utils/app_constants.dart';
import '../../../Utils/app_images.dart';
import '../../../Widgets/custom_container.dart';
import '../../../Widgets/custom_sized_box.dart';
import '../../../Widgets/custom_text.dart';

class ContainerComponent extends StatelessWidget {
  const ContainerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomContainer(
            margin: EdgeInsets.only(top: 10.h),
            height: 40.h,
            width: 220.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.r),
              border: Border.all(color: AppColors.backgoundColor),
              color: AppColors.backgoundColor,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 20.w,
              ),
              child: Row(
                children: [
                  Image(
                      image: AssetImage(AppImages.google),
                      height: 18.h,
                      width: 18.w),
                  CustomSizeBox(width: 20.w),
                  GestureDetector(
                    onTap: () {
                      AppConstants.showCustomSnackBar("Sign up with Google");
                    },
                    child: CustomText(
                      title: "Sign up with Google",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            )),
        CustomContainer(
            margin: EdgeInsets.only(top: 10.h),
            height: 40.h,
            width: 220.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.r),
              border: Border.all(color: AppColors.backgoundColor),
              color: AppColors.backgoundColor,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 20.w,
              ),
              child: Row(
                children: [
                  Image(
                      image: AssetImage(AppImages.linkedin),
                      height: 18.h,
                      width: 18.w),
                  CustomSizeBox(width: 20.w),
                  GestureDetector(
                    onTap: () {
                      AppConstants.showCustomSnackBar("Sign up with LinkedIn");
                    },
                    child: CustomText(
                      title: "Sign up with LinkedIn",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            )),
        GestureDetector(
          onTap: () {
            AppConstants.showCustomSnackBar("Sign up with Facebook");
          },
          child: CustomContainer(
              margin: EdgeInsets.only(top: 10.h),
              height: 40.h,
              width: 220.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.r),
                border: Border.all(color: AppColors.backgoundColor),
                color: AppColors.backgoundColor,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20.w,
                ),
                child: Row(
                  children: [
                    Image(
                        image: AssetImage(AppImages.facbook),
                        height: 18.h,
                        width: 18.w),
                    CustomSizeBox(width: 20.w),
                    CustomText(
                      title: "Sign up with Facebook",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }
}
