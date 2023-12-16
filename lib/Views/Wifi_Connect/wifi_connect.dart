import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Views/AddPackageGuard/Bluetooth.dart';
import 'package:packageguard/Views/Wifi_Connect/wifi_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/app_constants.dart';
import '../../Widgets/custom_appbar.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/drawer.dart';
import '../Login/login.dart';
import 'package:get/get.dart';

class ConnectedDevicesController extends GetxController {
  RxMap connectedDevices = {}.obs;

  void updateConnectedDevice(String ssid, bool isConnected) {
    connectedDevices[ssid] = isConnected;
    print('the connected device is ${connectedDevices[ssid]}');
    print('Devices are $connectedDevices');
  }
}

class WifiController extends GetxController {
  final title = "**EMPTY**".obs;
  final RxList<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[].obs;
  final RxList<dynamic> ssidList = <dynamic>[].obs; // New list for SSIDs

  void updateTitle(List<WiFiAccessPoint> ssid) {
    ssidList.assignAll(ssid.map((ap) => ap.ssid)); // Update the SSID list
    title.value = ssidList.join(', '); // Concatenate SSIDs for the title
    accessPoints.assignAll(ssid);

    print('My name is $title');
  }
}

// class Controller extends GetxController {
//   RxString connectedWifiTitle = ''.obs;

//   setConnectedWifiTitle(String title, bool bool) {
//     connectedWifiTitle.value = title;
//   }
// }

class WifiConnect extends StatefulWidget {
  const WifiConnect({super.key});

  @override
  State<WifiConnect> createState() => _WifiConnectState();
}

bool isPasswordVisible = false;
List? wifiTitle;

class _WifiConnectState extends State<WifiConnect> {
  final ConnectedDevicesController _controller =
      Get.find<ConnectedDevicesController>();
  late BuildContext listViewContext;
  late BluetoothController bluetoothController;
  late WifiController? wifiController;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;

  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final userController = Get.find<UserController>();

  // final TextEditingController _ssidController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();

  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  final List<dynamic> ssidList = <dynamic>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;

  bool shouldCheckCan = true;

  bool get isStreaming => true;

  String userId = '';

  User? user;

  // New list for SSIDs

  String token = '';
  Future<void> _startScan(BuildContext context) async {
    // check if "can" startScan
    if (shouldCheckCan) {
      // check if can-startScan
      final can = await WiFiScan.instance.canStartScan();
      // if can-not, then show error
      if (can != CanStartScan.yes) {
        if (mounted) kShowSnackBar(context, "Cannot start scan: $can");
        return;
      }
    }

    // call startScan API
    final result = await WiFiScan.instance.startScan();
    // if (mounted) kShowSnackBar(context, "startScan: $result");
    // reset access points.
    setState(() => accessPoints = <WiFiAccessPoint>[]);
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (shouldCheckCan) {
      // check if can-getScannedResults
      final can = await WiFiScan.instance.canGetScannedResults();
      // if can-not, then show error
      if (can != CanGetScannedResults.yes) {
        if (mounted) kShowSnackBar(context, "Cannot get scanned results: $can");
        accessPoints = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }

  Future<void> _getScannedResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      // get scanned results
      final results = await WiFiScan.instance.getScannedResults();
      setState(() => accessPoints = results);
      print('$results are there');
    }
  }

  final WifiController wificontroller = Get.find();
  // final Controller controller = Get.find();

  Future<void> _startListeningToScanResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      subscription = WiFiScan.instance.onScannedResultsAvailable.listen(
        (result) {
          // Update the GetX controller with the new list
          Get.find<WifiController>().updateTitle(result);
          print('the results is $result');
        },
      );
    }
  }

  void _stopListeningToScanResults() {
    subscription?.cancel();
    setState(() => subscription = null);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    // stop subscription for scanned results
    _stopListeningToScanResults();
  }

  void _sendWifiCredentials() {
    String ssid = _ssidController.text;
    String password = _passwordController.text;
    getCurrentUserToken();
    // Format the data to be sent to ESP32 (customize as per your ESP32 requirements)
    String? wifiData =
        "$ssid,$password,$userId,Ag1O02cdXwgF8DEehiuXfkdXHbq1,eyJhbGciOiJSUzI1NiIsImtpZCI6IjNhM2JkODk4ZGE1MGE4OWViOWUxY2YwYjdhN2VmZTM1OTNkNDEwNjgiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiRmFpc2FsIFNhZWVkIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL3BhY2thZ2VndWFyZC1kNTE3ZSIsImF1ZCI6InBhY2thZ2VndWFyZC1kNTE3ZSIsImF1dGhfdGltZSI6MTcwMTM2MDA2MiwidXNlcl9pZCI6IkFnMU8wMmNkWHdnRjhERWVoaXVYZmtkWEhicTEiLCJzdWIiOiJBZzFPMDJjZFh3Z0Y4REVlaGl1WGZrZFhIYnExIiwiaWF0IjoxNzAxNDUyNTg2LCJleHAiOjE3MDE0NTYxODYsImVtYWlsIjoiZmFpc2Fsc2FlZWRAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbImZhaXNhbHNhZWVkQGdtYWlsLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6InBhc3N3b3JkIn19.bCkURk3rQxl5oQ8jbWEqfPrYViF3OU0xqdRtT9DKvnaV3aOwV69Uw_hw2STCX1Rx8mTLRdxJx6eN9siCG-HakqL5Z7iB_wFJKfNnc9cTXj9l14YksbS89KfQEKzz1THEvocngJ_4QNY6-ywuV9dZZxFg7bVqbCieWk2QJQSmqJeAlEGW05TJ1FZrPmICNRWSxehdvuLINVXCUNt34vHLN1PPMkfx7PX_lWeRK1eGSFTsx5Vdy_y2LvXYoJv3T22q_u9ePf84MOvBBWWdM7ASXXsgz4dJ5OT6Sxp8T5R66vZCyXSM9a5VtFgkC1i6LQUp-IU-n0uQPqC1qqZ-";

    _sendData(wifiData);
  }

  void _sendData(String dataString) async {
    // List<int> data = utf8.encode(dataString);
    List<int> data = dataString.codeUnits;

    print('the data is $dataString');
    if (connectedDevice != null && characteristic != null) {
      print("the connected device is $connectedDevice");
      await characteristic?.write(data);
    }
  }

  Future<String?> getCurrentUserToken() async {
    // Get the current user
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Get the authentication token
      try {
        token = await user!.getIdToken() ?? '';
        print('the accesstoken is $token');
      } catch (e) {
        print("Error getting user token: $e");
        return null;
      }
    } else {
      print("No user is currently signed in.");
      return null;
    }
    return token;
  }

  Map<String, dynamic> userData = {};
  Map<String, bool> connectedDevices = {};
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    // getCurrentUserToken();
    // _ssidController.text = (wifiTitle ?? '').toString();
    _startListeningToScanResults(context);
    _getScannedResults(context);
    _startScan(context);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getScannedResults(context);
    });
    // Access user data in initState or another method
    userData = userController.userData as Map<String, dynamic>;
    bluetoothController = Get.find<BluetoothController>();
    wifiController = Get.find<WifiController>();
    wifiTitle = wifiController?.ssidList.value;
    print('the value is  $wifiTitle');
    connectedDevice = bluetoothController.connectedDevice.value;
    characteristic = bluetoothController.characteristic.value;

    // print(userData);
    // print(userData['ProfileImage']);
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = userData['ProfileImage'].toString().trim();
    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                image: profileImage,
                title: '${userData['Name']}',
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 200.h,
                      child: Card(
                        color: Colors.blueGrey.shade100,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                title: 'Available Networks',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyblue,
                              ),
                              SizedBox(height: 13.h),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: wifiTitle?.length,
                                  itemBuilder: (context, index) {
                                    // return ListTile(
                                    //   leading: Image.asset(
                                    //     AppImages.wifiImg,
                                    //     height: 17.h,
                                    //     width: 17.w,
                                    //   ),
                                    //   title: wifiTitle![index],
                                    // );


                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: GestureDetector(
                                                onTap: () {
                                                  buildShowDialog(context,
                                                      wifiTitle![index]);
                                                  _ssidController.text =
                                                      wifiTitle![index];
                                                  _controller
                                                      .updateConnectedDevice(
                                                          wifiTitle![index],
                                                          true);
                                                },
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                      AppImages.wifiImg,
                                                      height: 17.h,
                                                      width: 17.w,
                                                    ),
                                                    SizedBox(
                                                      width: 8.w,
                                                    ),
                                                    CustomText(
                                                      title: wifiTitle![index],
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.black,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            connectedDevices[
                                                        wifiTitle![index]] ==
                                                    true
                                                ? 'connected'
                                                    .text
                                                    .color(Colors.blue)
                                                    .fontWeight(FontWeight.w600)
                                                    .maxFontSize(12)
                                                    .make()
                                                : Container(),
                                          ],
                                        ),
                                        SizedBox(height: 5.h),
                                        Divider(thickness: 1.w),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    GestureDetector(
                      onTap: () {
                        buildShowDialog(context, '');
                      },
                      child: CustomText(
                        title: 'Add manually',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyblue,
                      ),
                    ),
                    SizedBox(
                      height: 290.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Get.to(() => HomeScreen());
                      },
                      child: Container(
                        // height: 35.h,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        width: 393.w,
                        decoration: BoxDecoration(
                            color: AppColors.navyblue,
                            borderRadius: BorderRadius.circular(10.r)),
                        child: Center(
                          child: CustomText(
                            title: "Connect Another Wifi",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // const AvailableNetworks(),
            ],
          ),
        ),
      ),
    );
  }

  void buildShowDialog(BuildContext context, String deviceIdentifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: 17.w,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
            ),
            height: 270.h,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.h),
                CustomText(
                  title: 'Add Wifi',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                TextFormField(
                  controller: _ssidController,
                  decoration: InputDecoration(
                    hintText: "SSID",
                    hintStyle: TextStyle(fontSize: 12.sp),
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(fontSize: 12.sp),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      activeColor: AppColors.navyblue,
                      value: isPasswordVisible,
                      onChanged: (bool? value) {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    SizedBox(width: 8.w),
                    CustomText(
                      title: 'Show Password',
                      color: const Color(0xff252525),
                      fontWeight: FontWeight.w400,
                      fontSize: 10.sp,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _ssidController.clear();
                        _passwordController.clear();
                      },
                      child: CustomText(
                        title: 'Cancel',
                        color: const Color(0xff252525),
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Check if both SSID and password controllers have non-empty values
                        if (_ssidController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty) {
                          AppConstants.showCustomSnackBar("data sent");

                          Navigator.pop(context);
                          _ssidController.clear();
                          _passwordController.clear();

                          setState(() {
                            connectedDevices[deviceIdentifier] = true;
                          });
                          _sendWifiCredentials();
                        } else {
                          // Show a message or take appropriate action if either SSID or password is empty
                          AppConstants.showCustomSnackBar(
                              "Please enter both SSID and password.");
                        }
                        // Get.to(() => blueT());
                      },
                      child: Container(
                        // height: 30.h,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        width: 80.w,
                        decoration: BoxDecoration(
                            color: AppColors.navyblue,
                            borderRadius: BorderRadius.circular(8.r)),
                        child: Center(
                          child: CustomText(
                            title: "Connect",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.btntext,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
