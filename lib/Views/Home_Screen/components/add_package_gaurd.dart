// ignore_for_file: must_be_immutable, unused_local_variable

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:packageguard/Views/Home_Screen/controller/home_controller.dart';
import 'package:packageguard/Views/Home_Screen/home_screen.dart';
import 'package:packageguard/Views/Wifi_Connect/wifi_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
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

class _AddPackageGaurdState extends State<AddPackageGaurd>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  bool status = true;
  List<Map<String, dynamic>> devices = [];
  bool isLoading = true; // Set loading to false in case of an error
  Future<void> fetchDevices() async {
    final firestore = FirebaseFirestore.instance;
    final userUidController = Get.find<UserUidController>();
    // final uid = userUidController.uid.value; // Assuming you are storing the user's UID in this controller

    final uid = 'tnmNVyaT4LNeDWgo8kl2vILkE2m2';
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
            print("DEVICES are ; ${devices}");
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
    // final uid = userUidController.uid.value;
    final uid = 'tnmNVyaT4LNeDWgo8kl2vILkE2m2';

    try {
      final devicesCollection = firestore.collection('devices');
      final querySnapshot =
          await devicesCollection.where('deviceId', isEqualTo: deviceId).get();

      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('I am here');

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


  final ref = FirebaseDatabase.instance.ref('packageGuard/userId1/devices/');

  // bool isArmed = false;
  String deviceId = 'SN83C048DF9D4';
  String battery = '';
  bool armedstatus = false;
  bool? armedStatusFromSharedPreferences;
  bool isArmed = false;
  bool switchValue = false;
  List ids = [];

  final controller = Get.put(HomeController());
  final ConnectedWifi = Get.find<ConnectedDevicesController>();
  bool isAlarming = true;

  void storeAlarmStatus(bool alarmStatus) {
    isAlarming = alarmStatus;

    print("app: $isAlarming");
  }

  void getAlarmStatus() {
    print("function started");

    DatabaseReference alarmRef = FirebaseDatabase.instance
        .ref('devices/SN83C048DF9D4/alerts/ALARM_SCALERMOVED');
    alarmRef.onValue.listen((DatabaseEvent event) {
      setState(() {
        final alarmStatus = event.snapshot.value as bool;
        // final alarmStatus = true;

        storeAlarmStatus(alarmStatus);
        if (alarmStatus) {
          turnOnAlarm(deviceId);
          print("server: ${alarmStatus}");
        }
      });
    });
  }

  void turnOffAlarm() async {
    DatabaseReference armedRef =
        FirebaseDatabase.instance.ref("devices/SN83C048DF9D4_status/");
    await armedRef.update({
      "alarm": false,
    });
  }

  void turnOnAlarm(String deviceId) async {

    DatabaseReference armedRef =
        FirebaseDatabase.instance.ref().child('status').child(deviceId).child('alerts');
    await armedRef.update({
      "alarm": true,
    });
  }

  // void updateArmedStatus(bool isArmed, String deviceId) async {
  //   // var deviceId= 'SN83C048DF9D4'; use variable when getting many devices

  //   DatabaseReference armedRef =
  //       FirebaseDatabase.instance.ref("packageGuard/deviceId1/data/alerts/");
  //   await armedRef.once();

  //   await armedRef.update({
  //     "armedStatus": isArmed,
  //     // "alarm": true
  //   });
  // }
    void updateArmedStatus(bool isArmed, String deviceId) async {
    String deviceId= 'SN83C048DF9D4'; //use variable when getting many devices
 DatabaseReference armedRef =
        FirebaseDatabase.instance.ref().child('status').child(deviceId);
    await armedRef.once();

    await armedRef.update({
      "armed": isArmed,
      // "alarm": true
    });
  }

  void _saveState(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('armedStatus', status);
  }

  bool? armedStatus;
  // void fetchArmedStatus() async {
  //   // var deviceId= 'SN83C048DF9D4'; use variable when getting many devices

  //   DatabaseReference ref =
  //       FirebaseDatabase.instance.ref("packageGuard/deviceId1/data/alerts/");
  //   DatabaseEvent event = await ref.once();
  //   dynamic data = event.snapshot.value;
  //   armedStatus = data['armedStatus'] as bool?;

  //   armedstatus = armedStatus!;
  //   print('the armed status value now is${armedstatus}');
  //   setState(() {
  //     switchValue = armedstatus ?? false;
  //   });
  //   _saveArmedStatusToSharedPreferences();
  //   // print('the armed status is ${armedstatus}');
  //   // Object? armedStatus = event.snapshot.value;

  //   // DataSnapshot snapshot = (await ref.once()) as DataSnapshot;
  // }

    void fetchArmedStatus() async {
    // var deviceId= 'SN83C048DF9D4'; use variable when getting many devices
String deviceId='SN83C048DF9D4';
    // DatabaseReference ref =
    //     FirebaseDatabase.instance.ref("status/$deviceId/data/alerts/");
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('status').child(deviceId);
    DatabaseEvent event = await ref.once();
    dynamic data = event.snapshot.value;
    armedStatus = data['armed'] as bool?;

    armedstatus = armedStatus!;
    print('the armed status value now is${armedstatus}');
    setState(() {
      switchValue = armedstatus ?? false;
    });
    _saveArmedStatusToSharedPreferences();
    // print('the armed status is ${armedstatus}');
    // Object? armedStatus = event.snapshot.value;

    // DataSnapshot snapshot = (await ref.once()) as DataSnapshot;
  }

  void _saveArmedStatusToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('armedStatus', armedStatus ?? false);
    print('Saved armed status to SharedPreferences: $armedStatus');
  }

  void _loadArmedStatusFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      armedStatusFromSharedPreferences = prefs.getBool('armedStatus') ?? false;
      switchValue = armedStatusFromSharedPreferences ?? false;
    });
    print(
        'Loaded armed status from SharedPreferences: $armedStatusFromSharedPreferences');
  }

  // late Timer _timer;
  @override
  void initState() {
    super.initState();
    getAlarmStatus();
    fetchArmedStatus();
    _loadArmedStatusFromSharedPreferences();
    // Timer.periodic(Duration(seconds: 1), (timer) {
      fetchArmedStatus();
    // });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Adjust the duration as needed
    )..repeat();
    fetchDevices();
    // print("the connected wifi is ${ConnectedWifi[$ConnectedWifi]}");

    // Uncomment the next line if you want to start the animation immediately
    // _animationController.forward();
  }

  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    AppImages.batteryloww
  ];

  List titleText = [
    'Armed',
    'Low Battery',
  ];

  List subtitleText = [
    'Front Door',
    'Side Door',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360.h,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
          stream: ref.onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else {
              Map<dynamic, dynamic> map =
                  snapshot.data!.snapshot.value as dynamic;

                  print("Map : $map");
              List list = map.keys.toList();
                                print("list of map keys : $list");

              // print('the value of the $list is');

              Map deviceIds = map["deviceId1"];
              print("deviceIds : $deviceIds");

              print("deviceIds1: ${map["deviceId1"]}");
              print("deviceIds2: ${map["deviceId2"]}");

              Map deviceData = deviceIds['data'];  
              print("deviceData : $deviceData");   

              print('here the battery is ${deviceData['battery']}');

              Map data =
                  deviceData['alerts'] is Map ? deviceData['alerts'] : {};

              print('the value of the map is ${data['armedStatus']}');

              // FirebaseFirestore.instance
              //     .collection("users")
              //     .doc(FirebaseAuth.instance.currentUser!.uid)
              //     .update({"devices": deviceIds});

              // List<bool> armedStatusList =
              //     List.generate(deviceIds.length, (index) => false);

              // battery =
              //     map['SN83C048DF9D4']['battery_level'] ?? 'battery level';

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                // itemCount: devices.length, // Use the length of the devices list
                itemCount: 1,
                // Use the length of the devices list
                itemBuilder: (context, index) {
                  // Map<dynamic, dynamic> packageGuardInfo =
                  //     list[index]['SN83C048DF9D4'] ?? {};

                  Key itemKey = UniqueKey();
                  // Map<dynamic, dynamic> packageGuardInfo = map[deviceIds] ?? {};
                  // Map<dynamic, dynamic> packageGuardInfo = map[data] ?? {};

                  // print("package Guard info: $packageGuardInfo");

                  // print("alarm status: ${data['alarm']}");

                  // bool armedStatus = data['armedStatus'] ?? false;
                  // print("Armed status: ${armedStatus}");
                  // String battery = deviceData['battery'] ?? 'battery level';
                  // print("battery: ${battery}");

                  // bool armedStatus = packageGuardInfo['armed_status'] ?? false;
                  // var device_id = packageGuardInfo[
                  //'device_id'] ?? 'dd';
                  // final deviceData = 1; // Access the device data

                  // ids.add(deviceIds[index]);
                  // print("the device ids are given ad $ids");

                  return Container(
                    key: itemKey,
                    margin: EdgeInsets.only(top: 5.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
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
                          // title: CustomText(
                          //   title: isArmed
                          //       ? 'Armed'
                          //       : (double.parse(deviceData['battery']) <= 20
                          //           ? 'Low Battery'
                          //           : 'disarmed'),
                          //   // Access device status
                          //   fontWeight: FontWeight.w600,
                          //   fontSize: 13,
                          //   color:
                          //       isArmed ? const Color(0xff348D15) : Colors.red,
                          // ),
                          title: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              // Determine the text and color based on conditions
                              final textIndex = _animationController.value < 0.5
                                  ? 'Alarm'
                                  : (_animationController.value < 0.75
                                      ? 'Low battery'
                                      : 'Armed');

                              final textColor = isAlarming
                                  ? Colors.red // Color for Alarm
                                  : (double.parse(deviceData['battery']) <= 20
                                      ? Colors.yellow // Color for Low Battery
                                      : isArmed
                                          ? const Color(
                                              0xff348D15) // Color for Armed
                                          : Colors
                                              .red); // Default color for Disarmed

                              return Text(
                                textIndex,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              );
                            },
                          ),

                          subtitle: CustomText(
                            title: list[index]
                            //  deviceIds[0]
                            , // Access device SSID
                            color: const Color(0xff4E4E4E),
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                          ),
                          // trailing: isArmed
                          //     ? Image.asset(
                          //         _trailImages[0],
                          //         height: 41,
                          //         width: 41,
                          //       )
                          //     : (Text('Ready to arm'))
                          trailing: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              // Use the animation value to interpolate between the two images
                              final imageIndex = _animationController.value <
                                      0.5
                                  ? 0
                                  : (_animationController.value < 0.75 ? 1 : 2);

                              return isAlarming &&
                                      double.parse(deviceData['battery']) <=
                                          20 &&
                                      armedstatus
                                  ? Image.asset(
                                      _trailImages[imageIndex],
                                      height: 41,
                                      width: 41,
                                    )
                                  : Text('Ready to Arm');
                              // : GestureDetector(
                              //     onTap: () {
                              //       setState(() {
                              //         turnOffAlarm();
                              //       });
                              //     },
                              //     child: Container(
                              //       // ignore: prefer_const_constructors
                              //       child: Column(children: [
                              //         Image.asset(
                              //           _trailImages[2],
                              //           height: 41,
                              //           width: 41,
                              //         )
                              //       ]),
                              //     ),
                              //   );
                            },
                          ),
                        ),
                        // trailing: AnimatedSwitcher(
                        //   duration: Duration(milliseconds: 500),
                        //   child: isArmed
                        //       ? double.parse(deviceData['battery']) <= 20
                        //           ? ScaleTransition(
                        //               scale: Tween<double>(begin: 1, end: 1.5)
                        //                   .animate(
                        //                 CurvedAnimation(
                        //                   parent:
                        //                       _animationController, // Replace with your AnimationController
                        //                   curve: Curves.easeInOut,
                        //                 ),
                        //               ),
                        //               child: Image.asset(
                        //                 _trailImages[1],
                        //                 height: 41,
                        //                 width: 41,
                        //               ),
                        //             )
                        //           : ScaleTransition(
                        //               scale: Tween<double>(begin: 2, end: 1.5)
                        //                   .animate(
                        //                 CurvedAnimation(
                        //                   parent:
                        //                       _animationController, // Replace with your AnimationController
                        //                   curve: Curves.easeInOut,
                        //                 ),
                        //               ),
                        //               child: Image.asset(
                        //                 _trailImages[2],
                        //                 height: 41,
                        //                 width: 41,
                        //               ),
                        //             )
                        //       : // Your other code here
                        //       const Column(
                        //           children: [
                        //             AnimatedSwitcher(
                        //               duration: Duration(milliseconds: 500),
                        //               child: Text(
                        //                 'Ready to arm',
                        //                 key: Key('readyToArmKey'),
                        //               ),
                        //             ),
                        //             SizedBox(height: 5),
                        //           ],
                        //         ),
                        // ),

                        Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 9.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InnerContainerData(
                                    img: AppImages.wifiImg,
                                    imgHeight: 20,
                                    imgWidth: 20,
                                    toptext: 'Connected to',
                                    btnText: ConnectedWifi.connectedDevices.keys
                                        .toString(),
                                    tFontWeight: FontWeight.w400,
                                    bFontWeight: FontWeight.w700,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InnerContainerData(
                                    img: double.parse(deviceData['battery']) >=
                                            80
                                        ? AppImages.batteryFull
                                        : (double.parse(
                                                    deviceData['battery']) <=
                                                20
                                            ? AppImages.batteryloww
                                            : AppImages.batteryLow),
                                    imgHeight: 20,
                                    imgWidth: 30,
                                    toptext: 'Battery',
                                    btnText: deviceData[
                                        'battery'], // Replace with actual battery data
                                    tFontWeight: FontWeight.w400,
                                    bFontWeight: FontWeight.w700,
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InnerContainerData(
                                    img: AppImages.diamondImg,
                                    imgHeight: 22,
                                    imgWidth: 22,
                                    toptext: '2 Packages',
                                    btnText:
                                        "Waiting", // Replace with actual package data
                                    tFontWeight: FontWeight.w700,
                                    bFontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // const CustomSwitch(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomText(
                              title: armedstatus
                                  ? 'Armed'
                                  : 'DisArmed', // Access device status
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: armedstatus
                                  ? const Color(0xff348D15)
                                  : Colors.red,
                            ),
                            SizedBox(width: 5.w),
                            FlutterSwitch(
                              padding: 0,
                              activeColor: const Color(0xff3FCE33),
                              inactiveColor: Colors.red,
                              value: armedstatus,
                              width: 40,
                              height: 20,
                              toggleSize: 20,
                              onToggle: (value) async {
                                print("Toggle value is true for: $value");
                                setState(() {
                                  // controller.enableIsArmed(index);
                                  armedstatus = value;
                                  deviceData['alerts'] = value;
                                  _saveState(armedstatus);
                                });
                                updateArmedStatus(armedstatus, deviceId);

                                armedstatus != armedstatus;
                                print('the value of the $isArmed hello');

                                // Determine if it should be armed or not

                                // Update the status in Firestore
                                // await updateDeviceStatus(
                                //     deviceData['deviceId'], isArmed);

                                // Update the local status`
                                // setState(() {
                                // deviceData['status'] =
                                //     isArmed ? 'armed' : 'disarmed';
                                // });
                              },
                            ),
                          ],
                        ), // If you have a switch component
                        SizedBox(height: 10.h),
                      ],
                    ),
                  );
                },
              );
            }
          }),
    );
  }
}

  // isAlarming
  //                       ? GestureDetector(
  //                           onTap: () {
  //                             setState(() {
  //                               turnOffAlarm();
  //                             });
  //                           },
  //                           child: Container(
  //                             color: Colors.red,
  //                             // ignore: prefer_const_constructors
  //                             child: Column(children: [
  //                               const Text(
  //                                 'DEVICE IS ALARMING...Turn Off Alarm',
  //                                 style: TextStyle(fontSize: 15.0),
  //                               ),
  //                               Icon(Icons.notifications_off, size: 50.0),
  //                             ]),
  //                           ),
  //                         )

//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? Center(
//             child:
//                 CircularProgressIndicator(), // Show loader while data is loading
//           )
//         : Container(
//             height: 360.h,
//             width: MediaQuery.of(context).size.width,
//             child: ListView.builder(
//               physics: const BouncingScrollPhysics(),
//               // itemCount: devices.length, // Use the length of the devices list
//               itemCount: 2, // Use the length of the devices list
//               itemBuilder: (context, index) {
//                 final deviceData = devices[index]; // Access the device data

//                 return GestureDetector(
//                   onTap: () {
//                     // Get.to(() => DeviceDetail());
//                   },
//                   child: Container(
//                     margin: EdgeInsets.only(top: 5.h),
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
//                     // height: 186.h,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8.r),
//                       color: Colors.blueGrey.shade100,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           horizontalTitleGap: 10.w,
//                           leading: Image.asset(
//                             AppImages.packageLogo,
//                             height: 48,
//                             width: 68,
//                           ),
//                           title: CustomText(
//                             title: deviceData['status'], // Access device status
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13,
//                             color: deviceData['status'] == 'disarmed'
//                                 ? const Color(0xff348D15)
//                                 : deviceData['status'] == 'armed'
//                                     ? const Color(0xffE09400)
//                                     : Colors.red,
//                           ),
//                           subtitle: CustomText(
//                             title: deviceData['ssid'], // Access device SSID
//                             color: const Color(0xff4E4E4E),
//                             fontSize: 9,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           trailing: Image.asset(
//                             _trailImages[index],
//                             height: 41,
//                             width: 41,
//                           ),
//                         ),
//                         Container(
//                           height: 60,
//                           width: MediaQuery.of(context).size.width,
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 10.w, vertical: 9.h),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(5.r),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               InnerContainerData(
//                                 img: AppImages.wifiImg,
//                                 imgHeight: 20,
//                                 imgWidth: 20,
//                                 toptext: 'Connected to',
//                                 btnText: deviceData['deviceId'],
//                                 tFontWeight: FontWeight.w400,
//                                 bFontWeight: FontWeight.w700,
//                               ),
//                               InnerContainerData(
//                                 img: _batteryIcon[index],
//                                 imgHeight: 20,
//                                 imgWidth: 30,
//                                 toptext: 'Battery',
//                                 btnText:
//                                     "${deviceData['battery'].toString()}%", // Replace with actual battery data
//                                 tFontWeight: FontWeight.w400,
//                                 bFontWeight: FontWeight.w700,
//                               ),
//                               InnerContainerData(
//                                 img: AppImages.diamondImg,
//                                 imgHeight: 22,
//                                 imgWidth: 22,
//                                 toptext: '2 Packages',
//                                 btnText:
//                                     "Waiting", // Replace with actual package data
//                                 tFontWeight: FontWeight.w700,
//                                 bFontWeight: FontWeight.w400,
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 10.h),
//                         // const CustomSwitch(),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text(
//                               '${deviceData['status']}',
//                             ),
//                             SizedBox(width: 5.w),
//                             FlutterSwitch(
//                               padding: 0,
//                               activeColor: const Color(0xff3FCE33),
//                               inactiveColor: Colors.red,
//                               value: deviceData['status'] != 'armed'
//                                   ? false
//                                   : true,
//                               width: 40,
//                               height: 20,
//                               toggleSize: 20,
//                               onToggle: (value) async {
//                                 bool isArmed =
//                                     value; // Determine if it should be armed or not

//                                 // Update the status in Firestore
//                                 await updateDeviceStatus(
//                                     deviceData['deviceId'], isArmed);

//                                 // Update the local status
//                                 setState(() {
//                                   deviceData['status'] =
//                                       isArmed ? 'armed' : 'disarmed';
//                                 });
//                               },
//                             ),
//                           ],
//                         ), // If you have a switch component
//                         SizedBox(height: 10.h),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//   }
// }
