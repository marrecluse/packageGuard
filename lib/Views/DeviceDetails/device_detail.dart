import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Views/DeviceDetails/Device_alerts.dart';
import 'package:packageguard/Views/Home_Screen/components/add_package_gaurd.dart';
import 'package:packageguard/Views/Wifi_Connect/wifi_connect.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../Utils/app_colors.dart';
import '../../Utils/app_constants.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/drawer.dart';
import '../EditSafeCircle/edit_safecircle.dart';
import '../Home_Screen/components/customSwitch.dart';
import '../Home_Screen/components/inner_container_data.dart';
import '../Login/login.dart';
import 'package:share_plus/share_plus.dart';

class DeviceDetails extends StatefulWidget {
  const DeviceDetails({super.key});

  @override
  State<DeviceDetails> createState() => _DeviceDetailsState();
}

final ConnectedDevicesController _controller = Get.find<ConnectedDevicesController>();

final userController = Get.find<UserController>();
Map<String, dynamic> userData = {};

class _DeviceDetailsState extends State<DeviceDetails>
    with SingleTickerProviderStateMixin {
  @override
  late AnimationController _animationController;
  final ref = FirebaseDatabase.instance.ref('packageGuard/userId1/devices/');

  double _volumeListenerValue = 0;
  double _getVolume = 0;
  double _setVolumeValue = 0;

  // bool isArmed = false;
  String deviceId = '';
  String battery = '';
  bool armedstatus = false;
  bool isArmed = false;
  bool testAlarm = false;
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

  void updateAlarmStatus(bool alarm, String deviceId) async {
    // var deviceId= 'SN83C048DF9D4'; use variable when getting many devices

    // DatabaseReference alarmRef = FirebaseDatabase.instance
    //     .ref("packageGuard/userId1/devices/deviceId1/data/alerts/");
    DatabaseReference alarmRef = FirebaseDatabase.instance
        .ref().child('status').child(deviceId).child('alerts');
    await alarmRef.once();

    await alarmRef.update({"alarm": alarm});
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
  bool? armedStatus;
  bool switchValue = false;
  bool? armedStatusFromSharedPreferences;
  void _loadArmedStatusFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      armedStatusFromSharedPreferences = prefs.getBool('armedStatus') ?? false;
      switchValue = armedStatusFromSharedPreferences ?? false;
    });
    print(
        'Loaded armed status from SharedPreferences: $armedStatusFromSharedPreferences');
  }

  void fetchArmedStatus() async {
    // var deviceId= 'SN83C048DF9D4'; use variable when getting many devices
String deviceId='SN83C048DF9D4';
    // DatabaseReference ref =
    //     FirebaseDatabase.instance.ref("status/$deviceId/data/alerts/");
    try {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('status').child(deviceId);
    DatabaseEvent event = await ref.once();
    dynamic data = event.snapshot.value;
    armedStatus = data['armed'] as bool?;

    armedstatus = armedStatus!;
    print('the armed status value now is ${armedstatus}');
    setState(() {
      switchValue = armedstatus ?? false;
    });  
    } catch (e) {
      print("fethArmedStatus failed:  $e");
    }
    
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

  List ids = [];
  void initState() {
    super.initState();
    _loadArmedStatusFromSharedPreferences();
    fetchArmedStatus();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Adjust the duration as needed
    )..repeat();
    VolumeController().listener((volume) {
      setState(() => _volumeListenerValue = volume);
    });
    VolumeController().getVolume().then((volume) {
      setState(() {
        _getVolume = volume;
        _setVolumeValue = volume;
      });
    });
    void dispose() {
      VolumeController().removeListener();
      super.dispose();
    }

    userData = userController.userData as Map<String, dynamic>;
    print(userData);
    print(userData['ProfileImage']);
  }

  Future<void> _showVolumeControlDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Volume Control'),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text('Current volume: $_volumeListenerValue'),
                  Row(
                    children: [
                      Text('Set Volume:'),
                      Flexible(
                        child: Slider(
                          min: 0,
                          max: 1,
                          onChanged: (double value) {
                            setState(() {
                              _setVolumeValue = value;
                              VolumeController().setVolume(_setVolumeValue);
                            });
                          },
                          value: _setVolumeValue,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Volume is: $_getVolume'),
                      TextButton(
                        onPressed: () async {
                          setState(() async {
                            _getVolume = await VolumeController().getVolume();
                          });
                        },
                        child: Text('Get Volume'),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => VolumeController().muteVolume(),
                    child: Text('Mute Volume'),
                  ),
                  TextButton(
                    onPressed: () => VolumeController().maxVolume(),
                    child: Text('Max Volume'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Show system UI:${VolumeController().showSystemUI}'),
                      TextButton(
                        onPressed: () => setState(() => VolumeController()
                            .showSystemUI = !VolumeController().showSystemUI),
                        child: Text('Show/Hide UI'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  final profileImage = userData['ProfileImage'].toString().trim();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        body: Column(
          children: [
            CustomAppBar(
              image: profileImage,
              title: '${userData['Name']}',
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 182.w,
                        height: 100.h,
                        decoration: ShapeDecoration(
                          color: const Color(0x2B15508D),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1.w, color: AppColors.navyblue),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                title: "20 Packages",
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyblue,
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    title: "Guraded Date",
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.black,
                                  ),
                                  Image.asset(
                                    AppImages.box,
                                    height: 30.h,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  testAlarm = !testAlarm;
                                });
                                updateAlarmStatus(testAlarm, deviceId);
                              },
                              child: Container(
                                width: 169.w,
                                height: 41.h,
                                decoration: ShapeDecoration(
                                  color: testAlarm
                                      ? Colors.red
                                      : const Color(0xB515508D),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 1.w,
                                        color: const Color(0x7F15508D)),
                                    borderRadius: BorderRadius.circular(9.r),
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        height: 25.h,
                                        AppImages.alram,
                                      ),
                                      SizedBox(width: 10.w),
                                      CustomText(
                                        title: testAlarm
                                            ? 'Beeping'
                                            : 'Test Alarm',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w400,
                                        color: testAlarm
                                            ? Colors.white
                                            : AppColors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Container(
                              width: 200.w,
                              height: 41.h,
                              decoration: ShapeDecoration(
                                color: const Color(0xB515508D),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 1.w,
                                      color: const Color(0x7F15508D)),
                                  borderRadius: BorderRadius.circular(9.r),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _showVolumeControlDialog(context);
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        height: 25.h,
                                        AppImages.speaker,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: CustomText(
                                          title: "Adjust Volume",
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30.h),
AddPackageGaurd(),
// cccccc

                  // Container(
                  //   height: 360.h,
                  //   width: MediaQuery.of(context).size.width,
                  //   child: StreamBuilder(
                  //       stream: ref.onValue,
                  //       builder:
                  //           (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  //         if (!snapshot.hasData) {
                  //           return Container();
                  //         } else {
                  //           Map<dynamic, dynamic> map =
                  //               snapshot.data!.snapshot.value as dynamic;
                  //           List list = map.keys.toList();
                  //           // print('the value of the $list is');

                  //           Map deviceIds = map["deviceId1"];

                  //           Map deviceData = deviceIds['data'];
                  //           print(
                  //               'here the battery is ${deviceData['battery']}');

                  //           Map data = deviceData['alerts'] is Map
                  //               ? deviceData['alerts']
                  //               : {};

                  //           print(
                  //               'the value of the map is ${data['armedStatus']}');

                  //           // FirebaseFirestore.instance
                  //           //     .collection("users")
                  //           //     .doc(FirebaseAuth.instance.currentUser!.uid)
                  //           //     .update({"devices": deviceIds});

                  //           // List<bool> armedStatusList =
                  //           //     List.generate(deviceIds.length, (index) => false);

                  //           // battery =
                  //           //     map['SN83C048DF9D4']['battery_level'] ?? 'battery level';

                  //           return ListView.builder(
                  //             physics: const BouncingScrollPhysics(),
                  //             // itemCount: devices.length, // Use the length of the devices list
                  //             itemCount: list.length,
                  //             // Use the length of the devices list
                  //             itemBuilder: (context, index) {
                  //               // Map<dynamic, dynamic> packageGuardInfo =
                  //               //     list[index]['SN83C048DF9D4'] ?? {};

                  //               Key itemKey = UniqueKey();
                  //               // Map<dynamic, dynamic> packageGuardInfo = map[deviceIds] ?? {};
                  //               // Map<dynamic, dynamic> packageGuardInfo = map[data] ?? {};

                  //               // print("package Guard info: $packageGuardInfo");

                  //               // print("alarm status: ${data['alarm']}");

                  //               // bool armedStatus = data['armedStatus'] ?? false;
                  //               // print("Armed status: ${armedStatus}");
                  //               // String battery = deviceData['battery'] ?? 'battery level';
                  //               // print("battery: ${battery}");

                  //               // bool armedStatus = packageGuardInfo['armed_status'] ?? false;
                  //               // var device_id = packageGuardInfo[
                  //               //'device_id'] ?? 'dd';
                  //               // final deviceData = 1; // Access the device data

                  //               // ids.add(deviceIds[index]);
                  //               // print("the device ids are given ad $ids");

                  //               return Container(
                  //                 key: itemKey,
                  //                 margin: EdgeInsets.only(top: 5.h),
                  //                 padding: EdgeInsets.symmetric(
                  //                     horizontal: 10.w, vertical: 1.h),
                  //                 // height: 186.h,
                  //                 decoration: BoxDecoration(
                  //                   borderRadius: BorderRadius.circular(8.r),
                  //                   color: Colors.blueGrey.shade100,
                  //                 ),
                  //                 child: Column(
                  //                   crossAxisAlignment:
                  //                       CrossAxisAlignment.start,
                  //                   children: [
                  //                     ListTile(
                  //                       contentPadding: EdgeInsets.zero,
                  //                       horizontalTitleGap: 10.w,
                  //                       leading: Image.asset(
                  //                         AppImages.packageLogo,
                  //                         height: 48,
                  //                         width: 68,
                  //                       ),
                  //                       title: CustomText(
                  //                         title: isArmed
                  //                             ? 'Armed'
                  //                             : (double.parse(deviceData[
                  //                                         'battery']) <=
                  //                                     20
                  //                                 ? 'Low Battery'
                  //                                 : 'disarmed'),
                  //                         // Access device status
                  //                         fontWeight: FontWeight.w600,
                  //                         fontSize: 13,
                  //                         color: isArmed
                  //                             ? const Color(0xff348D15)
                  //                             : Colors.red,
                  //                       ),
                  //                       subtitle: CustomText(
                  //                         title: list[index]
                  //                         //  deviceIds[0]
                  //                         , // Access device SSID
                  //                         color: const Color(0xff4E4E4E),
                  //                         fontSize: 9,
                  //                         fontWeight: FontWeight.w400,
                  //                       ),
                  //                       trailing: AnimatedBuilder(
                  //                         animation: _animationController,
                  //                         builder: (context, child) {
                  //                           // Use the animation value to interpolate between the two images
                  //                           final imageIndex =
                  //                               _animationController.value < 0.5
                  //                                   ? 0
                  //                                   : (_animationController
                  //                                               .value <
                  //                                           0.75
                  //                                       ? 1
                  //                                       : 2);

                  //                           return double.parse(deviceData[
                  //                                           'battery']) <=
                  //                                       20 &&
                  //                                   armedstatus
                  //                               ? Image.asset(
                  //                                   _trailImages[imageIndex],
                  //                                   height: 41,
                  //                                   width: 41,
                  //                                 )
                  //                               : Text('Ready To Arm');
                  //                         },
                  //                       ),
                  //                     ),
                  //                     Container(
                  //                       height: 60,
                  //                       width:
                  //                           MediaQuery.of(context).size.width,
                  //                       padding: EdgeInsets.symmetric(
                  //                           horizontal: 10.w, vertical: 9.h),
                  //                       decoration: BoxDecoration(
                  //                         color: Colors.white,
                  //                         borderRadius:
                  //                             BorderRadius.circular(5.r),
                  //                       ),
                  //                       child: Row(
                  //                         mainAxisAlignment:
                  //                             MainAxisAlignment.spaceBetween,
                  //                         children: [
                  //                           Column(
                  //                             mainAxisAlignment:
                  //                                 MainAxisAlignment.center,
                  //                             children: [
                  //                               InnerContainerData(
                  //                                 img: AppImages.wifiImg,
                  //                                 imgHeight: 20,
                  //                                 imgWidth: 20,
                  //                                 toptext: 'Connected to',
                  //                                 btnText: _controller
                  //                                     .connectedDevices.keys
                  //                                     .toString(),
                  //                                 tFontWeight: FontWeight.w400,
                  //                                 bFontWeight: FontWeight.w700,
                  //                               ),
                  //                             ],
                  //                           ),
                  //                           Column(
                  //                             mainAxisAlignment:
                  //                                 MainAxisAlignment.center,
                  //                             children: [
                  //                               InnerContainerData(
                  //                                 img: double.parse(deviceData[
                  //                                             'battery']) >=
                  //                                         80
                  //                                     ? AppImages.batteryFull
                  //                                     : (double.parse(deviceData[
                  //                                                 'battery']) <=
                  //                                             20
                  //                                         ? AppImages
                  //                                             .batteryloww
                  //                                         : AppImages
                  //                                             .batteryLow),
                  //                                 imgHeight: 20,
                  //                                 imgWidth: 30,
                  //                                 toptext: 'Battery',
                  //                                 btnText: deviceData[
                  //                                     'battery'], // Replace with actual battery data
                  //                                 tFontWeight: FontWeight.w400,
                  //                                 bFontWeight: FontWeight.w700,
                  //                               ),
                  //                             ],
                  //                           ),
                  //                           Column(
                  //                             mainAxisAlignment:
                  //                                 MainAxisAlignment.center,
                  //                             children: [
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
                  //                         ],
                  //                       ),
                  //                     ),
                  //                     SizedBox(height: 10.h),
                  //                     // const CustomSwitch(),
                  //                     Row(
                  //                       mainAxisAlignment:
                  //                           MainAxisAlignment.end,
                  //                       children: [
                  //                         CustomText(
                  //                           title: armedstatus
                  //                               ? 'Armed'
                  //                               : 'DisArmed', // Access device status
                  //                           fontWeight: FontWeight.w600,
                  //                           fontSize: 12,
                  //                           color: armedstatus
                  //                               ? const Color(0xff348D15)
                  //                               : Colors.red,
                  //                         ),
                  //                         SizedBox(width: 5.w),
                  //                         FlutterSwitch(
                  //                           padding: 0,
                  //                           activeColor:
                  //                               const Color(0xff3FCE33),
                  //                           inactiveColor: Colors.red,
                  //                           value: armedstatus,
                  //                           width: 40,
                  //                           height: 20,
                  //                           toggleSize: 20,
                  //                           onToggle: (value) async {
                  //                             print(
                  //                                 "Toggle value is true for: $value");
                  //                             setState(() {
                  //                               // controller.enableIsArmed(index);
                  //                               armedstatus = value;
                  //                               deviceData['alerts'] = value;
                  //                             });
                  //                             updateArmedStatus(
                  //                                 armedstatus, deviceId);
                  //                             _saveArmedStatusToSharedPreferences();

                  //                             armedstatus != armedstatus;
                  //                             print(
                  //                                 'the value of the $isArmed hello');

                  //                             // Determine if it should be armed or not

                  //                             // Update the status in Firestore
                  //                             // await updateDeviceStatus(
                  //                             //     deviceData['deviceId'], isArmed);

                  //                             // Update the local status`
                  //                             // setState(() {
                  //                             // deviceData['status'] =
                  //                             //     isArmed ? 'armed' : 'disarmed';
                  //                             // });
                  //                           },
                  //                         ),
                  //                       ],
                  //                     ), // If you have a switch component
                  //                     SizedBox(height: 10.h),
                  //                   ],
                  //                 ),
                  //               );
                  //             },
                  //           );
                  //         }
                  //       }),
                  // )



                  // ddddddddd

                  // Container(
                  //   width: 358.w,
                  //   // height: 176.h,
                  //   padding: EdgeInsets.symmetric(horizontal: 15.h),
                  //   decoration: ShapeDecoration(
                  //     color: const Color(0x2B15508D),
                  //     shape: RoundedRectangleBorder(
                  //       side: BorderSide(
                  //           width: 1.w, color: const Color(0x7F15508D)),
                  //       borderRadius: BorderRadius.circular(9.r),
                  //     ),
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       ListTile(
                  //           contentPadding: EdgeInsets.zero,
                  //           horizontalTitleGap: 10.w,
                  //           leading: Image.asset(
                  //             AppImages.packageLogo,
                  //             height: 48.h,
                  //             width: 68.w,
                  //           ),
                  //           title: CustomText(
                  //               title: "Armed",
                  //               fontWeight: FontWeight.w600,
                  //               fontSize: 13.sp,
                  //               color: const Color(0xff348D15)),
                  //           subtitle: CustomText(
                  //             title: "Front Door",
                  //             color: const Color(0xff4E4E4E),
                  //             fontSize: 10.sp,
                  //             fontWeight: FontWeight.w400,
                  //           ),
                  //           trailing: Image.asset(
                  //             AppImages.greenIcon,
                  //             height: 60.h,
                  //           )),
                  //       SizedBox(height: 15.h),
                  //       Container(
                  //         height: 60,
                  //         width: MediaQuery.of(context).size.width,
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 10.w, vertical: 9.h),
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(5.r),
                  //         ),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             InnerContainerData(
                  //               img: AppImages.wifiImg,
                  //               imgHeight: 20,
                  //               imgWidth: 20,
                  //               toptext: 'Connected to',
                  //               btnText: "Micheal's Wifi",
                  //               tFontWeight: FontWeight.w400,
                  //               bFontWeight: FontWeight.w700,
                  //             ),
                  //             InnerContainerData(
                  //               img: AppImages.batteryFull,
                  //               imgHeight: 20,
                  //               imgWidth: 30,
                  //               toptext: 'Battery',
                  //               btnText: "90%",
                  //               tFontWeight: FontWeight.w400,
                  //               bFontWeight: FontWeight.w700,
                  //             ),
                  //             InnerContainerData(
                  //               img: AppImages.diamondImg,
                  //               imgHeight: 22,
                  //               imgWidth: 22,
                  //               toptext: '2 Packages',
                  //               btnText: "Waiting",
                  //               tFontWeight: FontWeight.w700,
                  //               bFontWeight: FontWeight.w400,
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       SizedBox(height: 15.h),
                  //       const CustomSwitch(),
                  //       SizedBox(height: 10.h),
                  //     ],
                  //   ),
                  // ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const DeviceHistory());
                        },
                        child: Container(
                          //height: 30.h,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          width: 150.w,
                          decoration: BoxDecoration(
                              color: AppColors.navyblue,
                              borderRadius: BorderRadius.circular(8.r)),
                          child: Center(
                            child: CustomText(
                              title: "See History",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.btntext,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 50.w),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // AppConstants.showCustomSnackBar("Share!");

                                String appLink = 'your_app_link_here';
                                Share.share(appLink,
                                    subject: 'Check out this app!');
                              },
                              child: Image.asset(
                                AppImages.share1,
                                height: 30.h,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            GestureDetector(
                                onTap: () {
                                  // AppConstants.showCustomSnackBar("Share!");
                                  String appLink = 'your_app_link_here';
                                  Share.share(appLink,
                                      subject: 'Check out this app!');
                                },
                                child: Image.asset(AppImages.share2))
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
