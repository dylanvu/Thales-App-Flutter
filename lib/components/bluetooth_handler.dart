import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class BluetoothHandler {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;

  Future<void> startBluetooth() async {
    // get permissions
    if (await Permission.bluetooth.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted) {
      print("Starting bluetooth scanning");
      await flutterBlue.startScan(timeout: const Duration(seconds: 4));

      flutterBlue.scanResults.listen((List<ScanResult> results) {
        // Process scan results
        for (ScanResult result in results) {
          print('Device found: ${result.device.name}');
          // You can use the result.2device.identifier to identify your ESP32
        }
      });
      print("Done bluetooth scanning");
    } else {
      // ask for permissions
      print("One or more bluetooth permissions are not granted");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    _device = device;
    if (_device != null) {
      await _device!.connect();
      print('Connected to ${_device!.name}');
    }
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    if (_device != null) {
      print('Disconnecting from ${_device!.name}');
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
