import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import '../../Utils/app_constants.dart';
import '../../Widgets/custom_sized_box.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/custom_text_foam_field.dart';
import '../../Widgets/drawer.dart';
import '../AddPackageGuard/add_packgard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../EditSafeCircle/edit_safecircle.dart';
import '../Login/login.dart';

class EditSafeCircleMain extends StatefulWidget {
  final String name;
  final String email;
  // final String image;

  EditSafeCircleMain({required this.name, required this.email, Key? key})
      : super(key: key);

  @override
  State<EditSafeCircleMain> createState() => _EditSafeCircleMainState();
}

class _EditSafeCircleMainState extends State<EditSafeCircleMain> {
  File? imageFile;

  getFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
    setState(() {});
  }

  getFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);

      print('IMAGW : $imageFile');
    }
    setState(() {});
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final userController = Get.find<UserController>();

// Access user data
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
    nameController.text = widget.name;

    userData = userController.userData as Map<String, dynamic>;
    print(userData);
    print(userData['ProfileImage']);
  }

  Future<void> updateSafePersonInFirestore(String originalName,
      String originalEmail, String newName, String newEmail) async {
    final userRef =
        FirebaseFirestore.instance.collection('safeCircle').doc(widget.name);

    // Check if the document exists
    final docSnapshot = await userRef.get();

    if (docSnapshot.exists) {
      // Update the user's data in Firestore
      await userRef.update({
        'name': newName,
        'email': newEmail,
      });
    } else {
      // Handle the case where the document doesn't exist
      print("Document not found: ${widget.name}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = userData['ProfileImage'].toString().trim();
    return SafeArea(
        child: Scaffold(
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              image: profileImage,
              title: '${userData['Name']}',
            ),
            Container(
              width: 358.w,
              //  height: 336.h,
              decoration: ShapeDecoration(
                color: const Color(0x2B15508D),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.w, color: const Color(0x7F15508D)),
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title: 'Safe Circle',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyblue,
                    ),
                    CustomSizeBox(height: 20.h),
                    Row(
                      children: [
                        CustomSizeBox(width: 20.w),
                        Image.asset(
                          AppImages.vector,
                          height: 120.h,
                        ),
                        CustomText(
                          title:
                              'Join your neighbor’s Safe Circle\nand have them join yours. The\nwhole street then becomes\npackage guardians.',
                          fontSize: 10.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        )
                      ],
                    ),
                    CustomSizeBox(
                      height: 15.h,
                    ),
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                                title: 'Name',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyblue),

                            CustomSizeBox(
                              width: 13.w,
                            ),

                            Container(
                              width: 225.w,
                              height: 35.h,
                              decoration: ShapeDecoration(
                                color: AppColors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4).r),
                                shadows: [
                                  BoxShadow(
                                    color: const Color(0x3F000000),
                                    blurRadius: 5.r,
                                    offset: const Offset(0, 0),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      left: 10.w, bottom: 15.h, right: 10.w),
                                  hintText: 'Name',
                                  hintStyle: TextStyle(
                                      color: AppColors.grey, fontSize: 13.sp),
                                  border: InputBorder.none,
                                ),
                              ),
                            )
                            //   Expanded(child:
                            // //  CustomTextFoamField()
                            //   ),
                          ],
                        ),
                        CustomSizeBox(height: 10.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                                title: 'Email',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyblue),
                            CustomSizeBox(
                              width: 15.w,
                            ),

                            Container(
                              width: 225.w,
                              height: 35.h,
                              decoration: ShapeDecoration(
                                color: AppColors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4).r),
                                shadows: [
                                  BoxShadow(
                                    color: const Color(0x3F000000),
                                    blurRadius: 5.r,
                                    offset: const Offset(0, 0),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      left: 10.w, bottom: 15.h, right: 10.w),
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                      color: AppColors.grey, fontSize: 13.sp),
                                  border: InputBorder.none,
                                ),
                              ),
                            )
                            // Expanded(child: CustomTextFoamField()),
                          ],
                        ),
                        CustomSizeBox(height: 10.w),
                        // Container(
                        //   width: 100.0, // Set your desired width
                        //   height: 100.0, // Set your desired height
                        //   child: CircleAvatar(
                        //     child: Image.network(widget.image),
                        //   ),
                        // ),
                        Row(
                          children: [
                            imageFile == null
                                ? GestureDetector(
                                    onTap: () {
                                      showOptionsDialog(context);
                                    },
                                    child: CustomText(
                                        title: 'Choose Photo',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navyblue),
                                  )
                                : Container(
                                    height: 50.h,
                                    width: 50.w,
                                    child: Image.file(
                                      File(imageFile!.path),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                            CustomSizeBox(width: 40.w),
                            GestureDetector(
                              onTap: () {
                                AppConstants.showCustomSnackBar(
                                    "Image uploaded");
                              },
                              child: Container(
                                height: 35.h,
                                width: 80.w,
                                decoration: BoxDecoration(
                                    color: AppColors.navyblue,
                                    borderRadius: BorderRadius.circular(5.r)),
                                child: Center(
                                  child: CustomText(
                                    title: "Upload",
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.btntext,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () async {
                              if (emailController.text.isNotEmpty &&
                                  nameController.text.isNotEmpty) {
                                // Update data in Firestore
                                await updateSafePersonInFirestore(
                                    widget.name,
                                    widget.email,
                                    emailController.text,
                                    nameController.text);

                                // Show a snackbar
                                AppConstants.showCustomSnackBar(
                                    "Safe Circle Person updated!");

                                // Navigate back to the EditSafeCircle page
                                Navigator.pop(context);
                              } else {
                                // Handle the case where email or phone is empty
                                AppConstants.showCustomSnackBar(
                                    "Please fill in both email and phone.");
                              }
                            },
                            child: Container(
                              height: 30.h,
                              width: 80.w,
                              decoration: BoxDecoration(
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.circular(8.r)),
                              child: Center(
                                child: CustomText(
                                  title: "Update",
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            CustomSizeBox(height: 80.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const AddPackageGuard());
                },
                child: Container(
                  // height: 30.h,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  width: 390.w,
                  decoration: BoxDecoration(
                      color: AppColors.navyblue,
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Center(
                    child: CustomText(
                      title: "Access Phone Contact",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> showOptionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
              child: ListBody(
            children: [
              GestureDetector(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "From Camera",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  getFromCamera();
                  Navigator.pop(context);
                },
              ),
              Padding(padding: EdgeInsets.all(10.h)),
              GestureDetector(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "From Gallery",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  getFromGallery();
                  Navigator.pop(context);
                },
              ),
            ],
          )),
        );
      },
    );
  }
}
//
// Future<void> updateSafePersonInFirestore(String originalName, String originalPhone, String newName, String newPhone) async {
//   final userRef = FirebaseFirestore.instance.collection('safeCircle').doc(widget.name);
//
//   // Update the user's data in Firestore
//   await userRef.update({
//     'Added email': newName,
//     'phone': newPhone,
//   });
// }

