import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

import 'package:provider/provider.dart';

class USBHandler extends ChangeNotifier {
  // list of devices that the USB handler currently sees
  List<UsbDevice> availableDevices = [];

  // currently connected usb device
  UsbDevice? currentlyConnectedDevice;
  // currently connected usb port
  UsbPort? currentlyConnectedPort;

  // something needed for connecting
  Transaction<String>? _transaction;

  // subscription
  StreamSubscription<String>? _subscription;

  // current serial data
  List<String> serialData = [];

  @override
  String toString() {
    return "c.c.d: ${currentlyConnectedDevice != null ? currentlyConnectedDevice!.deviceName : "none"}   c.c.p: $currentlyConnectedPort";
  }

  // get all the available devices
  Future<void> getPorts() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    print(devices);

    availableDevices = devices;
    notifyListeners();
  }

  Future<bool> connectTo(device) async {
    serialData.clear();

    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (currentlyConnectedPort != null) {
      currentlyConnectedPort!.close();
      currentlyConnectedPort = null;
    }

    if (device == null) {
      currentlyConnectedDevice = null;
      notifyListeners();
      return true;
    }

    currentlyConnectedPort = await device.create();
    if (await (currentlyConnectedPort!.open()) != true) {
      notifyListeners();
      return false;
    }
    currentlyConnectedDevice = device;

    await currentlyConnectedPort!.setDTR(true);
    await currentlyConnectedPort!.setRTS(true);
    await currentlyConnectedPort!.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    notifyListeners();
    return true;
  }

  // create the stream listener for incoming usb data
  void subscribe({void Function(String)? callback}) {
    if (currentlyConnectedPort == null) {
      print("currently connected port is null");
      return;
    }
    _transaction = Transaction.stringTerminated(
        currentlyConnectedPort!.inputStream as Stream<Uint8List>,
        Uint8List.fromList([13, 10]));

    // open the stream
    _subscription = _transaction!.stream.listen((String line) {
      serialData.add(line);
      if (serialData.length > 20) {
        serialData.removeAt(0);
      }
      // call our function to handle the update with the new data
      if (callback != null) {
        callback(line);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void disposeStream() {
    if (_subscription != null) {
      _subscription!.cancel();
      _transaction!.dispose();
      _subscription = null;
      _transaction = null;
    }
  }
}

/// this widget is used solely to subscribe to the stream
class USBSubscriber extends StatelessWidget {
  const USBSubscriber({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<USBHandler>(
      builder: (context, usbHandler, child) {
        // subscribe here
        usbHandler.subscribe();
        return const SizedBox.shrink();
      },
    );
  }
}
