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
  int scanTimeout = 15;

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
          timeout: Duration(seconds: scanTimeout),
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
          // Add a delay to give some time for the connection to establish
          await Future.delayed(const Duration(seconds: 2));
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
      // await device!.connect(autoConnect: true, mtu: null);
      await device!.connect();
      print('Connected to ${device!.platformName}');
      device = newDevice;
      notifyListeners();
      print("done notify");
    }
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    // cancel the stream
    print('Disconnecting from ${device!.platformName}');
    disposeStream();
    await device.disconnect();
    this.device = null;
    notifyListeners();
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
            // do additional processing to the string. This is Thales specific code
            // convert to JSON
            Map<String, dynamic> bluetoothDataJSON = jsonDecode(resultString);
            // add new entries: RMSSD and stress level
            // grab all the heart rates
            List<double> heartRates = [];
            for (String entry in bluetoothData) {
              Map<String, dynamic> dataJSON = jsonDecode(entry);
              double heartRate = dataJSON["heart_rate"];
              if (heartRate > 0) {
                heartRates.add(heartRate);
              }
            }
            double stressValue;
            double rmssd;
            if (heartRates.isNotEmpty) {
              Stress stress = stressLevelCalculation(heartRates);
              StressLevel stressLevel = stress.stressLevel;
              rmssd = stress.rmssd;

              // map stress level to 0 (low), 1 (normal), and 2 (high)
              if (stressLevel == StressLevel.HIGH) {
                stressValue = 2;
              } else if (stressLevel == StressLevel.LOW) {
                stressValue = 0;
              } else {
                stressValue = 1;
              }
            } else {
              stressValue = -1;
              rmssd = -1;
            }

            bluetoothDataJSON["stress"] = stressValue;

            // TODO: calculate RMSSD and add it
            bluetoothDataJSON["rmssd"] = rmssd;

            // turn back to a string
            resultString = jsonEncode(bluetoothDataJSON);
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
          // cleanup: cancel subscription when disconnected
          // device!.cancelWhenDisconnected(_subscription as StreamSubscription);
          // notifyListeners();
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
      value = bluetoothDataJSON[dataKey];
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
    BluetoothHandler bluetoothHandler = context.read<BluetoothHandler>();

    var disconnectionSubscription = bluetoothHandler.device?.connectionState
        .listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        if (bluetoothHandler.device != null) {
          bluetoothHandler.disconnectDevice(bluetoothHandler.device!);
        }
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
        await bluetoothHandler.startScanning();
        // reconnect and resubscribe
        Timer.periodic(Duration(seconds: bluetoothHandler.scanTimeout),
            (timer) async {
          if (bluetoothHandler.device != null) {
            timer.cancel();
            // subscribe now
            // await bluetoothHandler.subscribe(callback: widget.callback);
          } else {
            await bluetoothHandler.startScanning();
          }
        });
      } else if (state == BluetoothConnectionState.connected) {
        // subscribe
        bluetoothHandler.subscribe(callback: widget.callback);
      }
    });

    // bluetoothHandler.device?.cancelWhenDisconnected(
    //     disconnectionSubscription as StreamSubscription,
    //     next: true);
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
