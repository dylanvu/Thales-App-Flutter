import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'package:thales_wellness/components/sensor_graph.dart';

import 'package:provider/provider.dart';
import 'package:thales_wellness/scripts/stress.dart';

class BluetoothHandler extends ChangeNotifier {
  BluetoothDevice? device;
  StreamSubscription<List<ScanResult>>? subscription;
  String thalesSeriviceUUID = "af97994f-4d78-457e-8e10-05dd0ce6f680";
  List<String> bluetoothData = [];

  StreamSubscription<List<int>>? _subscription;

  int bluetoothDataMax = 50;

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
            if (bluetoothData.length > bluetoothDataMax) {
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

  List<GraphData> bluetoothDataToGraphData(String dataKey) {
    List<GraphData> sensorData = [];
    Map<String, dynamic> bluetoothDataJSON = {};
    //List<Map<String, dynamic>> bluetoothDataList = [];
    int count = 0;
    double value;
    List<double> heartRates = [];

    for (String entry in bluetoothData) {
      bluetoothDataJSON = jsonDecode(entry);
      //bluetoothDataList.add(bluetoothDataJSON);

      //count = bluetoothData.indexOf(entry);
      //I was gonna use this code but then it's like stuck around 0 and 1s
      //Is the string array constantly resetting? or I'm probably doing smth wrong
      //also is the array stuck at like 20 lol
      //but anyways current code kinda works, hopefully this is what u need
      //btw I also changed the max of the x axis to 50 just to check
      count += 1;
      if (dataKey == "stress") {
        // pull in the stress algorithm instead
        // grab the previous heart rates
        heartRates.add(bluetoothDataJSON["heart_rate"]);

        // put these into the stress level calculation
        StressLevel stressLevel = stressLevelCalculation(heartRates);
        // map stress level to 0 (low), 1 (normal), and 2 (high)
        if (stressLevel == StressLevel.HIGH) {
          value = 2;
        } else if (stressLevel == StressLevel.LOW) {
          value = 0;
        } else {
          value = 1;
        }
      } else {
        value = bluetoothDataJSON[dataKey];
      }
      sensorData.add(GraphData(count.toString(), value));
    }
    return sensorData;
  }
}

/// this widget is used solely to subscribe to the stream

class BluetoothSubscriber extends StatefulWidget {
  void Function(String)? callback;

  BluetoothSubscriber({super.key, this.callback});

  @override
  State<BluetoothSubscriber> createState() => _BluetoothSubscriberState();
}

class _BluetoothSubscriberState extends State<BluetoothSubscriber> {
  @override
  void initState() {
    super.initState();
    // subscribe
    context.read<BluetoothHandler>().subscribe(callback: widget.callback);
  }

  @override
  void dispose() {
    super.dispose();
    // unsubscribe
    print("dispose unsubscribe");
    context.read<BluetoothHandler>().disposeStream();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
