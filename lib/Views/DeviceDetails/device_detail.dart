// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:velocity_x/velocity_x.dart';
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
  String wifi = '';
  String battery = '';
  bool? armedStatusMap = false;
  bool alarmValue = false;
  String device = '';
  bool alarming = false;
  DeviceDetails({
    super.key,
    required this.wifi,
    required this.battery,
    required this.armedStatusMap,
    required this.alarmValue,
    required this.device,
    required this.alarming,
  });

  @override
  State<DeviceDetails> createState() => _DeviceDetailsState();
}

final ConnectedDevicesController _controller =
    Get.find<ConnectedDevicesController>();

final userController = Get.find<UserController>();
Map<String, dynamic> userData = {};

class _DeviceDetailsState extends State<DeviceDetails>
    with SingleTickerProviderStateMixin {
  @override
  late AnimationController _animationController;
  final ref = FirebaseDatabase.instance.ref('packageGuard/userId1/devices/');
  double _volumeListenerValue = 0;
  double _currentSliderValue = 20;
  double _getVolume = 0;
  double _setVolumeValue = 0;

  // bool isArmed = false;
  String deviceId = '';
  String battery = '';
  bool armedstatus = false;
  bool isArmed = false;
  bool testAlarm = false;
  void updateArmedStatus(bool isArmed, String deviceId) async {
    String deviceId = 'SN83C048DF9D4'; //use variable when getting many devices
    DatabaseReference armedRef =
        FirebaseDatabase.instance.ref().child('status').child(deviceId);
    await armedRef.once();

    await armedRef.update({
      "armed": isArmed,
      // "alarm": true
    });
  }

  Future<int> getTotalScaleAdded() async {
    // Firestore collection reference
    CollectionReference alertsCollection = FirebaseFirestore.instance
        .collection('alerts')
        .doc(userData['uid'])
        .collection('alertsLog');

    // Query documents where alertType is "ALERT_SCALEADDED"
    QuerySnapshot querySnapshot = await alertsCollection
        .where('alertType', isEqualTo: 'ALERT_SCALEADDED')
        .get();

    // Calculate the sum of the 'packages' field in the documents
    int sum = querySnapshot.docs.length;
    print("sum of packages: $sum");
    return sum;
  }

  void turnOffAlarm(String d) async {
    DatabaseReference alarmRef = FirebaseDatabase.instance
        .ref()
        .child('status')
        .child(d)
        .child('alerts');
    await alarmRef.update({
      "alarm": false,
    });
  }




  void updateVolume(int vol, String deviceId) async {
    // var deviceId= 'SN83C048DF9D4'; use variable when getting many devices

    // DatabaseReference alarmRef = FirebaseDatabase.instance
    //     .ref("packageGuard/userId1/devices/deviceId1/data/alerts/");

    DatabaseReference alarmRef =
        FirebaseDatabase.instance.ref().child('testAlarm').child(deviceId);
    await alarmRef.once();

    await alarmRef.update({"volume": vol});
  }





  void updateTestAlarmStatus(bool alarm, String deviceId) async {
    // var deviceId= 'SN83C048DF9D4'; use variable when getting many devices

    // DatabaseReference alarmRef = FirebaseDatabase.instance
    //     .ref("packageGuard/userId1/devices/deviceId1/data/alerts/");

    DatabaseReference alarmRef =
        FirebaseDatabase.instance.ref().child('testAlarm').child(deviceId);
    await alarmRef.once();

    await alarmRef.update({"alarm": alarm});
  }

  final List _trailImages = [
    AppImages.greenIcon,
    AppImages.orangeIcon,
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
    String deviceId = 'SN83C048DF9D4';
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


    userData = userController.userData as Map<String, dynamic>;
    print(userData);
    print(userData['ProfileImage']);
  }

  Future<void> _refreshData() async {
    setState(() {
      userData = userController.userData as Map<String, dynamic>;
    });
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
                          value: _currentSliderValue,
                          max: 100,
                          divisions: 5,
                          label: _currentSliderValue.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _currentSliderValue = value;
                            });
                          },
                        ),
                      ),
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
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: AppColors.navyblue,
          strokeWidth: 4.0,
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: Column(
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
                                  FutureBuilder(
                                      future: getTotalScaleAdded(),
                                      builder: (context,
                                          AsyncSnapshot<int> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          int totalScaleAdded =
                                              snapshot.data ?? 0;

                                          return CustomText(
                                            title:
                                                "$totalScaleAdded  ${totalScaleAdded == 1 ? 'Package' : 'Packages'}",
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.navyblue,
                                          );
                                        }
                                      }),
                                  SizedBox(height: 10.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        title: "Guarded to Date",
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

                                    updateTestAlarmStatus(
                                        testAlarm, widget.device);

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
                                        borderRadius:
                                            BorderRadius.circular(9.r),
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
                                      // _showVolumeControlDialog(context);
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4.w),
                                      child: testAlarm 
                                      ? Slider(
                                        value: _currentSliderValue,
                                        max: 100,
                                        activeColor: Colors.white,
                                        divisions: 5,
                                        label: _currentSliderValue
                                            .round()
                                            .toString(),
                                        onChanged: (double value) {
                                          setState(() {
                                            _currentSliderValue = value;

                                          });
                                      updateVolume(
                                        _currentSliderValue.round().toInt(), widget.device);
                                        },
                                      )
                                       :
                                      Row(
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
                      Container(
                        key: Key(deviceId), // Use device_id as a unique key
                        // Use device ID as a unique key
                        margin: EdgeInsets.only(top: 5.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 1.h),
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
                              title: AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  // Determine the text and color based on conditions
                                  final textIndex =
                                      widget.armedStatusMap ?? false
                                          ? 'Armed'
                                          : 'DisArmed';

                                  final textColor = widget.alarming
                                      ? Colors.red // Color for Alarm
                                      // : (double.parse(
                                      //             map[deviceId]["battery_level"]) <=
                                      //         20.00
                                      //     ? Colors.pink // Color for Low Battery
                                      : widget.armedStatusMap ?? false
                                          ? const Color(
                                              0xff348D15) // Color for Armed
                                          : Colors
                                              .red; // Default color for Disarmed
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
                                title: widget.device,
                                color: const Color(0xff4E4E4E),
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                              ),
                              trailing: GestureDetector(
                                onTap: () async {
                                  if (widget.alarmValue) {
                                    turnOffAlarm(widget.device);
                                  }
                                },
                                child: Image.asset(
   _trailImages[widget.alarmValue ? 2 : double.parse(widget.battery) <=20 ? 1: 0],
                                  height: 41,
                                  width: 41,
                                ),
                              ),
                            ),

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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InnerContainerData(
                                        img: AppImages.wifiImg,
                                        imgHeight: 20,
                                        imgWidth: 20,
                                        toptext: 'Connected to',
                                        btnText: widget.wifi,
                                        tFontWeight: FontWeight.w400,
                                        bFontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InnerContainerData(
                                        img: double.parse(widget.battery) >= 80
                                            ? AppImages.batteryFull
                                            : (double.parse(widget.battery) <=
                                                    20
                                                ? AppImages.batteryloww
                                                : AppImages.batteryLow),
                                        imgHeight: 20,
                                        imgWidth: 30,
                                        toptext: 'Battery',
                                        btnText: widget
                                            .battery, // Replace with actual battery data
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
                                  title: widget.armedStatusMap ?? false
                                      ? 'Armed'
                                      : 'DisArmed', // Access device status
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: widget.armedStatusMap ?? false
                                      ? const Color(0xff348D15)
                                      : Colors.red,
                                ),
                                SizedBox(width: 5.w),
                                FlutterSwitch(
                                  padding: 0,
                                  activeColor: const Color(0xff3FCE33),
                                  inactiveColor: Colors.red,
                                  // value: armedstatus,s
                                  width: 40,
                                  height: 20,
                                  toggleSize: 20,

                                  value: widget.armedStatusMap ??
                                      false, // Use armed status from the map
                                  onToggle: (value) async {
                                    setState(() {
                                      widget.armedStatusMap =
                                          value; // Update the armed status map for the device
                                      // _saveState(armedStatusMap[deviceid]);
                                    });
                                    // Save the state in shared preferences
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool(
                                        'armedStatus_$deviceId', value);

                                    updateArmedStatus(widget.armedStatusMap!,
                                        deviceId); // Update armed status in the database
                                  },
                                ),
                              ],
                            ), // If you have a switch component
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
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

                                    String appLink = 'https://play.google.com/store/apps/details?id=com.packageGuard&hl=en&gl=US';
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
                                      String appLink = 'https://play.google.com/store/apps/details?id=com.packageGuard&hl=en&gl=US';
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
        ),
      ),
    );
  }
}
