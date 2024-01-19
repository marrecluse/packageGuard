// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_local_variable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Views/profile_image_service.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'package:packageguard/Utils/app_constants.dart';
import 'package:packageguard/Views/DeviceDetails/device_detail.dart';
import 'package:packageguard/Views/Forgot_Password/forgot_password.dart';
import 'package:packageguard/Views/Register/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isLoggedIn = false;
  Map _userObj = {};

  String? googleUserImage;
  bool isLoading = false; // Initially, the button is not in loading state
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? deviceToken = '';
  Map<String, dynamic> userData = {};
  getCredentials() {
    userData = userController.userData as Map<String, dynamic>;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        deviceToken = token;
      });
      print("your device token is ${deviceToken}");
    });
  }

  storeTheToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceToken', '${deviceToken}');
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(
            backgroundColor: AppColors.navyblue,
            color: Colors.white,
            strokeWidth: 10,
          ),
          Container(margin: EdgeInsets.only(left: 5), child: Text("Loading")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // void _handleGoogleSignIn() async {
  //   final firestore = FirebaseFirestore.instance; // Initialize Firestore
  //   final userController = Get.find<UserController>(); // Get the controller
  //   final userUidController =
  //       Get.find<UserUidController>(); // Get the controller

  //   try {
  //     GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
  //     UserCredential userCredential =
  //         await _auth.signInWithProvider(_googleAuthProvider);
  //     User? user = userCredential.user;
  //     await firestore.collection('users').doc(user?.uid).update({
  //       'deviceToken': deviceToken,
  //     });

  //     Get.toNamed(
  //       '/home',
  //       arguments: userCredential,
  //     );
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images')
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

  Future<void> _handleFacebookSignIn() async {
    final userController = Get.find<UserController>();
    final userUidController =
        Get.find<UserUidController>(); // Get the controller
    try {
      final LoginResult result = await FacebookAuth.instance.login(
    permissions: ['email', 'public_profile'],
      
      );
      if (result.status == LoginStatus.success) {

        print('Logged in using Facebook');
        print('Result: }');

        // Authenticate with Firebase using Facebook access token
        final AuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

//Get facebook user data

        final fbUserData = await FacebookAuth.instance.getUserData(
        fields: "name,email,picture.width(200)",
        );
        print('fb user: $fbUserData');
// Console output for this:
// fb user: {name: M Abdul Rehman, email: danijakhar11@gmail.com, picture: {data: {height: 201, is_silhouette: false, url: https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=223327424169414&width=200&ext=1708236888&hash=Afq5k082PjQ__CY0Z2LY14sYhSxyRX6m4Y2thabxsUum-A, width: 200}}, id: 223327424169414}

        final fb_uid = userCredential.user!.uid;
        print('fb uid $fb_uid');

// Extracting fb user data:

        String fb_name = fbUserData['name'] ?? '';
        String fb_email = fbUserData['email'] ?? '';

        //for picture
      final fb_pictureData = fbUserData['picture'];
        String fb_picture = fb_pictureData['data']['url'] ?? '';

        final fb_userData = {
          'Name': fb_name,
          'Email': fb_email,
          'phoneNumber': '',
          'Address': '',
          'City': '',
          'State': '',
          'Cell phone': '',
          'Zip code': '',
          'deviceToken': deviceToken,
          'Country': '',
          'ProfileImage': fb_picture,
          'uid': fb_uid,
          'method': 'facebook'
        };
//make firestore user collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(fb_uid)
            .set(fb_userData);

//Store data in controller:

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(fb_uid)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          userUidController.setUID(fb_uid);
          userController.setUserData(userData!);
        }
        else{
          debugPrint('fb UserDoc does not exists');
        }

        Get.offAll(() => const HomeScreen());



      } else {
        print('Login Failed');
      }
    } catch (e) {
      print('Facebook Login exception: $e');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance; // Initialize Firestore
    final userController = Get.find<UserController>(); // Get the controller
    final userUidController =
        Get.find<UserUidController>(); // Get the controller

    try {
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
      UserCredential userCredential =
          await _auth.signInWithProvider(_googleAuthProvider);
      User? user = userCredential.user!;
      AdditionalUserInfo? userProfile = userCredential.additionalUserInfo;

      if (userProfile != null && userProfile.profile != null) {
        googleUserImage = userProfile.profile!['picture'] as String?;

        if (googleUserImage != null) {
          print('Google User Image: $googleUserImage');
          // Use googleUserImage where needed
        } else {
          print('Picture URL not found');
        }
      } else {
        print('Profile information not available');
      }

      await user?.updateProfile(displayName: user.displayName);

      // await firestore.collection('users').doc(user?.uid).update({
      //   'deviceToken': deviceToken,
      // });
      final uid = userCredential.user?.uid;
      print("Google user: $user");
      print("GoogleUser Credentials: $userCredential");

      String? uName = user?.displayName;
      String? uEmail = user?.email;
      String? uPhoto = user?.photoURL;

      if (uPhoto != null) {
        print('Photo URL: $uPhoto');
      } else {
        print('Photo URL not available');
      }
      if (uName != null) {
        print('Google user name: $uName');
      } else {
        print('Google user name not available');
      }
      if (uEmail != null) {
        print('uEmail : $uEmail');
      } else {
        print('uEmail not available');
      }

      final userData = {
        'Name': user.displayName,
        'Email': user.email,
        'phoneNumber': '',
        'Address': '',
        'City': '',
        'State': '',
        'Cell phone': '',
        'Zip code': '',
        'deviceToken': deviceToken,
        'Country': '',
        'ProfileImage': googleUserImage,
        'uid': uid,
        'method': 'emailAndPass'

        // Use imageUrl directly
      };
      await firestore.collection('users').doc(uid).set(userData);

      // Sign-in was successful, navigate to the next page.

      // Retrieve the user's data from Firestore based on UID

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

      Get.offAll(() => const HomeScreen());

      // You might want to show a success snackbar here.
      AppConstants.showCustomSnackBar("Welcome Back!");
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

  Future<void> signIn() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance; // Initialize Firestore
    final userController = Get.find<UserController>(); // Get the controller
    final userUidController =
        Get.find<UserUidController>(); // Get the controller

    try {
      print("in SignIN()");
      final UserCredential userCredential =
          await auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      print("user credentials: $userCredential");
      User? user = userCredential.user;
      print("user is: $user");

      await firestore.collection('users').doc(user?.uid).update({
        'deviceToken': deviceToken,
      });
      print("user credentials: $deviceToken");

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
          Get.offAll(() => const HomeScreen());
          print("after HomeScreen");
          // You might want to show a success snackbar here.
          AppConstants.showCustomSnackBar("Welcome Back!");
        } else {
          print("User document not found in Firestore");
        }
      } else {
        print("UID is null, unable to fetch user data from Firestore");
      }

      // Sign-in was successful, navigate to the next page.
    } catch (e) {
      // Sign-in failed, handle the error here.
      print("Sign-in error: $e");
      setState(() {
        isLoading = false;
      });
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
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
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
                    SizedBox(
                      height: 12,
                    ),
                    isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                            backgroundColor: AppColors.navyblue,
                            color: Colors.white,
                            strokeWidth: 10,
                          ))
                        : SizedBox(),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(AppColors.green),
                        ),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          signIn();
                          storeTheToken();
                          getCredentials();
                        },
                        child: CustomText(
                          title: "Submit",
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.btntext,
                        ),
                      ),
                    ),
                    CustomSizeBox(height: 10.h),
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
                    _isLoggedIn
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_userObj["name"] ?? ''),
                              Text(_userObj["email"] ?? ''),
                              TextButton(
                                  onPressed: () {
                                    FacebookAuth.instance
                                        .logOut()
                                        .then((value) {
                                      setState(() {
                                        _isLoggedIn = false;
                                        _userObj = {};
                                      });
                                    });
                                  },
                                  child: Text("Logout"))
                            ],
                          )
                        : SizedBox(),
                    SizedBox(
                      height: context.screenWidth * 0.09,
                    ),
                    Center(
                        child: CustomText(
                      title: "or",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    )),
                    Center(
                        child: CustomText(
                      title: "Login with:",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    )),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              _handleGoogleSignIn();

                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              pref.setString("email", _user!.email!);
                            },
                            child: Container(
                                child: Image.asset(
                              AppImages.google,
                              height: 40.sp,
                              width: 40.sp,
                            )),
                          ),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              _handleFacebookSignIn();
                              // FacebookAuth.instance.login(permissions: [
                              //   "public_profile",
                              //   "email"
                              // ]).then((value) {
                              //   FacebookAuth.instance
                              //       .getUserData()
                              //       .then((userData) async {
                              //     setState(() {
                              //       _isLoggedIn = true;
                              //       _userObj = userData;
                              //     });
                              //   });
                              // });
                            },
                            child: Container(
                                child: Image.asset(
                              AppImages.facebook,
                              height: 40.sp,
                              width: 40.sp,
                            )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: context.screenWidth * 0.1,
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
