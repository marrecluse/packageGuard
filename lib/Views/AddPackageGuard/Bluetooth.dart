import 'dart:async';

import 'dart:convert';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:packageguard/Views/Wifi_Connect/wifi_connect.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:velocity_x/velocity_x.dart';

// import '../../Widgets/custom_appbar.dart';
import '../../Widgets/drawer.dart';
import '../Login/login.dart';

class BluetoothController extends GetxController {
  Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  Rx<BluetoothCharacteristic?> characteristic =
      Rx<BluetoothCharacteristic?>(null);

  void setConnectedDevice(BluetoothDevice device) {
    connectedDevice.value = device;
  }

  void setCharacteristic(BluetoothCharacteristic char) {
    characteristic.value = char;
  }
}

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _selectedDevice;
  bool isSelected = false;
  BluetoothCharacteristic? _characteristic;
  Stream<List<int>> _listStream = Stream.empty();
  StreamSubscription<List<int>>? _streamSubscription;
  List<BluetoothDevice> _discoveredDevices = [];

  final userController = Get.find<UserController>();

// Access user data
  Map<String, dynamic> userData = {};
  bool isLoading = true; // Add this variable to track loading state
  bool isConnected = false;
  String connectionStatus = 'Connect';
  @override
  void initState() {
    super.initState();
    _initBluetooth();
    _checkPermissionsAndStartScanning();
    requestBluetoothPermissions();
    userData = userController.userData as Map<String, dynamic>;
    print(userData);
    print(userData['ProfileImage']);
    isLoading = false; // Set loading state to false when data is loaded
  }

  Future<void> _checkPermissionsAndStartScanning() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      // Location permission granted, you can start scanning here
      _scanForDevices();
    } else {
      // Request location permission
      final result = await Permission.location.request();

      if (result.isGranted) {
        // Location permission granted, you can start scanning here
        _scanForDevices();
      } else {
        print('Location permission denied');
      }
    }
  }

  Future<void> requestBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect, // Add this line
      Permission.bluetoothScan,
    ].request();
  }

  void _initBluetooth() {
    _flutterBlue.state.listen((state) {
      if (state == BluetoothState.on) {
        _scanForDevices();
      }
    });
  }

  final BluetoothController bluetoothController = Get.find();
  void _scanForDevices() {
    setState(() {
      _discoveredDevices.clear();
    });
    _flutterBlue.scan(timeout: Duration(seconds: 4)).listen((scanResult) {
      print("Found device: ${scanResult.device.name}");
      setState(() {
        _discoveredDevices.add(scanResult.device);
      });
    }).onDone(() {
      // Scanning is done, you can handle this event if needed
    });
  }

  void _stopScanning() {
    _flutterBlue.stopScan();
  }

  Future<BluetoothDevice?> _connectToDevice(BluetoothDevice device) async {
    if (device != null) {
      await device.connect();

      bluetoothController.setConnectedDevice(device);
      _discoverServices(device);

      setState(() {
        connectionStatus = 'Connected';
      });
      print('I am here');
      return device;
    }
  }

  void _discoverServices(BluetoothDevice device) async {
    if (device != null) {
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) {
        service.characteristics.forEach((characteristic) {
          setState(() {
            _characteristic = characteristic;
            bluetoothController.setCharacteristic(characteristic);
          });

          _streamSubscription = _characteristic?.value.listen((data) {
            _interpretReceivedData(utf8.decode(data));
          });
        });
      });
    }
  }

  void _interpretReceivedData(String data) {
    print("Received data: $data");
  }

  void _sendData(String dataString) async {
    List<int> data = utf8.encode(dataString);
    if (_selectedDevice != null && _characteristic != null) {
      await _characteristic?.write(data);
    }
  }

  Future<void> disconnectFromDevice() async {
    try {
      print('the selected device $_selectedDevice is');
      if (_selectedDevice != null ||
          _selectedDevice!.state == BluetoothDeviceState.connected) {
        await _selectedDevice!.disconnect();
        // Optionally, perform additional cleanup or actions after disconnecting
        _selectedDevice = null;
      } else {
        // Handle the case when the device is not connected
        print("Device is not connected.");
      }
    } catch (e) {
      print("Error disconnecting from device: $e");
    }
  }

  @override
  void dispose() {
    disconnectFromDevice();
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> onRefresh() async {
    await Future.delayed(Duration(seconds: 2));
    _scanForDevices();
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = userData['ProfileImage'].toString().trim();
    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        body: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CustomAppBar(
                  image: profileImage,
                  title: '${userData['Name']}',
                ),
                if (isLoading)
                  CircularProgressIndicator(), // Display CircularProgressIndicator while loading
              ],
            ),
            SingleChildScrollView(
              child: Center(
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Swipe To Scan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      // ElevatedButton(
                      //   onPressed: _scanForDevices,
                      //   child: Text('Scan for Devices'),
                      // ),
                      // // ElevatedButton(
                      // //   onPressed: () {
                      // //     disconnectFromDevice();
                      // //   },
                      // //   child: Text('Disconnect'),
                      // // ),
                      10.heightBox,
                      if (_discoveredDevices.isNotEmpty)
                        Container(
                          height: context.screenHeight * .6,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (var device in _discoveredDevices)
                                  Container(
                                    width: context.screenWidth * .9,
                                    child: Card(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedDevice = device;
                                          });
                                        },
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.bluetooth,
                                            size: 35,
                                          ),
                                          title: Center(
                                            child: Text(device.name ??
                                                'Unknown Device'),
                                          ),
                                          subtitle: Center(
                                              child:
                                                  Text(device.id.toString())),
                                          onTap: () {
                                            setState(() {
                                              _selectedDevice = device;
                                            });
                                            // _connectToDevice(device);
                                          },
                                          trailing: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectedDevice = device;
                                              });
                                              _connectToDevice(
                                                  _selectedDevice!);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: _selectedDevice == device
                                                  ? Colors.blue
                                                  : Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                              ),
                                            ),
                                            child: Text(
                                              _selectedDevice == device
                                                  ? 'Connected'
                                                  : 'Connect',
                                              style: TextStyle(
                                                  color:
                                                      _selectedDevice == device
                                                          ? Colors.white
                                                          : Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                // if (_selectedDevice != null)
                                //   Column(
                                //     children: [
                                //       Column(
                                //         children: [
                                //           Text(
                                //               'Selected Device: ${_selectedDevice?.name}'),
                                //           ElevatedButton(
                                //             onPressed: () {
                                //               _connectToDevice(
                                //                   _selectedDevice!);
                                //             },
                                //             child: Text('Connect to Device'),
                                //           ),
                                //         ],
                                //       ),
                                //       StreamBuilder<List<int>>(
                                //         stream: _listStream,
                                //         initialData: [],
                                //         builder: (context, snapshot) {
                                //           if (snapshot.connectionState ==
                                //               ConnectionState.active) {
                                //             final receivedData =
                                //                 snapshot.data ?? <int>[];
                                //             return Text(
                                //                 'Received Data: ${utf8.decode(receivedData)}');
                                //           } else {
                                //             return Text('No data received');
                                //           }
                                //         },
                                //       ),
                                //     ],
                                //   ),
                              ],
                            ),
                          ),
                        ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     _sendData('Hello');
                      //   },
                      //   child: Text('Send Data'),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            10.heightBox,
            ElevatedButton(
                onPressed: () {
                  Get.to(() => WifiConnect());
                },
                child: Text('Connect to WiFi'))
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BluetoothPage(),
  ));
}
