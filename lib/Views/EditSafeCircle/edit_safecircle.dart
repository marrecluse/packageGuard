import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Views/EditSafeCircle/EditSafeCircle.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import 'package:packageguard/Widgets/custom_text.dart';

import '../../Utils/app_constants.dart';
import '../../Widgets/custom_sized_box.dart';
import '../../Widgets/drawer.dart';
import '../AddSafePerson/addsafe_circleperson.dart';
import '../Login/login.dart';

class SafeCircleUser {
  final String userName;
  final String userEmail;
  final String userImage;

  SafeCircleUser(
      {required this.userEmail,
      required this.userName,
      required this.userImage});
}

class EditSafeCircle extends StatefulWidget {
  const EditSafeCircle({super.key});

  @override
  State<EditSafeCircle> createState() => _EditSafeCircleState();
}

class _EditSafeCircleState extends State<EditSafeCircle> {
  List<SafeCircleUser> safeCircleUsers = [];

  @override
  void initState() {
    super.initState();
    // Fetch safe circle users from Firestore when the widget is initialized
    fetchSafeCircleUsers();
    userData = userController.userData as Map<String, dynamic>;
    print(userData);
    print(userData['ProfileImage']);
  }

  void fetchSafeCircleUsers() {
    User? user = FirebaseAuth.instance.currentUser;

    FirebaseFirestore.instance
        .collection('safeCircle')
        .doc(user?.uid)
        .collection('circlePersons')
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<SafeCircleUser> users = [];
      querySnapshot.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['userName'] as String?;
        final email = data['userEmail'] as String?;
        final image = data['image'] as String;

        // print(image);
        print(name);
        print(email);

        if (name != null && email != null) {
          // Create a SafeCircleUser object and add it to the list
          users.add(SafeCircleUser(
              userName: name, userEmail: email, userImage: image));
        }
      });

      setState(() {
        // Update the state with the fetched users
        safeCircleUsers = users;
      });
    }).catchError((error) {
      // Handle any potential errors here
      print("Error fetching SafeCircle data: $error");
    });
  }

  Future<void> deleteSafeCircleUser(String name, String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('safeCircle')
          .doc(user?.uid)
          .collection('circlePersons')
          .where('userName', isEqualTo: name)
          .where('userEmail', isEqualTo: email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

//to delete user notification
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(user?.uid)
          .collection('userNotification')
          .where('userEmail', isEqualTo: email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // await FirebaseFirestore.instance
      //     .collection('notifications')
      //      .doc(user?.uid)
      //     .collection('userNotification')

      //     .get
      //     .then((QuerySnapshot querySnapshot) {
      //   querySnapshot.docs.forEach((doc) {
      //     doc.reference.delete();

      //   });

      // });

      // After successfully deleting, refresh the list
      fetchSafeCircleUsers();
    } catch (error) {
      print("Error deleting Safe Circle user: $error");
    }
  }

  final userController = Get.find<UserController>();

// Access user data
  Map<String, dynamic> userData = {};

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
              title: '${userData['Name'] ?? 'User'}',
            ),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title: " SAFE CIRCLE",
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyblue,
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 456.h,
                    child: ListView.builder(
                      itemCount: safeCircleUsers.length,
                      itemBuilder: (context, index) {
                        final user = safeCircleUsers[index];

                        return Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            width: 358.w,
                            decoration: ShapeDecoration(
                              color: const Color(0x2B15508D),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 1.w, color: const Color(0x7F15508D)),
                                borderRadius: BorderRadius.circular(9.r),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 9.w, vertical: 9.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 27.r,
                                    child: ClipOval(
                                      child: Image.network(
                                        user.userImage
                                            .toString(), // Use the network URL directly
                                        height: 50.h,
                                        width: 50.h,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  CustomSizeBox(
                                    width: 13.w,
                                  ),

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        title: user.userName,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navyblue,
                                      ),
                                      CustomSizeBox(
                                        height: 3.h,
                                      ),
                                      CustomText(
                                        title: user.userEmail,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.grey,
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // Container(
                                  //   width: 100.0, // Set your desired width
                                  //   height: 100.0, // Set your desired height
                                  //   child: CircleAvatar(
                                  //     child: Image.network(user.image),
                                  //   ),
                                  // ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(
                                            () => EditSafeCircleMain(
                                              name: user.userName,
                                              email: user.userEmail,
                                            ),
                                          );
                                          AppConstants.showCustomSnackBar(
                                              "You can edit now!");
                                        },
                                        child: CircleAvatar(
                                            radius: 14.r,
                                            backgroundColor: AppColors.grey,
                                            child: Icon(
                                              Icons.edit,
                                              color: AppColors.white,
                                              size: 18.sp,
                                            )),
                                      ),
                                      CustomSizeBox(
                                        width: 10.w,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Delete User"),
                                                content: Text(
                                                    "Are you sure you want to delete this user?"),
                                                actions: [
                                                  TextButton(
                                                    child: Text("Cancel"),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text("Delete"),
                                                    onPressed: () {
                                                      // Call the delete function here with the user's phone number
                                                      deleteSafeCircleUser(
                                                          user.userName,
                                                          user.userEmail);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 14.r,
                                          backgroundColor: AppColors.mahron,
                                          child: Icon(
                                            Icons.delete,
                                            color: AppColors.white,
                                            size: 18.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                  SizedBox(height: 30.h),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const AddSafePerson());
                    },
                    child: Container(
                      // height: 30.h,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      width: 393.w,
                      decoration: BoxDecoration(
                          color: AppColors.navyblue,
                          borderRadius: BorderRadius.circular(8.r)),
                      child: Center(
                        child: CustomText(
                          title: "Add Safe Circle Person",
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.btntext,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
