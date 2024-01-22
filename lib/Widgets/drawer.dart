import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Views/AddPackageGuard/add_packgard.dart';
import 'package:packageguard/Views/Home_Screen/home_screen.dart';
import 'package:packageguard/Views/Register/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
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
int selectedIndex=0;
bool logoutPressed = false;
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
    getTileIndex();
  
  }

 Future<void> getTileIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
    selectedIndex = prefs.getInt('selected') ?? 1;
    });
  }

Future<void> setIndex(int index)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('selected',index);
  
}

  RemoveToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  RemoveUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(userData['uid']);
  }

  Future<void> logout() async {
    RemoveToken();
    RemoveUser();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove("email");
    Future.delayed(Duration(seconds: 3), () {
      Get.off(() => SignIn());
    });
  }

  @override
  Widget build(BuildContext context) {
    print('selected index: $selectedIndex');
    final profileImage = userData['ProfileImage'].toString().trim();
    String name = userData['Name'] ?? "User";
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 180,
            child: DrawerHeader(
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: AppColors.navyblue,
              ),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.navyblue,
                ),
                margin: EdgeInsets.only(top: 3),
                accountName: CustomText(
                  title: name,
                  fontSize: name.length > 13 ? 12.sp : 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                accountEmail: SizedBox(
                  height: 190,
                  child: CustomText(
                    title: '${userData['Email'] ?? "UserEmail"}',
                    fontSize: name.length > 13 ? 10.sp : 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                currentAccountPictureSize: Size.square(50),
                currentAccountPicture: CircleAvatar(
                  radius: 30.r,
                  child: ClipOval(
                    child: Image.network(
                      profileImage,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons
                          .person_2_outlined), // Use the network URL directly
                      height: 50.h,
                      width: 50.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            splashColor: Colors.blue,
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
            setIndex(0);
              Get.off(() => ProfilePage());
              // Navigator.pop(context);
            },
            enabled: true,
            selected: selectedIndex == 0,
            selectedTileColor: AppColors.navyblue,
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
                        setIndex(1);


              Get.off(() => HomeScreen());

              // Navigator.pop(context);
            },
            enabled: true,
            selected: selectedIndex == 1,
            selectedTileColor: AppColors.navyblue,
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
                       setIndex(2);


              Get.off(() => EditSafeCircle());
            },
            enabled: true,
            selected: selectedIndex == 2,
            selectedTileColor: AppColors.navyblue,
          ),
          ListTile(
            leading: Icon(
              Icons.notifications_on_rounded,
              size: 25.sp,
              color: AppColors.grey,
            ),
            title: CustomText(
              title: "Notifications",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
              setIndex(3);
          
              Get.off(() => SafeCircleNotification());
            },
            enabled: true,
            selected: selectedIndex == 3,
            selectedTileColor: AppColors.navyblue,
          ),
          ListTile(
            leading: Icon(
              Icons.add_box_rounded,
              size: 25.sp,
              color: AppColors.grey,
            ),
            title: CustomText(
              lines: 3,
              title: "Add a package guard",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
                       setIndex(4);

              Get.off(() => AddPackageGuard());
            },
            enabled: true,
            selected: selectedIndex == 4,
            selectedTileColor: AppColors.navyblue,
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
            onTap: () async {
                        setIndex(5);
                        logoutPressed=true;
                        

              Get.dialog(Center(
                child: CircularProgressIndicator(
                  backgroundColor: AppColors.navyblue,
                  color: Colors.white,
                  strokeWidth: 10,
                ),
              ));
              await logout();
            },
            enabled: true,
            selected: logoutPressed,
            selectedTileColor: AppColors.navyblue,
          ),
        ],
      ),
    );
  }
}
