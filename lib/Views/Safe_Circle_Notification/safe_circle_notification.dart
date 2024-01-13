import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Views/Safe_Circle_Notification/components/real_timedata.dart';
import 'package:packageguard/Views/Safe_Circle_Notification/components/safe_noticication%20_alerts2.dart';
import '../../Utils/app_colors.dart';
import '../../Widgets/custom_appbar.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/drawer.dart';
import '../Login/login.dart';
import 'components/safe_notification_alerts.dart';


class SafeCircleNotification extends StatefulWidget {
  const SafeCircleNotification({super.key});

  @override
  State<SafeCircleNotification> createState() => _SafeCircleNotificationState();
}

final userController = Get.find<UserController>();

// Access user data
Map<String, dynamic> userData = {};

class _SafeCircleNotificationState extends State<SafeCircleNotification> {

  @override
  void initState() {
    super.initState();
            final userController = Get.find<UserController>();

    // Access user data in initState or another method
    userData = userController.userData as Map<String, dynamic>;

    print(userData);
    print(userData['ProfileImage']);
  }
final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    Future<void> _refreshData() async {

    setState(() {
      initState();
    });
  }

  @override
  Widget build(BuildContext context) {
        final profileImage = userData['ProfileImage'].toString().trim();

    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: AppColors.navyblue,
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(
                  image: profileImage,
                  title: '${userData['Name']}',
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  child: CustomText(
                    title: 'Safe Circle Notification',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyblue,
                  ),
                ),
                // SafeNotificationAlerts()
                SizedBox(
                  height: 580.h,
                  width: MediaQuery.of(context).size.width,
                  // child: ListView.builder(
                  //   physics: const BouncingScrollPhysics(),
                  //   itemCount: 1,
                  //   itemBuilder: (context, index) {
                  //     return const SafeNOtificationsAlerts2();
                  //   },
                  // ),
                  child: Container(
                    child: SafeNOtificationsAlerts2(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
























// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:packageguard/Utils/app_images.dart';
// import 'package:packageguard/Views/Safe_Circle_Notification/components/real_timedata.dart';
// import 'package:packageguard/Views/Safe_Circle_Notification/components/safe_noticication%20_alerts2.dart';
// import '../../Utils/app_colors.dart';
// import '../../Widgets/custom_appbar.dart';
// import '../../Widgets/custom_text.dart';
// import '../../Widgets/drawer.dart';
// import '../Login/login.dart';
// import 'components/safe_notification_alerts.dart';

// class SafeCircleNotification extends StatefulWidget {
//   const SafeCircleNotification({super.key});

//   @override
//   State<SafeCircleNotification> createState() => _SafeCircleNotificationState();
// }

// final userController = Get.find<UserController>();

// // Access user data
// Map<String, dynamic> userData = {};

// class _SafeCircleNotificationState extends State<SafeCircleNotification> {
//   @override
//   void initState() {
//     super.initState();

//     userData = userController.userData as Map<String, dynamic>;
//     print(userData);
//     print(userData['ProfileImage']);
//   }

//   final profileImage = userData['ProfileImage'].toString().trim();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         drawer: MyDrawer(),
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CustomAppBar(
//               image: profileImage,
//               title: '${userData['Name'] ?? 'User'}',
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
//               child: CustomText(
//                 title: 'Safe Circle Notification',
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.navyblue,
//               ),
//             ),
//             SafeNOtificationsAlerts2()
//             // SizedBox(
//             //   height: 580.h,
//             //   width: MediaQuery.of(context).size.width,
//             //   child: ListView.builder(
//             //     physics: const BouncingScrollPhysics(),
//             //     itemCount: 4,
//             //     itemBuilder: (context, index) {
//             //       return const SafeNotificationAlerts();
//             //     },
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
