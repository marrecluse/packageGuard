// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../Utils/app_images.dart';
import '../../../Widgets/custom_text.dart';
import '../../Login/login.dart';
import 'customSwitch.dart';
import 'inner_container_data.dart';

// ignore: use_key_in_widget_constructors
class AddPackageGaurd extends StatefulWidget {
  @override
  State<AddPackageGaurd> createState() => _AddPackageGaurdState();
}

class _AddPackageGaurdState extends State<AddPackageGaurd> {
  bool status = true;
  List<Map<String, dynamic>> devices = [];
bool  isLoading = true; // Set loading to false in case of an error
  Future<void> fetchDevices() async {
    final firestore = FirebaseFirestore.instance;
    final userUidController = Get.find<UserUidController>();
    final uid = userUidController.uid.value; // Assuming you are storing the user's UID in this controller

    try {
      final devicesCollection = firestore.collection('devices');
      final querySnapshot = await devicesCollection.get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> filteredDevices = [];

        for (var document in querySnapshot.docs) {
          final deviceData = document.data() as Map<String, dynamic>;

          // Check if the "userId" matches your UID
          if (deviceData['userId'] == uid) {
            filteredDevices.add(deviceData);


          }
        }

        if (filteredDevices.isNotEmpty) {
          setState(() {
            devices.addAll(filteredDevices);
            isLoading = false; // Set loading to false in case of an error
            print("DEVICES ; ${devices}");
          });
        } else {
          print("No devices found in Firestore for UID: $uid");
          isLoading = false; // Set loading to false in case of an error
        }
      } else {
        print("No devices found in Firestore for UID: $uid");
        isLoading = false; // Set loading to false in case of an error
      }
    } catch (e) {
      print("Error fetching devices: $e");
      isLoading = false; // Set loading to false in case of an error
    }
  }


  Future<void> updateDeviceStatus(String deviceId, bool isArmed) async {
    final firestore = FirebaseFirestore.instance;
    final userUidController = Get.find<UserUidController>();
    final uid = userUidController.uid.value;

    try {
      final devicesCollection = firestore.collection('devices');
      final querySnapshot = await devicesCollection.where('deviceId', isEqualTo: deviceId).get();

      if (querySnapshot.docs.isNotEmpty) {
        final deviceDocument = querySnapshot.docs.first;
        final deviceData = deviceDocument.data() as Map<String, dynamic>;

        // Check if the "userId" matches your UID
        if (deviceData['userId'] == uid) {
          // Update the 'status' field based on 'isArmed' value
          await deviceDocument.reference.update({
            'status': isArmed ? 'armed' : 'disarmed',
          });

          // You can add additional logic here if needed
        }
      }
    } catch (e) {
      print("Error updating device status: $e");
    }
  }




  @override
  void initState() {
    super.initState();
    fetchDevices();
  }




  final List _trailImages = [
    AppImages.greenIcon,
    AppImages.orangeIcon,
    AppImages.redIcon,
    AppImages.redIcon,

  ];

  final List _batteryIcon = [
    AppImages.batteryFull,
    AppImages.batteryLow,
    AppImages.batteryFull,
    AppImages.batteryFull,
  ];

  List titleText = ['Armed', 'Low Battery', ];

  List subtitleText = ['Front Door', 'Side Door',];

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
      child: CircularProgressIndicator(), // Show loader while data is loading
    )
        : Container(
      height: 360.h,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: devices.length, // Use the length of the devices list
        itemBuilder: (context, index) {
          final deviceData = devices[index]; // Access the device data

          return GestureDetector(
            onTap: () {
              // Get.to(() => DeviceDetail());
            },
            child: Container(
              margin: EdgeInsets.only(top: 5.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
              // height: 186.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.blueGrey.shade100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 10.w,
                    leading: Image.asset(
                      AppImages.packageLogo,
                      height: 48,
                      width: 68,
                    ),
                    title: CustomText(
                      title: deviceData['status'], // Access device status
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: deviceData['status'] == 'disarmed'
                          ? const Color(0xff348D15)
                          : deviceData['status'] == 'armed'
                          ? const Color(0xffE09400)
                          : Colors.red,
                    ),
                    subtitle: CustomText(
                      title: deviceData['ssid'], // Access device SSID
                      color: const Color(0xff4E4E4E),
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                    trailing: Image.asset(
                      _trailImages[index],
                      height: 41,
                      width: 41,
                    ),
                  ),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InnerContainerData(
                          img: AppImages.wifiImg,
                          imgHeight: 20,
                          imgWidth: 20,
                          toptext: 'Connected to',
                          btnText: deviceData['deviceId'],
                          tFontWeight: FontWeight.w400,
                          bFontWeight: FontWeight.w700,
                        ),
                        InnerContainerData(
                          img: _batteryIcon[index],
                          imgHeight: 20,
                          imgWidth: 30,
                          toptext: 'Battery',
                          btnText: "${deviceData['battery'].toString()}%", // Replace with actual battery data
                          tFontWeight: FontWeight.w400,
                          bFontWeight: FontWeight.w700,
                        ),
                        InnerContainerData(
                          img: AppImages.diamondImg,
                          imgHeight: 22,
                          imgWidth: 22,
                          toptext: '2 Packages',
                          btnText: "Waiting", // Replace with actual package data
                          tFontWeight: FontWeight.w700,
                          bFontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // const CustomSwitch(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                Text(
                 '${deviceData['status']}',

                    ),
                    SizedBox(width: 5.w),
                    FlutterSwitch(
                      padding: 0,
                      activeColor: const Color(0xff3FCE33),
                      inactiveColor: Colors.red,
                      value: deviceData['status'] != 'armed' ?  false:  true,
                      width: 40,
                      height: 20,
                      toggleSize: 20,
                      onToggle: (value) async {
                        bool isArmed = value; // Determine if it should be armed or not

                        // Update the status in Firestore
                        await updateDeviceStatus(deviceData['deviceId'], isArmed);

                        // Update the local status
                        setState(() {
                          deviceData['status'] = isArmed ? 'armed' : 'disarmed';
                        });
                      },
                    ),
                  ],
                ),// If you have a switch component
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
