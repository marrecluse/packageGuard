import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Views/AddPackageGuard/add_packgard.dart';
import 'package:packageguard/Views/Home_Screen/home_screen.dart';
import 'package:packageguard/Views/Register/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Views/AddSafePerson/addsafe_circleperson.dart';
import '../Views/EditSafeCircle/edit_safecircle.dart';
import '../Views/Login/login.dart';
import '../Views/Profile_Page/profile_page.dart';
import '../Views/Safe_Circle_Notification/safe_circle_notification.dart';
import 'custom_text.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final userController = Get.find<UserController>();

// Access user data
  Map<String, dynamic> userData = {
    // 'ProfileImage': 'assets/images/profile_ar.jpg'
  };

  @override
  void initState() {
    super.initState();
    // Access user data in initState or another method
    userData = userController.userData as Map<String, dynamic>;
    print(userData);
    print(userData['ProfileImage']);
  }

  RemoveToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  RemoveUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(userData['uid']);
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = userData['ProfileImage'].toString().trim();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.navyblue),
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.navyblue),
              accountName: CustomText(
                title: '${userData['Name'] ?? "Email"}',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              accountEmail: CustomText(
                title: '${userData['Email'] ?? "User"}',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              currentAccountPictureSize: Size.square(50),
              currentAccountPicture: CircleAvatar(
                radius: 30.r,
                child: ClipOval(
                  child: Image.network(
                                          profileImage,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              Icon(Icons
                                                  .person_2_outlined), // Use the network URL directly
                                          height: 50.h,
                                          width: 50.h,
                                          fit: BoxFit.cover,
                                        ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              size: 25.sp,
              color: AppColors.grey,
            ),
            title: CustomText(
              title: "My Profile",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
              Get.off(() => ProfilePage());
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.home_filled,
              size: 25.sp,
              color: AppColors.grey,
            ),
            title: CustomText(
              title: "Home",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
              Get.off(() => HomeScreen());
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.person_add_alt_1,
              size: 25.sp,
              color: AppColors.grey,
            ),
            title: CustomText(
              title: "Safe Circle",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
              Get.off(() => EditSafeCircle());
            },
          ),
          ListTile(
            leading: Icon(
              Icons.notifications_on_rounded,
              size: 25.sp,
              color: AppColors.grey,
            ),
            title: CustomText(
              title: "Notification",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
              Get.off(() => SafeCircleNotification());
            },
          ),
          ListTile(
            leading: Icon(
              Icons.add_box_rounded,
              size: 25.sp,
              color: AppColors.grey,
            ),
            title: CustomText(
              title: "Add a package guard",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
              Get.off(() => AddPackageGuard());
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              size: 25.sp,
              color: AppColors.grey,
            ),
            title: CustomText(
              title: "Logout",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            onTap: () async{
              RemoveToken();
              RemoveUser();
              SharedPreferences pref = await SharedPreferences.getInstance();
            pref.remove("email");
              Get.off(() => SignIn());
            },
          ),
        ],
      ),
    );
  }
}
