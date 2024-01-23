import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Widgets/custom_text.dart';

// ignore: must_be_immutable
class SafeCircleContainer extends StatelessWidget {
  String titleText;
  String subTitleText;
  Color titleColor;
  Color containerColor;
  String leadingImg;
  String userName='';
  String userAddress='';

  SafeCircleContainer({
    super.key,
     this.userName='',
     this.userAddress='',
    required this.titleText,
    required this.subTitleText,
    required this.leadingImg,
    required this.containerColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      //  height: 116.h,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: containerColor,
      ),
      child: Row(
        children: [
          Image.asset(leadingImg),
          SizedBox(
            width: 20.w,
          ),
          Container(
            width: 280.w,
            child: Column(
              children: [
                CustomText(
                  lines:4,
                  title: titleText,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                SizedBox(
                  child: CustomText(
                    lines: 4,
                    title: subTitleText,
                    //     textAlign: TextAlign.center,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10.h),
                CustomText(
                  title: "$userName's House",
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff15508D),
                ),
                SizedBox(
                  child: Center(
                    child: CustomText(
                      title: userAddress,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
