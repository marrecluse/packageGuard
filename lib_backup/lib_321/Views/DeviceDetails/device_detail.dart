import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';

import '../../Utils/app_colors.dart';
import '../../Utils/app_constants.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/drawer.dart';
import '../EditSafeCircle/edit_safecircle.dart';
import '../Home_Screen/components/customSwitch.dart';
import '../Home_Screen/components/inner_container_data.dart';
import '../Login/login.dart';

class DeviceDetails extends StatefulWidget {
  const DeviceDetails({super.key});

  @override
  State<DeviceDetails> createState() => _DeviceDetailsState();
}


final userController = Get.find<UserController>();
Map<String, dynamic> userData = {};




class _DeviceDetailsState extends State<DeviceDetails> {
  @override
  void initState() {
    super.initState();


    userData = userController.userData as Map<String, dynamic>;
    print(userData);
    print(userData['ProfileImage']);

  }

  final profileImage = userData['ProfileImage'].toString().trim();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        body: Column(
          children: [
            CustomAppBar(
              image:profileImage,
              title: '${userData['Name']}',
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 182.w,
                        height: 100.h,
                        decoration: ShapeDecoration(
                          color: const Color(0x2B15508D),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1.w, color: AppColors.navyblue),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                title: "20 Packages",
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyblue,
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    title: "Guraded Date",
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.black,
                                  ),
                                  Image.asset(
                                    AppImages.box,
                                    height: 30.h,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 169.w,
                              height: 41.h,
                              decoration: ShapeDecoration(
                                color: const Color(0xB515508D),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 1.w,
                                      color: const Color(0x7F15508D)),
                                  borderRadius: BorderRadius.circular(9.r),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      height: 25.h,
                                      AppImages.alram,
                                    ),
                                    SizedBox(width: 10.w),
                                    CustomText(
                                      title: "Test Alarm",
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Container(
                              width: 169.w,
                              height: 41.h,
                              decoration: ShapeDecoration(
                                color: const Color(0xB515508D),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 1.w,
                                      color: const Color(0x7F15508D)),
                                  borderRadius: BorderRadius.circular(9.r),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      height: 25.h,
                                      AppImages.speaker,
                                    ),
                                    SizedBox(width: 10.w),
                                    CustomText(
                                      title: "Adjust Volumn",
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Container(
                    width: 358.w,
                    // height: 176.h,
                    padding: EdgeInsets.symmetric(horizontal: 15.h),
                    decoration: ShapeDecoration(
                      color: const Color(0x2B15508D),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 1.w, color: const Color(0x7F15508D)),
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                            contentPadding: EdgeInsets.zero,
                            horizontalTitleGap: 10.w,
                            leading: Image.asset(
                              AppImages.packageLogo,
                              height: 48.h,
                              width: 68.w,
                            ),
                            title: CustomText(
                                title: "Armed",
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                                color: const Color(0xff348D15)),
                            subtitle: CustomText(
                              title: "Front Door",
                              color: const Color(0xff4E4E4E),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            trailing: Image.asset(
                              AppImages.greenIcon,
                              height: 60.h,
                            )),
                        SizedBox(height: 15.h),
                        Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 9.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InnerContainerData(
                                img: AppImages.wifiImg,
                                imgHeight: 20,
                                imgWidth: 20,
                                toptext: 'Connected to',
                                btnText: "Micheal's Wifi",
                                tFontWeight: FontWeight.w400,
                                bFontWeight: FontWeight.w700,
                              ),
                              InnerContainerData(
                                img: AppImages.batteryFull,
                                imgHeight: 20,
                                imgWidth: 30,
                                toptext: 'Battery',
                                btnText: "90%",
                                tFontWeight: FontWeight.w400,
                                bFontWeight: FontWeight.w700,
                              ),
                              InnerContainerData(
                                img: AppImages.diamondImg,
                                imgHeight: 22,
                                imgWidth: 22,
                                toptext: '2 Packages',
                                btnText: "Waiting",
                                tFontWeight: FontWeight.w700,
                                bFontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.h),
                        const CustomSwitch(),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 120.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const EditSafeCircle());
                        },
                        child: Container(
                          //height: 30.h,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          width: 150.w,
                          decoration: BoxDecoration(
                              color: AppColors.navyblue,
                              borderRadius: BorderRadius.circular(8.r)),
                          child: Center(
                            child: CustomText(
                              title: "See History",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.btntext,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 50.w),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                AppConstants.showCustomSnackBar("Share!");
                              },
                              child: Image.asset(
                                AppImages.share1,
                                height: 30.h,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            GestureDetector(
                                onTap: () {
                                  AppConstants.showCustomSnackBar("Share!");
                                },
                                child: Image.asset(AppImages.share2))
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
