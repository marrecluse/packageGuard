import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Utils/snackbar.dart';
import 'package:packageguard/Views/AddPackageGuard/Bluetooth.dart';
import 'package:packageguard/Views/Wifi_Connect/wifi_screen.dart';
import 'package:packageguard/Views/testBluetooth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:packageguard/Widgets/characteristic_tile.dart';
import 'package:packageguard/screens/device_screen.dart';
import 'package:packageguard/screens/scan_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../../Utils/app_colors.dart';
import '../../Utils/app_constants.dart';
import '../../Widgets/custom_appbar.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/drawer.dart';
import '../Login/login.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectedDevicesController extends GetxController {
  RxMap connectedDevices = {}.obs;

  void updateConnectedDevice(String ssid, bool isConnected) {
    connectedDevices[ssid] = isConnected;
    print('the connected device is ${connectedDevices[ssid]}');
    print('Devices are $connectedDevices');
  }
}

class WifiController extends GetxController {
  final title = "*EMPTY*".obs;
  final RxList<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[].obs;
  final RxList<dynamic> ssidList = <dynamic>[].obs; // New list for SSIDs

  void updateTitle(List<WiFiAccessPoint> ssid) {
    ssidList.assignAll(ssid.map((ap) => ap.ssid)); // Update the SSID list
    title.value = ssidList.join(', '); // Concatenate SSIDs for the title
    accessPoints.assignAll(ssid);

    print('My name is $title');
  }
}

class WifiConnect extends StatefulWidget {
  BluetoothCharacteristic deviceChar;

  WifiConnect({
    required this.deviceChar,
  });
  @override
  State<WifiConnect> createState() => _WifiConnectState();
}

bool isPasswordVisible = false;
List? wifiTitle;

class _WifiConnectState extends State<WifiConnect> {
  late BluetoothCharacteristic char;
  final info = NetworkInfo();

  final ConnectedDevicesController _controller =
      Get.find<ConnectedDevicesController>();
  late BuildContext listViewContext;
  // late BluetoothController bluetoothController;
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
        // if (mounted) kShowSnackBar(context, "Cannot start scan: $can");
        return;
      }
    }

    // call startScan API

    final result = await WiFiScan.instance.startScan();
    // if (mounted) kShowSnackBar(context, "startScan: $result");
    // reset access points.
    setState(() => accessPoints = <WiFiAccessPoint>[]);
  }

  Future<bool> writeCharacteristic(
      BluetoothDevice device, Guid characteristicId, List<int> data) async {
    print("in the werite function");

    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        print("char loop");

        await characteristic.write(data);
        print('Data written successfully.');

        try {
          await characteristic.write(data);
          print('Data written successfully.');
          return true; // Return true to indicate success
        } catch (e) {
          print('Error writing data: $e');
          return false; // Return false to indicate failure
        }
      }
    }
    return false; // Return false if the characteristic was not found
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (true) {
      // check if can-getScannedResults
      final can = await WiFiScan.instance.canGetScannedResults();
      // if can-not, then show error
      if (can != CanGetScannedResults.yes) {
        // if (mounted) kShowSnackBar(context, "Cannot get scanned results: $can");
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
  BluetoothDevice savedDevice = Get.find<BluetoothController>().savedDevice;

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
    _timer.cancel();
    super.dispose();
    // stop subscription for scanned results
    _stopListeningToScanResults();
  }

  Future _sendWifiCredentials() async {
    String ssid = _ssidController.text;
    String password = _passwordController.text;

    getCurrentUserToken();
    // Format the data to be sent to ESP32 (customize as per your ESP32 requirements)

    String wifiData = "123,abc,deff";
    print("Wifi data is: $wifiData");
    _sendData(wifiData);
  }

  void _sendData(String dataString) async {
    // List<int> data = utf8.encode(dataString);
    print('abbb');
    List<int> data = dataString.codeUnits;

    print('the data is $dataString');
    if (connectedDevice != null && characteristic != null) {
      print("the connected device is $connectedDevice");
      await char.write(data,
          withoutResponse: char.properties.writeWithoutResponse,
          allowLongWrite: true);
      print("characteristics are $characteristic");
      // await characteristic?.write([0x12, 0x34]);
    }
  }

  Future<void> sendData(
      String ssid, String password, BluetoothCharacteristic char) async {
    String currentUserId = user!.uid;
    String wifiData = "$ssid,$password,$currentUserId";
    List<int> data = wifiData.codeUnits;
    print("ssid:$ssid,pass: $password");
    // Assuming char is a BluetoothCharacteristic or similar object
    await char.write(data, allowLongWrite: true);
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
  Future<void> getuserLocationIos() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied');

          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
            'Location permissions are permanently denied, we cannot request permissions.');

        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        print('Location permissions Success');
      }
    } catch (e) {
      print('error==3 $e');
    }
  }

  // WIFI INFO
  String _connectionStatus = 'Unknown';
  final NetworkInfo _networkInfo = NetworkInfo();
  Future<void> _initNetworkInfo() async {
    String? wifiName;
    String? wifiBSSID;

    try {
      wifiName = await _networkInfo.getWifiName();
      print('wifiName is.., $wifiName');
    } catch (e) {
      // developer.log('Failed to get Wifi Name', error: e);
      print("Failed to get wifi Name: $e");

      wifiName = 'Failed to get Wifi Name';
      print("WifiNm: $wifiName");
    }
  }

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    // getCurrentUserToken();

    _ssidController.text =
        (Platform.isAndroid ? wifiTitle ?? '' : '').toString();
    _startListeningToScanResults(context);
    _getScannedResults(context);
    _startScan(context);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getScannedResults(context);
    });
    getuserLocationIos();
    // Access user data in initState or another method
    _initNetworkInfo();
    userData = userController.userData as Map<String, dynamic>;
    // final bluetoothController = Get.find<BluetoothController>();

    wifiController = Get.find<WifiController>();
    wifiTitle = wifiController?.ssidList.value;
    print('the value is  $wifiTitle');
    // connectedDevice = bluetoothController.connectedDevice.value;
    // characteristic = bluetoothController.characteristic.value;
    if(Platform.isIOS){
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
                          onTap: () async {
                            // Check if both SSID and password controllers have non-empty values
                            if (_ssidController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty) {
                              print("My SSID: ${_ssidController.text.toString()}");
                              print(
                                  "My PASS: ${_passwordController.text.toString()}");

                              String ssid = _ssidController.text.toString();
                              String pass = _passwordController.text.toString();

                              String wifiCred =
                                  "$ssid,$pass,${userData['uid']},${userData['Email']},${userData['Name']}";
                              print("My EMAIL: ${userData['Email']}");
                              List<int> data = wifiCred.codeUnits;
                              try {
                                await widget.deviceChar
                                    .write(data, allowLongWrite: true);

                              } catch (e) {
                                print('Data sent failed due to: $e');
                              }

                              AppConstants.showCustomSnackBar("data sent");

                              Navigator.pop(context);
                              // _ssidController.clear();
                              // _passwordController.clear();

                              setState(() {
                                connectedDevices[deviceIdentifier] = true;
                              });
                              // _sendWifiCredentials();

                              // String wifiData = "1321,abaa
                              // List<int> data = wifiData.codeUnits;
                              // await char.write(data, allowLongWrite: true);
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
    // print(userData);
    // print(userData['ProfileImage']);
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = userData['ProfileImage'].toString().trim();

    Map<String, dynamic>? args = Get.arguments;
    if (args != null && args.containsKey('characteristic')) {
      char = args['characteristic'];
      // Rest of your code
    } else {
      // Handle the case where 'characteristic' is missing or null
    }

    // Access the characteristic argument

    Future<void> _writeToCharacteristic(
        BluetoothCharacteristic characteristic) async {
      // Perform write operation using the provided characteristic
      await characteristic.write([0x12, 0x34]);
    }

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
                    Visibility(
                      visible: Platform.isAndroid,
                      child: SizedBox(
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
                                                        title:
                                                            wifiTitle![index],
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
                                                      .fontWeight(
                                                          FontWeight.w600)
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
                    ),
                    SizedBox(height: 15.h),
                    Visibility(
                        visible: Platform.isIOS,
                        child: SizedBox(
                          height: 260.h,
                        )),
                    Visibility(
                      visible: Platform.isAndroid,
                      child: GestureDetector(
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
                    ),
                    SizedBox(
                      height: 40.h,
                    ),
                    Platform.isIOS
                        ? GestureDetector(
                            onTap: () {
                              // Get.to(() => HomeScreen());
                              buildShowDialog(context, '');
                            },
                            child: Center(
                              child: Container(
                                // height: 35.h,
                                padding: EdgeInsets.symmetric(vertical: 15.h),
                                width: 300.w,
                                decoration: BoxDecoration(
                                    color: AppColors.navyblue,
                                    borderRadius: BorderRadius.circular(10.r)),
                                child: Center(
                                  child: CustomText(
                                    title: "Enter WIFI credentials",
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              // Get.to(() => HomeScreen());
                              buildShowDialog(context, '');
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
                      onTap: () async {
                        // Check if both SSID and password controllers have non-empty values
                        if (_ssidController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty) {
                          print("My SSID: ${_ssidController.text.toString()}");
                          print(
                              "My PASS: ${_passwordController.text.toString()}");

                          String ssid = _ssidController.text.toString();
                          String pass = _passwordController.text.toString();
                        
                          String wifiCred =
                              "$ssid,$pass,${userData['uid']},${userData['Email']},${userData['Name']}";
                          print("My EMAIL: ${userData['Email']}");
                          List<int> data = wifiCred.codeUnits;
                          try {
                             await widget.deviceChar
                              .write(data, allowLongWrite: true);

                          } catch (e) {
                            print('Data sent failed due to: $e');
                          }
                         
                          AppConstants.showCustomSnackBar("data sent");

                          Navigator.pop(context);
                          // _ssidController.clear();
                          // _passwordController.clear();

                          setState(() {
                            connectedDevices[deviceIdentifier] = true;
                          });
                          // _sendWifiCredentials();

                          // String wifiData = "1321,abaa
                          // List<int> data = wifiData.codeUnits;
                          // await char.write(data, allowLongWrite: true);
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


























// import 'dart:async';
// import 'dart:convert';
// import 'dart:core';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:packageguard/Utils/app_images.dart';
// import 'package:packageguard/Utils/snackbar.dart';
// import 'package:packageguard/Views/AddPackageGuard/Bluetooth.dart';
// import 'package:packageguard/Views/Wifi_Connect/wifi_screen.dart';
// import 'package:packageguard/Views/testBluetooth.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:packageguard/Widgets/characteristic_tile.dart';
// import 'package:packageguard/screens/device_screen.dart';
// import 'package:packageguard/screens/scan_screen.dart';

// import 'package:velocity_x/velocity_x.dart';
// import 'package:wifi_scan/wifi_scan.dart';
// import '../../Utils/app_colors.dart';
// import '../../Utils/app_constants.dart';
// import '../../Widgets/custom_appbar.dart';
// import '../../Widgets/custom_text.dart';
// import '../../Widgets/drawer.dart';
// import '../Login/login.dart';
// import 'package:get/get.dart';

// class ConnectedDevicesController extends GetxController {
//   RxMap connectedDevices = {}.obs;

//   void updateConnectedDevice(String ssid, bool isConnected) {
//     connectedDevices[ssid] = isConnected;
//     print('the connected device is ${connectedDevices[ssid]}');
//     print('Devices are $connectedDevices');
//   }
// }

// class WifiController extends GetxController {
//   final title = "**EMPTY**".obs;
//   final RxList<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[].obs;
//   final RxList<dynamic> ssidList = <dynamic>[].obs; // New list for SSIDs

//   void updateTitle(List<WiFiAccessPoint> ssid) {
//     ssidList.assignAll(ssid.map((ap) => ap.ssid)); // Update the SSID list
//     title.value = ssidList.join(', '); // Concatenate SSIDs for the title
//     accessPoints.assignAll(ssid);

//     print('My name is $title');
//   }
// }



// class WifiConnect extends StatefulWidget {
//   const WifiConnect({super.key});
//   @override
//   State<WifiConnect> createState() => _WifiConnectState();
// }

// bool isPasswordVisible = false;
// List? wifiTitle;

// class _WifiConnectState extends State<WifiConnect> {
//   late BluetoothCharacteristic char;

//   final ConnectedDevicesController _controller =
//       Get.find<ConnectedDevicesController>();
//   late BuildContext listViewContext;
//   // late BluetoothController bluetoothController;
//   late WifiController? wifiController;
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? characteristic;

//   final TextEditingController _ssidController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final userController = Get.find<UserController>();

//   // final TextEditingController _ssidController = TextEditingController();
//   // final TextEditingController _passwordController = TextEditingController();

//   List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
//   final List<dynamic> ssidList = <dynamic>[];
//   StreamSubscription<List<WiFiAccessPoint>>? subscription;

//   bool shouldCheckCan = true;

//   bool get isStreaming => true;

//   String userId = '';

//   User? user;

//   // New list for SSIDs

//   String token = '';
//   Future<void> _startScan(BuildContext context) async {
//     // check if "can" startScan
//     if (shouldCheckCan) {
//       // check if can-startScan
//       final can = await WiFiScan.instance.canStartScan();
//       // if can-not, then show error
//       if (can != CanStartScan.yes) {
//         if (mounted) kShowSnackBar(context, "Cannot start scan: $can");
//         return;
//       }
//     }

//     // call startScan API
//     final result = await WiFiScan.instance.startScan();
//     // if (mounted) kShowSnackBar(context, "startScan: $result");
//     // reset access points.
//     setState(() => accessPoints = <WiFiAccessPoint>[]);
//   }

//   Future<bool> writeCharacteristic(
//       BluetoothDevice device, Guid characteristicId, List<int> data) async {
//     print("in the werite function");

//     List<BluetoothService> services = await device.discoverServices();
//     for (BluetoothService service in services) {
//       for (BluetoothCharacteristic characteristic in service.characteristics) {
//         print("char loop");

//         await characteristic.write(data);
//         print('Data written successfully.');

//         try {
//           await characteristic.write(data);
//           print('Data written successfully.');
//           return true; // Return true to indicate success
//         } catch (e) {
//           print('Error writing data: $e');
//           return false; // Return false to indicate failure
//         }
//       }
//     }
//     return false; // Return false if the characteristic was not found
//   }

//   Future<bool> _canGetScannedResults(BuildContext context) async {
//     if (shouldCheckCan) {
//       // check if can-getScannedResults
//       final can = await WiFiScan.instance.canGetScannedResults();
//       // if can-not, then show error
//       print("can is: $can");
//       print("CanGet..: ${CanGetScannedResults.yes}");
//       if (can != CanGetScannedResults.yes) {
//         if (mounted) kShowSnackBar(context, "Cannot get scanned results: $can");
//         accessPoints = <WiFiAccessPoint>[];
//         return false;
//       }
//     }
//     return true;
//   }

//   Future<void> _getScannedResults(BuildContext context) async {
//     if (await _canGetScannedResults(context)) {
//       // get scanned results
//       final results = await WiFiScan.instance.getScannedResults();
//       setState(() => accessPoints = results);
//       print('$results are there');
//     }
//   }

//   final WifiController wificontroller = Get.find();
//   BluetoothDevice savedDevice = Get.find<BluetoothController>().savedDevice;

//   // final Controller controller = Get.find();

//   Future<void> _startListeningToScanResults(BuildContext context) async {
//     if (await _canGetScannedResults(context)) {
//       subscription = WiFiScan.instance.onScannedResultsAvailable.listen(
//         (result) {
//           // Update the GetX controller with the new list
//           Get.find<WifiController>().updateTitle(result);
//           print('the results is $result');
//         },
//       );
//     }
//   }
                                                                                                                                
//   void _stopListeningToScanResults() {
//     subscription?.cancel();
//     setState(() => subscription = null);
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//     // stop subscription for scanned results
//     _stopListeningToScanResults();
//   }

//   Future _sendWifiCredentials() async {
//     String ssid = _ssidController.text;
//     String password = _passwordController.text;

//     getCurrentUserToken();
//     // Format the data to be sent to ESP32 (customize as per your ESP32 requirements)

//     String wifiData = "123,abc,deff";
//     print("Wifi data is: $wifiData");
//     _sendData(wifiData);
//   }

//   void _sendData(String dataString) async {
//     // List<int> data = utf8.encode(dataString);
//     print('abbb');
//     List<int> data = dataString.codeUnits;

//     print('the data is $dataString');
//     if (connectedDevice != null && characteristic != null) {
//       print("the connected device is $connectedDevice");
//       await char.write(data,
//           withoutResponse: char.properties.writeWithoutResponse,
//           allowLongWrite: true);
//       print("characteristics are $characteristic");
//       // await characteristic?.write([0x12, 0x34]);
//     }
//   }

//   Future<void> sendData(String ssid,String password,BluetoothCharacteristic char) async {
//     String currentUserId = user!.uid;
//     String wifiData = "$ssid,$password,$currentUserId";
//     List<int> data = wifiData.codeUnits;
//     print("ssid:$ssid,pass: $password");
//     // Assuming char is a BluetoothCharacteristic or similar object
//     await char.write(data, allowLongWrite: true);
//   }

//   Future<String?> getCurrentUserToken() async {
//     // Get the current user
//     user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       // Get the authentication token
//       try {
//         token = await user!.getIdToken() ?? '';
//         print('the accesstoken is $token');
//       } catch (e) {
//         print("Error getting user token: $e");
//         return null;
//       }
//     } else {
//       print("No user is currently signed in.");
//       return null;
//     }
//     return token;
//   }

//   Map<String, dynamic> userData = {};
//   Map<String, bool> connectedDevices = {};
//   late Timer _timer;
//   @override
//   void initState() {
//     super.initState();
//     userId = FirebaseAuth.instance.currentUser!.uid;
//     // getCurrentUserToken();
//     // _ssidController.text = (wifiTitle ?? '').toString();
//     _startListeningToScanResults(context);
//     _getScannedResults(context);
//     _startScan(context);
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       _getScannedResults(context);
//     });
//     // Access user data in initState or another method
//     userData = userController.userData as Map<String, dynamic>;
//     // final bluetoothController = Get.find<BluetoothController>();

//     wifiController = Get.find<WifiController>();
//     wifiTitle = wifiController?.ssidList.value;
//     print('the value is  $wifiTitle');
//     // connectedDevice = bluetoothController.connectedDevice.value;
//     // characteristic = bluetoothController.characteristic.value;

//     // print(userData);
//     // print(userData['ProfileImage']);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final profileImage = userData['ProfileImage'].toString().trim();

//     Map<String, dynamic>? args = Get.arguments;
//     if (args != null && args.containsKey('characteristic')) {
//   char = args['characteristic'];
//   // Rest of your code
// } else {
//   // Handle the case where 'characteristic' is missing or null
// }

//     // Access the characteristic argument
    
//     Future<void> _writeToCharacteristic(
//         BluetoothCharacteristic characteristic) async {
//       // Perform write operation using the provided characteristic
//       await characteristic.write([0x12, 0x34]);
//     }

//     return SafeArea(
//       child: Scaffold(
//         drawer: MyDrawer(),
//         body: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CustomAppBar(
//                 image: profileImage,
//                 title: '${userData['Name']}',
//               ),

//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 15.w),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       height: 200.h,
//                       child: Card(
//                         color: Colors.blueGrey.shade100,
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 10.w, vertical: 10.h),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               CustomText(
//                                 title: 'Available Networks',
//                                 fontSize: 12.sp,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppColors.navyblue,
//                               ),
//                               SizedBox(height: 13.h),
//                               Expanded(
//                                 child: ListView.builder(
//                                   shrinkWrap: true,
//                                   itemCount: wifiTitle?.length,
//                                   itemBuilder: (context, index) {
//                                     // return ListTile(
//                                     //   leading: Image.asset(
//                                     //     AppImages.wifiImg,
//                                     //     height: 17.h,
//                                     //     width: 17.w,
//                                     //   ),
//                                     //   title: wifiTitle![index],
//                                     // );

//                                     return Column(
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Container(
//                                               child: GestureDetector(
//                                                 onTap: () {
//                                                   buildShowDialog(context,
//                                                       wifiTitle![index]);
//                                                   _ssidController.text =
//                                                       wifiTitle![index];
//                                                   _controller
//                                                       .updateConnectedDevice(
//                                                           wifiTitle![index],
//                                                           true);
//                                                 },
//                                                 child: Row(
//                                                   children: [
//                                                     Image.asset(
//                                                       AppImages.wifiImg,
//                                                       height: 17.h,
//                                                       width: 17.w,
//                                                     ),
//                                                     SizedBox(
//                                                       width: 8.w,
//                                                     ),
//                                                     CustomText(
//                                                       title: wifiTitle![index],
//                                                       fontSize: 12.sp,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       color: AppColors.black,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                             connectedDevices[
//                                                         wifiTitle![index]] ==
//                                                     true
//                                                 ? 'connected'
//                                                     .text
//                                                     .color(Colors.blue)
//                                                     .fontWeight(FontWeight.w600)
//                                                     .maxFontSize(12)
//                                                     .make()
//                                                 : Container(),
//                                           ],
//                                         ),
//                                         SizedBox(height: 5.h),
//                                         Divider(thickness: 1.w),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 15.h),
//                     GestureDetector(
//                       onTap: () {
//                         buildShowDialog(context, '');
//                       },
//                       child: CustomText(
//                         title: 'Add manually',
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.navyblue,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 290.h,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         // Get.to(() => HomeScreen());
//                       },
//                       child: Container(
//                         // height: 35.h,
//                         padding: EdgeInsets.symmetric(vertical: 15.h),
//                         width: 393.w,
//                         decoration: BoxDecoration(
//                             color: AppColors.navyblue,
//                             borderRadius: BorderRadius.circular(10.r)),
//                         child: Center(
//                           child: CustomText(
//                             title: "Connect Another Wifi",
//                             fontSize: 13.sp,
//                             fontWeight: FontWeight.w400,
//                             color: AppColors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // const AvailableNetworks(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void buildShowDialog(BuildContext context, String deviceIdentifier) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           insetPadding: EdgeInsets.symmetric(
//             horizontal: 17.w,
//           ),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: 14.w,
//             ),
//             height: 270.h,
//             width: MediaQuery.of(context).size.width,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 15.h),
//                 CustomText(
//                   title: 'Add Wifi',
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                 ),
//                 TextFormField(
//                   controller: _ssidController,
//                   decoration: InputDecoration(
//                     hintText: "SSID",
//                     hintStyle: TextStyle(fontSize: 12.sp),
//                   ),
//                 ),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: isPasswordVisible,
//                   decoration: InputDecoration(
//                     hintText: "Password",
//                     hintStyle: TextStyle(fontSize: 12.sp),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Checkbox(
//                       activeColor: AppColors.navyblue,
//                       value: isPasswordVisible,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           isPasswordVisible = !isPasswordVisible;
//                         });
//                       },
//                     ),
//                     SizedBox(width: 8.w),
//                     CustomText(
//                       title: 'Show Password',
//                       color: const Color(0xff252525),
//                       fontWeight: FontWeight.w400,
//                       fontSize: 10.sp,
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _ssidController.clear();
//                         _passwordController.clear();
//                       },
//                       child: CustomText(
//                         title: 'Cancel',
//                         color: const Color(0xff252525),
//                         fontWeight: FontWeight.w400,
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () async {
//                         // Check if both SSID and password controllers have non-empty values
//                         if (_ssidController.text.isNotEmpty &&
//                             _passwordController.text.isNotEmpty) {
//                           print("My SSID: ${_ssidController.text.toString()}");
//                           print(
//                               "My PASS: ${_passwordController.text.toString()}");
// String ssid=_ssidController.text.toString();
// String pass=_passwordController.text.toString();
//                               String wifiCred="$ssid,$pass,${userData['uid']}";

//                               List<int> data =wifiCred.codeUnits;
// await char.write(data,allowLongWrite: true); 

//                           AppConstants.showCustomSnackBar("data sent");

//                           Navigator.pop(context);
//                           // _ssidController.clear();
//                           // _passwordController.clear();

//                           setState(() {
//                             connectedDevices[deviceIdentifier] = true;
//                           });
//                           // _sendWifiCredentials();

//                           // String wifiData = "1321,abaa
//                           // List<int> data = wifiData.codeUnits;
//                           // await char.write(data, allowLongWrite: true);
//                         } else {
//                           // Show a message or take appropriate action if either SSID or password is empty
//                           AppConstants.showCustomSnackBar(
//                               "Please enter both SSID and password.");
//                         }
//                         // Get.to(() => blueT());
//                       },
//                       child: Container(
//                         // height: 30.h,
//                         padding: EdgeInsets.symmetric(vertical: 10.h),
//                         width: 80.w,
//                         decoration: BoxDecoration(
//                             color: AppColors.navyblue,
//                             borderRadius: BorderRadius.circular(8.r)),
//                         child: Center(
//                           child: CustomText(
//                             title: "Connect",
//                             fontSize: 13.sp,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.btntext,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
