import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Views/Wifi_Connect/wifi_connect.dart';

import 'package:velocity_x/velocity_x.dart';

import '../Widgets/service_tile.dart';
import '../Widgets/characteristic_tile.dart';
import '../Widgets/descriptor_tile.dart';
import '../Utils/snackbar.dart';
import '../Utils/extra.dart';

// class BluetoothController extends GetxController {
//   Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
//   Rx<BluetoothCharacteristic?> characteristic =
//       Rx<BluetoothCharacteristic?>(null);

//   void setConnectedDevice(BluetoothDevice device) {
//     connectedDevice.value = device;
//   }

//   void setCharacteristic(BluetoothCharacteristic char) {
//     characteristic.value = char;
//   }
// }

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  late BluetoothCharacteristic deviceCharacteristic;
  int? _rssi;
  int? _mtuSize;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<int> _mtuSubscription;

  @override
  void initState() {
    super.initState();
    onDiscoverServicesPressed();
    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      _connectionState = state;

      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }
      if (mounted) {
        setState(() {});
      }
    });

    _mtuSubscription = widget.device.mtu.listen((value) {
      _mtuSize = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isDisconnectingSubscription =
        widget.device.isDisconnecting.listen((value) {
      _isDisconnecting = value;
      if (mounted) {
        setState(() {});
      }
    });
  }
  // final BluetoothController bluetoothController = Get.find();

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Future onConnectPressed() async {
    try {
      await widget.device.connectAndUpdateStream();
      Snackbar.show(ABC.c, "Connect: Success", success: true);
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        // Snackbar.show(ABC.c, prettyException("Connect Error: ReConnect", e),
        //     success: false);
      }
    }
  }

  Future onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
      Snackbar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false);
    }
  }

  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream();
      // bluetoothController.setConnectedDevice(widget.device);
//       _discoverServices(device);
      Snackbar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e) {
      // Snackbar.show(ABC.c, prettyException("Disconnect Error: ReConnect", e),
      //     success: false);
    }
  }


  Future onDiscoverServicesPressed() async {
    if (mounted) {
      setState(() {
        _isDiscoveringServices = true;
      });
    }
    try {
      _services = await widget.device.discoverServices();
      Snackbar.show(ABC.c, "Discover Services: Success", success: true);
    } catch (e) {
      // Snackbar.show(ABC.c, prettyException("Discover Services Error, ReConnect:", e),
      //     success: false);
          
    }
    if (mounted) {
      setState(() {
        _isDiscoveringServices = false;
      });
    }
  }

  Future onRequestMtuPressed() async {
    try {
      await widget.device.requestMtu(223, predelay: 0);
      Snackbar.show(ABC.c, "Request Mtu: Success", success: true);
    } catch (e) {
      // Snackbar.show(ABC.c, prettyException("Change Mtu Error: ReConnect", e),
      //     success: false);
    }
  }

  List<Widget> _buildServiceTiles(BuildContext context, BluetoothDevice d) {
    return _services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map((c) => _buildCharacteristicTile(c))
                .toList(),
          ),
        )
        .toList();
  }

  CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicTile(
      characteristic: c,
      descriptorTiles:
          c.descriptors.map((d) => DescriptorTile(descriptor: d)).toList(),
    );
  }

  Widget buildSpinner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget buildRemoteId(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('${widget.device.remoteId}'),
    );
  }

  Widget buildRssiTile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isConnected
            ? const Icon(Icons.bluetooth_connected,color: Colors.blue,)
            : const Icon(Icons.bluetooth_disabled),
        Text(((isConnected && _rssi != null) ? '${_rssi!} dBm' : ''),
            style: Theme.of(context).textTheme.bodySmall)
      ],
    );
  }

  Widget buildGetServices(BuildContext context) {
    return IndexedStack(
      index: (_isDiscoveringServices) ? 1 : 0,
      children: <Widget>[
        TextButton(
          child: Visibility(
            visible: false,
            child: Text(
              "Get Services",
              style: TextStyle(
                color: AppColors.navyblue,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          onPressed: onDiscoverServicesPressed,
        ),
        const IconButton(
          icon: SizedBox(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
            width: 18.0,
            height: 18.0,
          ),
          onPressed: null,
        )
      ],
    );
  }

  Widget buildMtuTile(BuildContext context) {
    return ListTile(
        title: const Text('MTU Size'),
        subtitle: Text('$_mtuSize bytes'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onRequestMtuPressed,
        ));
  }

  Widget buildConnectButton(BuildContext context) {
    return Row(children: [
      if (_isConnecting || _isDisconnecting) buildSpinner(context),
      TextButton(
          onPressed: _isConnecting
              ? onCancelPressed
              : (isConnected ? onDisconnectPressed : onConnectPressed),
          child: Text(
            _isConnecting ? "CANCEL" : (isConnected ? "DISCONNECT" : "CONNECT"),
            style: Theme.of(context)
                .primaryTextTheme
                .labelLarge
                ?.copyWith(color: Colors.white),
          ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.navyblue,
          title: Text(widget.device.platformName),
          actions: [buildConnectButton(context)],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
           
              buildRemoteId(context),
              
              ListTile(
                leading: buildRssiTile(context),
                title: Center(
                  child: Text(
                    'Device is ${_connectionState.toString().split('.')[1]}.',
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                ),
                trailing: buildGetServices(context),
              ),
              // buildMtuTile(context),
              ..._buildServiceTiles(context, widget.device),
              SizedBox(
                height: context.screenWidth*1.2,
              ),

              ElevatedButton(
                
                  style: ElevatedButton.styleFrom(primary: AppColors.navyblue,minimumSize: Size(30, 52)),
                  onPressed: () async {
                    List<BluetoothService> services =
                        await widget.device.discoverServices();
                    services.forEach((service) {
                      // do something with service
                      var characteristics = service.characteristics;
                      for (BluetoothCharacteristic c in characteristics) {
                        if (c.properties.write) {
                          deviceCharacteristic = c;
                          print(
                              "deviceCharacteristic is $deviceCharacteristic");
                        }            

                      }
                    });
                    Get.to(() => WifiConnect(deviceChar: deviceCharacteristic));
                  },
                  child: Text('Connect with WIFI',style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: context.screenWidth*0.03,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,color: Colors.white

                  ),)),
            ],
          ),
        ),
      ),
    );
  }
}
