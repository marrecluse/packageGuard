import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:packageguard/Views/Home_Screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/app_images.dart';
import '../Login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var token;
  @override
  getToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('deviceToken');
  }

  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () {
        getToken();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => token == null ? SignIn() : HomeScreen()));
      },
    );
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
