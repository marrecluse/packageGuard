// ignore_for_file: unused_import

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:packageguard/Views/AddSafePerson/addsafe_circleperson.dart';
import 'package:packageguard/Views/AddSafePerson/firebase_pushnotification.dart';
import 'package:packageguard/Views/EditSafeCircle/edit_safecircle.dart';
import 'package:packageguard/Views/Home_Screen/components/add_package_gaurd.dart';
import 'package:packageguard/Views/Home_Screen/components/notification_section.dart';
import 'package:packageguard/Views/Home_Screen/home_screen.dart';
import 'package:packageguard/Views/Profile_Page/profile_page.dart';
import 'package:packageguard/Views/Register/register.dart';
import 'package:packageguard/Views/User_Notification/user_notification.dart';
import 'package:packageguard/push_notifiy.dart';
import 'Views/Login/login.dart';
import 'Views/Splash_Screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await Firebase.initializeApp(
  //   options: FirebaseOptions(
  //     apiKey: 'AIzaSyDTAM0nUnbpCjQ5opm63QFCu2xermvfFxI',
  //     appId: '1:1025977464909:android:f12401f597a37f16240404',
  //     messagingSenderId: '1025977464909	',
  //     projectId: 'packageguard-d517e',
  //     databaseURL:
  //         'https://packageguard-d517e-default-rtdb.asi a-southeast1.firebasedatabase.app/',
  //   ),
  // );
  // await pushNotification().initNotifications();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.instance.getToken().then((fcmToken) {
    print("FCM Token: $fcmToken");
  });

  //  FirebaseAppCheck.instance.activate(webRecaptchaSiteKey: 'YOUR_RECAPTCHA_SITE_KEY');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 844),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Place Packages",
          home: SplashScreen(),
          initialBinding: BindingsBuilder(
            () {
              Get.lazyPut(() => UserController());
              Get.lazyPut(() => UserUidController());
            },
          ),
        );
      },
    );
  }
}
