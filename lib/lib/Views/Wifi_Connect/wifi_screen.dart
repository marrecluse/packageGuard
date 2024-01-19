import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Utils/app_constants.dart';
import 'package:packageguard/Views/Wifi_Connect/wifi_connect.dart';
import 'package:packageguard/Widgets/custom_text.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:get/get.dart';

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

class blueT extends StatefulWidget {
  const blueT({super.key});

  @override
  State<blueT> createState() => _blueTState();
}

final TextEditingController _ssidController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

class _blueTState extends State<blueT> {
  @override
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  List<dynamic> ssidList = <dynamic>[];
  var title = "**EMPTY**";
  bool shouldCheckCan = true;

  bool get isStreaming => true;
  void _sendWifiCredentials() {
    String ssid = _ssidController.text;
    String password = _passwordController.text;

    // Format the data to be sent to ESP32 (customize as per your ESP32 requirements)
    String wifiData = "$ssid,$password";
  }

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
    if (mounted) kShowSnackBar(context, "startScan: $result");
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

  Future<void> _startListeningToScanResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      subscription = WiFiScan.instance.onScannedResultsAvailable.listen(
        (result) {
          // Update the GetX controller with the new list
        },
      );
    }
  }

  void updateTitle(List<WiFiAccessPoint> ssid) {
    List<String> ssidList = ssid.map((ap) => ap.ssid).toList();
    setState(() {
      title = ssidList.join(', '); // Concatenate SSIDs for the title
      accessPoints = List.from(ssid); // Copy the list
    });

    print('My name is $title');
  }

  void _stopListeningToScanResults() {
    subscription?.cancel();
    setState(() => subscription = null);
  }

  @override
  void dispose() {
    super.dispose();
    // stop subscription for scanned results
    _stopListeningToScanResults();
  }

  @override
  void initState() {
    // TODO: implement initState
    _startListeningToScanResults(context);
    _getScannedResults(context);
    _startScan(context);
    super.initState();
  }

  // build toggle with label
  // Widget _buildToggle({
  //   String? label,
  //   bool value = false,
  //   ValueChanged<bool>? onChanged,
  //   Color? activeColor,
  // }) =>
  //     Row(
  //       children: [
  //         if (label != null) Text(label),
  //         Switch(value: value, onChanged: onChanged, activeColor: activeColor),
  //       ],
  //     );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ElevatedButton.icon(
                    //   icon: const Icon(Icons.perm_scan_wifi),
                    //   label: const Text('SCAN'),
                    //   onPressed: () async => _startScan(context),
                    // ),
                    // ElevatedButton.icon(
                    //   icon: const Icon(Icons.refresh),
                    //   label: const Text('GET'),
                    //   onPressed: () async => _getScannedResults(context),
                    // ),
                    // _buildToggle(
                    //   label: "STREAM",
                    //   value: isStreaming,
                    //   onChanged: (shouldStream) async => shouldStream
                    //       ? await _startListeningToScanResults(context)
                    //       : _stopListeningToScanResults(),
                    // ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: Center(
                    child: accessPoints.isEmpty
                        ? const Text("NO SCANNED RESULTS")
                        : ListView.builder(
                            itemCount: accessPoints.length,
                            itemBuilder: (context, i) =>
                                _AccessPointTile(accessPoint: accessPoints[i])),
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

/// Show tile for AccessPoint.
///
/// Can see details when tapped.
class _AccessPointTile extends StatelessWidget {
  final WiFiAccessPoint accessPoint;

  const _AccessPointTile({Key? key, required this.accessPoint})
      : super(key: key);

  // build row that can display info, based on label: value pair.
  Widget _buildInfo(String label, dynamic value) => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: Text(value.toString()))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final title = accessPoint.ssid.isNotEmpty ? accessPoint.ssid : "**EMPTY**";

    final signalIcon = accessPoint.level >= -80
        ? Icons.signal_wifi_4_bar
        : Icons.signal_wifi_0_bar;
    return ListTile(
        visualDensity: VisualDensity.compact,
        leading: Icon(signalIcon),
        title: Text(title),
        // subtitle: Text(accessPoint.capabilities),
        onTap: () =>
            // showDialog(
            //   context: context,
            //   builder: (context) => AlertDialog(
            //     title: Text(title),
            //     content: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         _buildInfo("BSSDI", accessPoint.bssid),
            //         _buildInfo("Capability", accessPoint.capabilities),
            //         _buildInfo("frequency", "${accessPoint.frequency}MHz"),
            //         _buildInfo("level", accessPoint.level),
            //         _buildInfo("standard", accessPoint.standard),
            //         _buildInfo(
            //             "centerFrequency0", "${accessPoint.centerFrequency0}MHz"),
            //         _buildInfo(
            //             "centerFrequency1", "${accessPoint.centerFrequency1}MHz"),
            //         _buildInfo("channelWidth", accessPoint.channelWidth),
            //         _buildInfo("isPasspoint", accessPoint.isPasspoint),
            //         _buildInfo(
            //             "operatorFriendlyName", accessPoint.operatorFriendlyName),
            //         _buildInfo("venueName", accessPoint.venueName),
            //         _buildInfo("is80211mcResponder", accessPoint.is80211mcResponder),
            //       ],
            //     ),
            //   ),
            // ),
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  insetPadding: EdgeInsets.symmetric(
                    horizontal: 17.w,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
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
                                // setState(() {
                                //   isPasswordVisible = value!;
                                // });
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
                                AppConstants.showCustomSnackBar("Connected!");
                                // Navigator.pop(context);

                                Get.to(() => blueT());
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
            ));
  }
}

/// Show snackbar.
void kShowSnackBar(BuildContext context, String message) {
  if (kDebugMode) print(message);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
