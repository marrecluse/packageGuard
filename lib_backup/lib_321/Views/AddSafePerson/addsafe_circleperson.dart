import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
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

class AddSafePerson extends StatefulWidget {
  const AddSafePerson({super.key});

  @override
  State<AddSafePerson> createState() => _AddSafePersonState();
}

class _AddSafePersonState extends State<AddSafePerson> {


 final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();


  File? imageFile;

 void sendMail({
    required String recipientEmail,
    required String mailMessage,
  }) async {
    // change your email here
    String username = 'danijakhar11@gmail.com';
    // change your password here
    String password = 'wxlthhhlaljgojjb';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = 'Mail '
      ..text = 'Message: $mailMessage';

    try {
      await send(message, smtpServer);
      showSnackbar('Email sent successfully');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void addPerson() async{
    if (emailController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                                // Add data to Firestore
                                await addSafePersonToFirestore(emailController.text, phoneController.text);

                                // Show a snackbar
                                AppConstants.showCustomSnackBar("Safe Circle Person added!");

                                // Navigate to the EditSafeCircle page
                                Get.to(() => EditSafeCircle());
                              } else {
                                // Handle the case where email or phone is empty
                                AppConstants.showCustomSnackBar("Please fill in both email and phone.");
                              }
  }









void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: FittedBox(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }









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



  Future<void> addSafePersonToFirestore(String phone, String addedEmail) async {
    String imageUrl = ''; // Initialize imageUrl with an empty string
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final adminEmail = user.email; // Get the user's email
        if (imageFile != null) {
          imageUrl = (await uploadImageToFirebaseStorage(imageFile!))!;
        }
        if (adminEmail != null) {
          final safeCircleData = {
            'User email': adminEmail, // Add user's email
            'Added email':  phone, // Add the email from the input field
            'phone': addedEmail,
            'Image':imageUrl
          };

          final firestore = FirebaseFirestore.instance;
          await firestore.collection('safeCircle').add(safeCircleData);
          AppConstants.showCustomSnackBar("Safe Circle Person added!");
        } else {
          AppConstants.showCustomSnackBar("Failed to get admin's email");
        }
      } else {
        AppConstants.showCustomSnackBar("User not logged in");
      }
    } catch (e) {
      print('Error adding data to Firestore: $e');
      AppConstants.showCustomSnackBar("Error adding data to Firestore");
    }
  }

  Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('SafeCircle_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask;
      final String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  final userController = Get.find<UserController>();

// Access user data
  Map<String, dynamic> userData = {};





  @override
  void initState() {
    super.initState();
    // Access user data in initState or another method
    userData = userController.userData as Map<String, dynamic>;
    print(userData);
    print(userData['ProfileImage']);


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
              image:profileImage,
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
                              width: 15.w,
                            ),


                            Container(
                  width: 225.w,
                  height: 35.h,
                  decoration: ShapeDecoration(
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4).r),
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
                      contentPadding: EdgeInsets.only(left: 2.w, bottom: 20.h, right: 10.w),
                      hintText: 'Email',

                      hintStyle: TextStyle(color: AppColors.grey, fontSize: 13.sp),

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
                                title: 'Phone',
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4).r),
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
                                controller: phoneController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 2.w, bottom: 20.h, right: 10.w),
                                  hintText: 'Phone',

                                  hintStyle: TextStyle(color: AppColors.grey, fontSize: 13.sp),

                                  border: InputBorder.none,
                                ),

                              ),
                            )
                            // Expanded(child: CustomTextFoamField()),
                          ],
                        ),
                        CustomSizeBox(height: 10.w),
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
                            onTap: () {
                              sendMail(
                    recipientEmail: emailController.text.toString(),
                    mailMessage: 'Welcome to safe circle'.toString(),
                  );



                              addPerson();                              
                            },
                            child: Container(
                              height: 30.h,
                              width: 80.w,
                              decoration: BoxDecoration(
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.circular(8.r)),
                              child: Center(
                                child: CustomText(
                                  title: "Add",
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
