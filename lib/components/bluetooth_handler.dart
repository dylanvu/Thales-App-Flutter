import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class BluetoothHandler {
  BluetoothDevice? _device;
  StreamSubscription<List<ScanResult>>? subscription;

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
          print("Thales connected");
          print(result);
          _device = result.device;
          await stopScanning();
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

  Future<void> connectToDevice(BluetoothDevice device) async {
    _device = device;
    if (_device != null) {
      await _device!.connect();
      print('Connected to ${_device!.platformName}');
    }
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    if (_device != null) {
      print('Disconnecting from ${_device!.platformName}');
      await _device!.disconnect();
      _device == null;
    }
  }

  Future<void> sendData(String data) async {
    if (_device == null) {
      print('Error: No device connected');
      return;
    }

    if (_device != null) {
      await _device!.discoverServices();
      List<BluetoothService> services = await _device!.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          await characteristic.write(utf8.encode(data));
        }
      }
    } else {
      print("Bluetooth peripheral not found");
    }
  }
}
