import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

class BluetoothHandler extends ChangeNotifier {
  BluetoothDevice? device;
  StreamSubscription<List<ScanResult>>? subscription;
  String thalesSeriviceUUID = "af97994f-4d78-457e-8e10-05dd0ce6f680";
  List<String> bluetoothData = [];

  StreamSubscription<List<int>>? _subscription;

  Future<void> startBluetooth() async {
    // first, check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
      } else {
        // show an error to the user, etc
      }
    });

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> startScanning() async {
    // listen to scan results
    if (subscription != null) {
      await stopScanning();
    }
    print("Starting Scan...");
    try {
      // android is slow when asking for all advertisments,
      // so instead we only ask for 1/8 of them
      int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
          continuousUpdates: true,
          continuousDivisor: divisor);
    } catch (e) {
      print("Start Scan Error: $e");
    }

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        if (result.device.platformName == "ESP32 Thales") {
          await stopScanning();
          await connectToDevice(result.device);
          // print(result);
          break;
        }
      }
    });
  }

  Future<void> stopScanning() async {
    if (subscription != null) {
      print("Stopping scan");
      // Stop scanning
      await FlutterBluePlus.stopScan();

      // cancel to prevent duplicate listeners
      subscription?.cancel();
      subscription = null;
    }
    return;
  }

  void getConnectedDevices() {
    List<BluetoothDevice> devices = FlutterBluePlus.connectedDevices;

    print(devices);
  }

  Future<void> connectToDevice(BluetoothDevice newDevice) async {
    device = newDevice;
    if (device != null) {
      await device!.connect();
      print('Connected to ${device!.platformName}');
      device = newDevice;
      notifyListeners();
      print("done notify");
    }
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    if (device != null) {
      // cancel the stream
      print('Disconnecting from ${device!.platformName}');
      disposeStream();
      await device!.disconnect();
      device == null;
    }
  }

  Future<void> sendData(String data) async {
    if (device == null) {
      print('Error: No device connected');
      return;
    }
    print("Sending data: $data");
    List<BluetoothService> services = await device!.discoverServices();
    bool wasSent = false;
    try {
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          print(characteristic.serviceUuid.toString());

          if (characteristic.properties.write &&
              characteristic.serviceUuid.toString() == thalesSeriviceUUID) {
            print("Sending to ${characteristic.characteristicUuid}");
            String readyData = "$data\r\n";
            await characteristic.write(Uint8List.fromList(readyData.codeUnits));
            wasSent = true;
          }
        }
      }
      if (!wasSent) {
        print("Could not send the data");
      }
    } on FlutterBluePlusException catch (e) {
      print("Flutter Blue Plus Exception");
      print(e.toString());
      print(e.description);
    } catch (e) {
      print("Something is weird");
      print(e);
    }
  }

  Future<void> receiveData() async {
    if (device == null) {
      print('Error: No device connected');
      return;
    }

    List<BluetoothService> services = await device!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.read &&
            characteristic.serviceUuid.toString() == thalesSeriviceUUID) {
          List<int> value = await characteristic.read();
          String resultString = String.fromCharCodes(value);
          print(resultString);
        }
      }
    }
  }

  Future<void> subscribe({void Function(String)? callback}) async {
    if (_subscription != null) {
      print("Disposing of old subscription");
      disposeStream();
      notifyListeners();
    }
    List<BluetoothService> services = await device!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.notify &&
            characteristic.serviceUuid.toString() == thalesSeriviceUUID) {
          // create a subscription
          print("Creating subscription now");
          _subscription = characteristic.onValueReceived.listen((value) {
            // convert to string
            String resultString = String.fromCharCodes(value);
            print(resultString);
            // add to data
            bluetoothData.add(resultString);
            if (bluetoothData.length > 20) {
              bluetoothData.removeAt(0);
            }
            // call callback if defined
            if (callback != null) {
              callback(resultString);
            }
            notifyListeners();
          });
          // now actually subscribe
          await characteristic.setNotifyValue(true);
          notifyListeners();
// cleanup: cancel subscription when disconnected
          // device!.cancelWhenDisconnected(_subscription);
        }
      }
    }
  }

  void disposeStream() {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
  }
}

/// this widget is used solely to subscribe to the stream
class BluetoothSubscriber extends StatelessWidget {
  void Function(String)? callback;

  BluetoothSubscriber({super.key, this.callback});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothHandler>(
      builder: (context, bluetoothHandler, child) {
        // subscribe here
        bluetoothHandler.subscribe(callback: callback);
        return const SizedBox.shrink();
      },
    );
  }
}
