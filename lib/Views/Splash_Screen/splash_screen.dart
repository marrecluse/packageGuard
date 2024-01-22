import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:packageguard/Views/Home_Screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/app_images.dart';
import '../Login/login.dart';

class SplashScreen extends StatefulWidget {
 final String? storedEmail;
  final String? storedPassword;

  const SplashScreen({Key? key, this.storedEmail, this.storedPassword}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Map<String, dynamic> userData = {};
  String empty = '';
  List<Map<String, dynamic>> devices = [];
  var token;
  @override
  getToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('deviceToken');
  }

  void initState() {
    super.initState();
    isLogin(context);
    // isSaved();

    // Timer(
    //   const Duration(seconds: 3),
    //   () {
    //     getToken();
    //     Navigator.of(context).push(MaterialPageRoute(
    //         builder: (context) => token == null ? SignIn() : HomeScreen()));
    //   },
    // );
  }


void isSaved(){
if (widget.storedEmail != null && widget.storedPassword != null) {
            Get.offAll(() => HomeScreen());

}
else{
      Get.offAll(() => SignIn());

}  
}

  void isLogin(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    final userController = Get.find<UserController>(); // Get the controller
    final userUidController =
        Get.find<UserUidController>(); // Get the controller

    if (user != null) {
      Timer(Duration(seconds: 2), () async {
        if (user.uid != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            print("logged in user data: ${userData}");

            userUidController.setUID(user.uid);
            userController.setUserData(userData!);
          } else {
            print("UID is null,unable to fetch user data");
          }

          print(
              "going to Homescreen with the user: ${user.displayName} , ${user.email},${user.photoURL}");
          Get.offAll(() => HomeScreen());
        }
      });
    } else {
      print("Going to login screen");
      SchedulerBinding.instance.addPostFrameCallback((_) {

      Get.offAll(() => SignIn());
      });

    }
  }

  @override
  Widget build(BuildContext context) {
  
    return SafeArea(
        child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              AppColors.navyblue,
              AppColors.darkblue,
            ])),
        child: Center(
            child: Image.asset(
          AppImages.logo,
          height: 140.h,
        )),
      ),
    ));
  }
}
