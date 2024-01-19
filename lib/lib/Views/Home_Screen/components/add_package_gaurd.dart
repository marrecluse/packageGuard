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
import 'package:packageguard/Views/DeviceDetails/device_detail.dart';
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
  late bool? armedValue;
  bool isSwitched = false; // Local state to manage the toggle button

  Map<String, dynamic> userData = {};
  bool initialArmedStatus = false;
  late AnimationController _animationController;

  String deviceId = '';
  // List<Map<String, dynamic>> devices = [];
  Map<String, dynamic> deviceData = {};
  List devices = [];
  Map<String, bool> armedStatusMap = {}; // Initialize an empty map
  bool isLoading = true;
  String battery = '';
  bool armedstatus = false;
  bool? armedStatusFromSharedPreferences;
  bool switchValue = false;
  late bool rebuilt;
  List ids = [];

  final controller = Get.put(HomeController());
  final ConnectedWifi = Get.find<ConnectedDevicesController>();
  bool isAlarming = false;
  void storeAlarmStatus(bool alarmStatus) {
    isAlarming = alarmStatus;

    print("app: $isAlarming");
  }

// Define a function to save status and deviceId in shared preferences
  void saveStatusToDeviceId(bool status, String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(deviceId, status);
  }

  Future<bool> getStatusForDeviceId(String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(deviceId) ??
        false; // Return an empty string if not found
  }

  Stream<Map<String, int>> fetchCounts(String device) {
    try {
      // Reference to your Firestore collection
      User? user= FirebaseAuth.instance.currentUser;
      CollectionReference<Map<String, dynamic>> alertsCollection =
          FirebaseFirestore.instance.collection('alerts').doc(user!.uid).collection('alertsLog');

      // Create two variables to store counts
      int totalPackages = 0;
      int removedPackages = 0;
print("hi: ${alertsCollection.doc()}");
      // Query to get documents where alertType is equal to 'AlertScaleAdded' or 'AlertScaleRemoved'
      return alertsCollection
// Subcollection
          .where('deviceId', isEqualTo: device)
          .snapshots()
          .map((querySnapshot) {
        // Reset counts for each new snapshot
        totalPackages = 0;
        removedPackages = 0;
        print("docs are: ${querySnapshot.docs.length}");
        querySnapshot.docs.forEach((doc) {
          print("alertTypes: ${doc['alertType']}");
          if (doc['alertType'] == 'ALERT_SCALEADDED') {
            totalPackages++;
          } else if (doc['alertType'] == 'ALERT_SCALEREMOVED') {
            removedPackages++;
          }
        });
print("total_packages: $totalPackages");
print("removed_packages: $removedPackages");
        // Return a map containing the counts
        return {
          'total_packages': totalPackages,
          'removed_packages': removedPackages,
        };
      });
    } catch (e) {
      // Handle errors here
      print('Error fetching data: $e');
      return Stream.empty(); // Return an empty stream in case of error
    }
  }

  void getAlarmStatus() {
    print("function started");

    DatabaseReference alarmRef = FirebaseDatabase.instance.ref(
        'packageGuard/Ag1O02cdXwgF8DEehiuXfkdXHbq1/devices/SN83C048DF9D4/alerts/ALARM_SCALEREMOVED');

    // DatabaseReference alarmRef = FirebaseDatabase.instance.ref().child()

    alarmRef.onValue.listen((DatabaseEvent event) {
      setState(() {
        final alarmStatus = event.snapshot.value as bool;
        print("fetched alarm status is : $alarmStatus");
        // final alarmStatus = true;

        storeAlarmStatus(alarmStatus);
        if (alarmStatus) {
          turnOnAlarm(deviceId);
          print("server: ${alarmStatus}");
        }
      });
    });
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

  void turnOnAlarm(String dId) async {
    DatabaseReference alarmRef = FirebaseDatabase.instance
        .ref()
        .child('status')
        .child(dId)
        .child('alerts');
    await alarmRef.update({
      "alarm": true,
    });
  }

  void updateArmedStatus(bool isArmed, String dId) async {
    String id = dId; //use variable when getting many devices
    DatabaseReference armedRef =
        FirebaseDatabase.instance.ref().child('status').child(id);
    await armedRef.once();

    await armedRef.update({
      "armed": isArmed,
      // "alarm": true
    });
    // Save the armed status in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(dId, isArmed);
  }

  // void fetchArmedStatus() async {
  //   DatabaseReference ref =
  //       FirebaseDatabase.instance.ref().child('status').child(deviceId);
  //   DatabaseEvent event = await ref.once();
  //   dynamic data = event.snapshot.value;
  //   // armedstatus = data['armed'];

  //   print('the armed status value now is${armedstatus}');
  //   setState(() {
  //     switchValue = armedstatus;
  //     isArmed = armedstatus;
  //   });
  //   _saveArmedStatusToSharedPreferences();
  // }

  // late Timer _timer;
  @override
  void initState() {
    super.initState();
    rebuilt = true;
// Use this initialArmedStatus in your switch widget or wherever you need it
    getAlarmStatus();
    // fetchArmedStatus();
    final userController = Get.find<UserController>();
    // Load armed status for each device

    Timer.periodic(Duration(seconds: 1), (timer) {
      // fetchArmedStatus();
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Adjust the duration as needed
    )..repeat();
  }

  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    final ref = FirebaseDatabase.instance
        .ref()
        .child('packageGuard')
        .child(user!.uid.toString())
        .child('devices');
    print("now");
    return Container(
      height: 360.h,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
          stream: ref.onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SizedBox()); // Placeholder for loading state
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Container(
                child: Text('No devices'),
              );
            } else {
              final event = snapshot.data;
              final dataSnapshot = event!.snapshot;

              print("dataSnapshot is the: $dataSnapshot");
              if (dataSnapshot.value == null) {
                return Center(
                  child: Container(
                    child: Text(
                      'No devices',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                  ),
                );
              }
              Map<dynamic, dynamic> map = dataSnapshot.value as dynamic;

              print("Map : $map");

              devices = map.keys.toList();
              print("list of map keys : $devices");

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final deviceId =
                      devices[index]; // Assuming list contains device IDs

                  return StreamBuilder(
                      stream: ref.child(deviceId).onValue,
                      builder:
                          (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return Text('No data available');
                        } else {
                          Map<dynamic, dynamic> mapAlerts =
                              snapshot.data!.snapshot.value as dynamic;
                          print("mapAlerts: $mapAlerts");

                          bool? receivedArmedValue =
                              mapAlerts['armed'] as bool?;
                          if (receivedArmedValue == true &&
                              isSwitched == false &&
                              rebuilt == false) {
                            isSwitched = false;
                          } else {
                            isSwitched = receivedArmedValue as bool;
                          }

                          // Retrieve the received armed value
                          // Update the local state only if the received value is different
                          if (getStatusForDeviceId(deviceId) !=
                              receivedArmedValue) {
                            armedValue = receivedArmedValue ??
                                false; // Update the local state with the received value
                          } else {
                            armedValue = getStatusForDeviceId(deviceId) as bool;
                          }
                          Map<dynamic, dynamic> mapAlarm = mapAlerts['alerts'];
                          bool alarmValue = mapAlarm['ALARM_SCALEREMOVED'];

                          return StreamBuilder(
                stream: FirebaseFirestore.instance.collection('devices').doc(deviceId).snapshots(),
                            builder: (context, snapshot) {
  if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('No data available');
        } else {
          Map<String, dynamic> deviceStatus = snapshot.data!.data() as Map<String, dynamic>;
          print("device status: ${deviceStatus['status']}");
          bool? receivedArmedValue = deviceData['armed'] as bool?;



                              return GestureDetector(
                                onTap: () {
                                  Get.to(DeviceDetails(
                                    alarmValue: alarmValue,
                                    armedStatusMap: isSwitched,
                                    battery: map[deviceId]["battery_level"],
                                    wifi: map[deviceId]["wifi"]["SSID"],
                                    device: deviceId,
                                    alarming: alarmValue,
                                  ));
                                },
                                child: Container(
                                  key: Key(
                                      deviceId), // Use device_id as a unique key
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
                                             isSwitched ?? false
                                                ? 'Armed'
                                                : 'DisArmed';
                          
                                            final textColor = isSwitched
                                                ? Colors.green
                                                : Colors.red;
                                            // Default color for Disarmed
                                            return Text(
                                              deviceStatus['status']=='offline' ? 'Offline' : textIndex,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: textColor,
                                              ),
                                            );
                                          },
                                        ),
                                        subtitle: CustomText(
                                          title: deviceId,
                                          //  deviceIds[0]
                                          // Access device SSID
                                          color: const Color(0xff4E4E4E),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        trailing: GestureDetector(
                                          onTap: () async {
                                            if (alarmValue) {
                                              turnOffAlarm(deviceId);
                                            }
                                          },
                                          child: Image.asset(
                                            _trailImages[alarmValue
                                                ? 2
                                                : double.parse(map[deviceId]
                                                            ["battery_level"]) <=
                                                        20
                                                    ? 1
                                                    : 0],
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                InnerContainerData(
                                                  img: AppImages.wifiImg,
                                                  imgHeight: 20,
                                                  imgWidth: 20,
                                                  toptext: 'Connected to',
                                                  btnText: map[deviceId]["wifi"]
                                                      ["SSID"],
                                                  tFontWeight: FontWeight.w400,
                                                  bFontWeight: FontWeight.w700,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                InnerContainerData(
                                                  img: double.parse(map[deviceId]
                                                              ["battery_level"]) >=
                                                          80
                                                      ? AppImages.batteryFull
                                                      : (double.parse(map[deviceId][
                                                                  "battery_level"]) <=
                                                              20
                                                          ? AppImages.batteryloww
                                                          : AppImages.batteryLow),
                                                  imgHeight: 20,
                                                  imgWidth: 30,
                                                  toptext: 'Battery',
                                                  btnText: map[deviceId][
                                                      "battery_level"], // Replace with actual battery data
                                                  tFontWeight: FontWeight.w400,
                                                  bFontWeight: FontWeight.w700,
                                                ),
                                              ],
                                            ),
                                            StreamBuilder<Map<String, int>>(
                                                stream: fetchCounts(deviceId),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    return Center(
                                                      child: Text(
                                                          'Error: ${snapshot.error}'),
                                                    );
                                                  }
                          
                                                  if (!snapshot.hasData ||
                                                      snapshot.data == null) {
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                          
                                                  final data = snapshot.data!;
                                                  print("count data: $data");
                          
                                                  int totalPackages =
                                                      data['total_packages'] as int;
                                                  print(
                                                      "total packages: $totalPackages");
                                                  int removedPackages =
                                                      data['removed_packages']
                                                          as int;
                                                  int sum = totalPackages -
                                                      removedPackages;
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      InnerContainerData(
                                                        img: AppImages.diamondImg,
                                                        imgHeight: 22,
                                                        imgWidth: 22,
                                                        toptext: '$sum Packages',
                                                        btnText:
                                                            "Waiting", // Replace with actual package data
                                                        tFontWeight:
                                                            FontWeight.w700,
                                                        bFontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ],
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      // const CustomSwitch(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          CustomText(
                                            title: isSwitched ?? false
                                                ? 'Armed'
                                                : 'DisArmed', // Access device status
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: isSwitched
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
                                              value: isSwitched,
                                              // Use armed status from the map
                                              onToggle: (val) async {
                                                setState(() {
                                                  isSwitched = val;
                                                });
                                                // Update the armed status in the real-time database
                                                updateArmedStatus(val, deviceId);
                          
                                                // Here, you can also store the updated value in shared preferences
                                                saveStatusToDeviceId(val, deviceId);
                                              }),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                    ],
                                  ),
                                ),
                              );
        }}
                          );
                        }
                      });
                },
              );
            }
          }),
    );
  }
}
