import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_constants.dart';
import 'package:packageguard/Views/Forgot_Password/forgot_password.dart';
import 'package:packageguard/Views/Register/register.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../Utils/app_colors.dart';
import '../../Widgets/custom_sized_box.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/custom_text_foam_field.dart';
import '../../Widgets/label_text.dart';
import '../../Widgets/myapp_bar.dart';
import '../Home_Screen/home_screen.dart';

// import '../Wifi_Connect/wifi_connect.dart';



class UserController extends GetxController {
  final RxMap<String, dynamic> userData = RxMap<String, dynamic>();

  void setUserData(Map<String, dynamic> data) {
    userData.assignAll(data);
  }
}

class UserUidController extends GetxController {
  RxString uid = ''.obs;

  void setUID(String newUID) {
    uid.value = newUID;
  }
}

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
   String deviceToken='';
   String? email='';
   String? tokenUserId ='';

Future<void> saveDeviceToken(String inputEmail) async{

   FirebaseMessaging.instance.getToken().then((fcmToken) {
    deviceToken = fcmToken.toString();
    debugPrint(deviceToken);

});


  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('Email' ,isEqualTo: inputEmail)
        .get();

    querySnapshot.docs.forEach((doc) async {
      final data = doc.data() as Map<String, dynamic>;
      tokenUserId = doc.id;
      email = data['userEmail'] as String?;

  
    });

final tokenData ={
  'deviceToken':deviceToken,

};


await FirebaseFirestore.instance.collection("users").doc(tokenUserId).update(tokenData);

}


  Future<void> signIn() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance; // Initialize Firestore
    final userController = Get.find<UserController>(); // Get the controller
    final userUidController = Get.find<UserUidController>(); // Get the controller


    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Sign-in was successful, navigate to the next page.
      Get.to(() => const HomeScreen());

      // You might want to show a success snackbar here.
      AppConstants.showCustomSnackBar("Welcome Back!");

      // Retrieve the user's data from Firestore based on UID
      final uid = userCredential.user?.uid;

      if (uid != null) {


        final userDoc = await firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          print("User Data: $userData");


          userUidController.setUID(uid); // Call setUID on UserUidController
          // Save user data to the controller
          userController.setUserData(userData!);
        } else {
          print("User document not found in Firestore");
        }
      } else {
        print("UID is null, unable to fetch user data from Firestore");
      }
    } catch (e) {
      // Sign-in failed, handle the error here.
      print("Sign-in error: $e");

      // Example: Show an error snackbar with GetX.
      Get.snackbar(
        'Sign-In Error',
        'Please check your credentials',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(children: [
        const MyAppBar(),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CustomText(
                        title: "Sign In",
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                   



                    CustomSizeBox(height: 21.h),
                    LabelText(title: "Email"),
                    CustomSizeBox(height: 5.h),
                    CustomTextFoamField(
                      controller: emailController,
                      hintText: "Email",



                    ),
                    CustomSizeBox(height: 10.h),
                    LabelText(title: "Password"),
                    CustomSizeBox(height: 5.h),
                    CustomTextFoamField(

                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true, // Enable password obscuring
                    ),
                    CustomSizeBox(height: 12.h),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => const ForgotPassword());
                        },
                        child: CustomText(

                          title: "Forgot Password?",
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    CustomSizeBox(height: 29.h),
                    Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            
                              fixedSize: Size(198.w, context.screenWidth >900 ? 80.h : 60.h),
                              backgroundColor: AppColors.green),
                        onPressed: () async {
                          signIn();
                          saveDeviceToken(emailController.text);

                        },


                          child: CustomText(
                            title: "Login",
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            
                            color: AppColors.btntext,
                          )),
                    ),
                    CustomSizeBox(height: 10.h),
                    Center(
                        child: CustomText(
                      title: "or",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    )),
                    CustomSizeBox(height: 10.h),
                    GestureDetector(
                      onTap: () {

                        Get.to(() => const SignUp());
                      },
                      child: Center(
                          child: CustomText(
                        title: "Create new account",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                                            )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ]),
    ));
  }
}
