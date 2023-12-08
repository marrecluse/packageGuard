// ignore_for_file: dead_code

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Utils/app_constants.dart';
import 'package:packageguard/Views/Login/login.dart';
import 'package:path/path.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../Utils/app_images.dart';
import '../../../Widgets/custom_text.dart';
import 'safe_circle_container.dart';

class RealTimeData extends StatefulWidget {
  const RealTimeData({super.key});

  @override
  State<RealTimeData> createState() => _RealTimeDataState();
}

class _RealTimeDataState extends State<RealTimeData> {
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<DataSnapshot?> fetchdata() async {
    final databaseReference =
        await FirebaseDatabase.instance.ref().child('package_guard_info').get();

    try {
      print(databaseReference);
      print('hello');
    } catch (e) {
      print('some exception');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
              onPressed: () {
                fetchdata();
              },
              child: Text('fetch'))
        ],
      ),
    );
  }
}

// @override
// Widget build(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 15),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [

//         // SafeCircleContainer(
//         //   titleText:  'PACKAGE THEFT ALERT',
//         //   subTitleText:
//         //       'A package is being retrieved without authorization at:',
//         //   leadingImg: AppImages.redIcon,
//         //   containerColor: const Color(0xffC58888),
//         //   titleColor: const Color(0xffCE3333),
//         // ),

//         // SafeCircleContainer(
//         //   titleText: 'ALERT RESOLUTION',
//         //   subTitleText: 'Thank you. The package alarm has been silenced at:',
//         //   leadingImg: AppImages.checkMark,
//         //   containerColor: const Color(0xff8DC588),
//         //   titleColor: const Color(0xff009045),
//         // ),

//           Container(
//             height: 73,
//             margin: EdgeInsets.only(top: 5.h),
//             padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(9.r),
//               color: const Color(0xffD7E1EC),
//             ),
//             child: Row(
//               children: [
//                 Image.asset(AppImages.checkMark),
//                 SizedBox(width: 20.w),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomText(
//                       title:'You have been added to Benjamin’s Safe\nCircle for Package Protection',
//                       // title: notificationList[index]['notification'],
//                       fontSize: 10.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                     ),
//                     SizedBox(height: 5.h),
//                     // Container(
//                     //   height: 20,
//                     //   width: 73,
//                     //   child: CustomButton(
//                     //       btnText: 'Accept',
//                     //       onPressed: () {},
//                     //       btnColor: Color(0xff3FCE33)),
//                     // )
//                   ],
//                 )
//               ],
//             ),
//           ),
//       ]
//     ),
//   );
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 15),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SafeCircleContainer(
//           titleText: 'PACKAGE THEFT ALERT',
//           subTitleText:
//               'A package is being retrieved without authorization at:',
//           leadingImg: AppImages.redIcon,
//           containerColor: const Color(0xffC58888),
//           titleColor: const Color(0xffCE3333),
//         ),
//         SafeCircleContainer(
//           titleText: 'ALERT RESOLUTION',
//           subTitleText: 'Thank you. The package alarm has been silenced at:',
//           leadingImg: AppImages.checkMark,
//           containerColor: const Color(0xff8DC588),
//           titleColor: const Color(0xff009045),
//         ),

//         Container(
//           height: 73,
//           margin: EdgeInsets.only(top: 5.h),
//           padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(9.r),
//             color: const Color(0xffD7E1EC),
//           ),
//           child: Row(
//             children: [
//               Image.asset(AppImages.checkMark),
//               SizedBox(width: 20.w),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CustomText(
//                     title:
//                         'You have been added to Benjamin’s Safe\nCircle for Package Protection',
//                     fontSize: 10.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black,
//                   ),
//                   SizedBox(height: 5.h),
//                   // Container(
//                   //   height: 20,
//                   //   width: 73,
//                   //   child: CustomButton(
//                   //       btnText: 'Accept',
//                   //       onPressed: () {},
//                   //       btnColor: Color(0xff3FCE33)),
//                   // )
//                 ],
//               )
//             ],
//           ),
//         )
//       ],
//     ),
//   );
// }
