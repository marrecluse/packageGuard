import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_images.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/app_constants.dart';
import '../../Widgets/custom_appbar.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/drawer.dart';
import '../Home_Screen/home_screen.dart';
import '../Login/login.dart';



class WifiConnect extends StatefulWidget {
  const WifiConnect({super.key});

  @override
  State<WifiConnect> createState() => _WifiConnectState();
}

bool isPasswordVisible = false;

class _WifiConnectState extends State<WifiConnect> {


  final userController = Get.find<UserController>();

// Access user data
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    // Access user data in initState or another method
    userData = userController.userData as Map<String, dynamic>;

    // print(userData);
    // print(userData['ProfileImage']);
  }







  @override
  Widget build(BuildContext context) {

    final profileImage = userData['ProfileImage'].toString().trim();
    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              image:profileImage,
              title: '${userData['Name']}',
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 200.h,
                    child: Card(
                      color: Colors.blueGrey.shade100,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 10.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              title: 'Available Networks',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyblue,
                            ),
                            SizedBox(height: 13.h),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  AppImages.wifiImg,
                                                  height: 17.h,
                                                  width: 17.w,
                                                ),
                                                SizedBox(
                                                  width: 8.w,
                                                ),
                                                CustomText(
                                                  title: "Micheal’s wifi",
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.black,
                                                ),
                                              ],
                                            ),
                                            CustomText(
                                              title: 'Connected',
                                              color: AppColors.navyblue,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10.sp,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        Divider(thickness: 1.w),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  GestureDetector(
                    onTap: () {
                      buildShowDialog(context);
                    },
                    child: CustomText(
                      title: 'Add manually',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyblue,
                    ),
                  ),
                  SizedBox(
                    height: 290.h,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() =>  HomeScreen());
                    },
                    child: Container(
                      // height: 35.h,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      width: 393.w,
                      decoration: BoxDecoration(
                          color: AppColors.navyblue,
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Center(
                        child: CustomText(
                          title: "Connect Another Wifi",
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // const AvailableNetworks(),
          ],
        ),
      ),
    );
  }

  void buildShowDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: 17.w,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
            ),
            height: 270.h,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.h),
                CustomText(
                  title: 'Add Wifi',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "SSID",
                    hintStyle: TextStyle(fontSize: 12.sp),
                  ),
                ),
                TextFormField(
                  obscureText: isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(fontSize: 12.sp),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      activeColor: AppColors.navyblue,
                      value: isPasswordVisible,
                      onChanged: (bool? value) {
                        setState(() {
                          isPasswordVisible = value!;
                        });
                      },
                    ),
                    SizedBox(width: 8.w),
                    CustomText(
                      title: 'Show Password',
                      color: const Color(0xff252525),
                      fontWeight: FontWeight.w400,
                      fontSize: 10.sp,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: CustomText(
                        title: 'Cancel',
                        color: const Color(0xff252525),
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppConstants.showCustomSnackBar("Connected!");
                        Navigator.pop(context);
                      },
                      child: Container(
                        // height: 30.h,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        width: 80.w,
                        decoration: BoxDecoration(
                            color: AppColors.navyblue,
                            borderRadius: BorderRadius.circular(8.r)),
                        child: Center(
                          child: CustomText(
                            title: "Connect",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.btntext,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
