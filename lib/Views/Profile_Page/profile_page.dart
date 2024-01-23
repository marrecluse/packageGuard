import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/app_constants.dart';
import '../../Utils/app_images.dart';
import '../../Widgets/custom_appbar.dart';
import '../../Widgets/custom_sized_box.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/custom_text_foam_field.dart';
import '../../Widgets/drawer.dart';
import '../../Widgets/label_text.dart';
import '../Login/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

bool onoff1 = true;
bool pushAllowed = true;
bool onoff2 = true;
bool onoff3 = true;
bool isLoader = false;

class _ProfilePageState extends State<ProfilePage> {
  File? imageFile;
  String imageUrl = '';
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
    }
    setState(() {});
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController cellPhoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController confirnPassController = TextEditingController();
  TextEditingController address2controller = TextEditingController();
  TextEditingController citycontroller = TextEditingController();
  TextEditingController statecontroller = TextEditingController();
  TextEditingController zipcontroller = TextEditingController();
  TextEditingController countrycontroller = TextEditingController();

  final userController = Get.find<UserController>();
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    userData = userController.userData as Map<String, dynamic>;
    print(userData);
    print(userData['ProfileImage']);

    nameController.text = userData['Name'] ??
        ''; // Use '??' to provide a default value if 'Name' is null
    emailController.text = userData['Email'] ?? '';
    passwordController.text = ''; // You might want to handle this differently
    confirnPassController.text =
        ''; // You might want to handle this differently
    cellPhoneController.text =
        userData['Cell phone'] ?? ''; // Adjust this to match your data
    addressController.text =
        userData['Address'] ?? ''; // Adjust this to match your data
    address2controller.text =
        userData['Address 2'] ?? ''; // Adjust this to match your data
    citycontroller.text =
        userData['City'] ?? ''; // Adjust this to match your data
    statecontroller.text =
        userData['State'] ?? ''; // Adjust this to match your data
    zipcontroller.text =
        userData['Zip code'] ?? ''; // Adjust this to match your data
    countrycontroller.text =
        userData['Country'] ?? ''; // Adjust this to match your data

    debugPrint("ssssss: ${nameController.text}");
  }

  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    final userController = Get.find<UserController>();
    final userUidController = Get.find<UserUidController>();
    final uuid =
        userUidController.uid.value; // Access the value inside RxString

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uuid)
          .update(updatedData);
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uuid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        print("User Data: $userData");

        // Update the GetX controller with the new data
        userController.setUserData(userData!);
      }

      AppConstants.showCustomSnackBar("Profile Saved!");
      Timer(Duration(seconds: 3), () {
        Get.toNamed('/home');
      });

      isLoader = false;
    } catch (e) {
      AppConstants.showCustomSnackBar("Profile Not Saved!");
      print("Error updating user profile: $e");
      // Handle the error as needed
      isLoader = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = userData['ProfileImage'].toString().trim();

    return SafeArea(
        child: Scaffold(
      drawer: MyDrawer(),
      body: Column(children: [
        CustomAppBar(
          image: profileImage,
          title: '${userData['Name'] ?? "User"}',
        ),
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
                        title: "User Profile",
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor,
                      ),
                    ),
                    LabelText(title: "Name"),
                    CustomSizeBox(height: 3.h),
                    CustomTextFoamField(
                      controller: nameController,
                      hintText: "Name",
                      suffixIcon: Icon(
                        Icons.edit,
                        size: 22.sp,
                        color: AppColors.grey,
                      ),
                    ),
                    CustomSizeBox(height: 10.h),
                    LabelText(title: "Email"),
                    CustomSizeBox(height: 3.h),
                    CustomTextFoamField(
                      controller: emailController,
                      hintText: "Email",
                      suffixIcon: Icon(
                        Icons.edit,
                        size: 22.sp,
                        color: AppColors.grey,
                      ),
                    ),
                    CustomSizeBox(height: 10.h),
                    LabelText(title: "Password"),
                    CustomSizeBox(height: 3.h),
                    CustomTextFoamField(
                      controller: passwordController,
                      hintText: "Password",
                      suffixIcon: Icon(
                        Icons.edit,
                        size: 22.sp,
                        color: AppColors.grey,
                      ),
                    ),
                    CustomSizeBox(height: 10.h),
                    LabelText(title: "Confirm Password"),
                    CustomSizeBox(height: 3.h),
                    CustomTextFoamField(
                      controller: confirnPassController,
                      hintText: "Confirm Password",
                      suffixIcon: Icon(
                        Icons.edit,
                        size: 22.sp,
                        color: AppColors.grey,
                      ),
                    ),
                    CustomSizeBox(height: 10.h),
                    LabelText(title: "Cell phone"),
                    CustomSizeBox(height: 3.h),
                    CustomTextFoamField(
                      controller: cellPhoneController,
                      hintText: "Cell phone",
                      suffixIcon: Icon(
                        Icons.edit,
                        size: 22.sp,
                        color: AppColors.grey,
                      ),
                    ),
                    CustomSizeBox(height: 10.h),
                    LabelText(title: "Address"),
                    CustomSizeBox(height: 3.h),
                    CustomTextFoamField(
                      controller: addressController,
                      hintText: "Address",
                      suffixIcon: Icon(
                        Icons.edit,
                        size: 22.sp,
                        color: AppColors.grey,
                      ),
                    ),
                    CustomSizeBox(height: 10.h),
                    LabelText(title: "Address 2"),
                    CustomSizeBox(height: 3.h),
                    CustomTextFoamField(
                      controller: address2controller,
                      hintText: "Address 2",
                      suffixIcon: Icon(
                        Icons.edit,
                        size: 22.sp,
                        color: AppColors.grey,
                      ),
                    ),
                    CustomSizeBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LabelText(title: "City"),
                              CustomSizeBox(height: 5.h),
                              CustomTextFoamField(
                                controller: citycontroller,
                                hintText: "City",
                                suffixIcon: Icon(
                                  Icons.edit,
                                  size: 22.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomSizeBox(width: 15.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LabelText(title: "State"),
                              CustomSizeBox(height: 5.h),
                              CustomTextFoamField(
                                controller: statecontroller,
                                hintText: "State",
                                suffixIcon: Icon(
                                  Icons.edit,
                                  size: 22.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    CustomSizeBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LabelText(title: "Zip Code"),
                              CustomSizeBox(height: 5.h),
                              CustomTextFoamField(
                                controller: zipcontroller,
                                hintText: "Zip Code",
                                suffixIcon: Icon(
                                  Icons.edit,
                                  size: 22.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomSizeBox(width: 15.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LabelText(title: "Country"),
                              CustomSizeBox(height: 5.h),
                              CustomTextFoamField(
                                controller: countrycontroller,
                                hintText: "Country",
                                suffixIcon: Icon(
                                  Icons.edit,
                                  size: 22.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    // SignUpRowComponent(),
                    CustomSizeBox(height: 10.h),
                    Row(
                      children: [
                        imageFile == null
                            ? GestureDetector(
                                onTap: () {
                                  showOptionsDialog(context);
                                },
                                child: LabelText(title: "Choose Photo"))
                            : Container(
                                height: 35.h,
                                width: 80.w,
                                child: Image.file(
                                  File(imageFile!.path),
                                  fit: BoxFit.fill,
                                ),
                              ),
                        CustomSizeBox(width: 40.w),
                        GestureDetector(
                          onTap: () {
                            AppConstants.showCustomSnackBar("Image uploaded");
                          },
                          child: Container(
                            height: 40.h,
                            width: 115.w,
                            decoration: BoxDecoration(
                                color: AppColors.navyblue,
                                borderRadius: BorderRadius.circular(5.r)),
                            child: Center(
                              child: CustomText(
                                title: "Upload",
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.btntext,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    CustomSizeBox(height: 10.h),

                    Row(
                      children: [
                        Container(
                          width: context.screenWidth *0.5,
                          child: CustomText(
                            lines: 2,
                            title: "Enable text message",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          activeColor: AppColors.green,
                          value: onoff1,
                          onChanged: (value) {
                            setState(() {
                              onoff1 = !onoff1;
                              pushAllowed = !pushAllowed;
                            });
                          },
                        )
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        Container(
                          width: context.screenWidth * 0.7,
                          child: CustomText(
                            title: "Enable push notification",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                            lines: 2,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          activeColor: AppColors.green,
                          value: onoff2,
                          onChanged: (value) {
                            setState(() {
                              onoff2 = !onoff2;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        Container(
                          width: context.screenWidth * 0.7,
                          child: CustomText(
                            lines: 2,
                            title: "Enable email notification",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          activeColor: AppColors.green,
                          value: onoff3,
                          onChanged: (value) {
                            setState(() {
                              onoff3 = !onoff3;
                            });
                          },
                        ),
                      ],
                    ),
                    CustomSizeBox(height: 30.h),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(198.w, 40.h),
                            backgroundColor: AppColors.green),
                        onPressed: () async {
                          isLoader = !isLoader;
                          if (imageFile != null) {
                            imageUrl = (await uploadImageToFirebaseStorage(
                                imageFile!))!;
                          }

                          final updatedData = {
                            'Name': nameController.text,
                            'Email': emailController.text,
                            'Cell phone': cellPhoneController.text,
                            'Address': addressController.text,
                            'Address 2': address2controller.text,
                            'City': citycontroller.text,
                            'State': statecontroller.text,
                            'Zip code': zipcontroller.text,
                            'Country': countrycontroller.text,

                            // Add other fields you want to update
                          };

                          updateUserProfile(updatedData);
                        },
                        child: isLoader
                            ? CircularProgressIndicator() // Show a loader when isLoading is true
                            : CustomText(
                                title: "Save",
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.btntext,
                              ),
                      ),
                    ),
                    CustomSizeBox(height: 10.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    ));
  }

  Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask;
      final String imageUrl = await storageReference.getDownloadURL();
      updateImage(imageUrl.toString());
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void updateImage(String imageUrl) async {
    final userUidController = Get.find<UserUidController>();
    final uuid =
        userUidController.uid.value; // Access the value inside RxString

    await FirebaseFirestore.instance.collection('users').doc(uuid).update({
      'ProfileImage': imageUrl,
    });
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
