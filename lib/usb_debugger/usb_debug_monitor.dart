import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:thales_wellness/components/usb_handler.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class USBDebugMonitorPage extends StatefulWidget {
  final String title;
  USBHandler usbHandler;

  USBDebugMonitorPage({
    Key? key,
    required this.title,
    required this.usbHandler,
  }) : super(key: key);

  @override
  _USBDebugMonitorPageState createState() => _USBDebugMonitorPageState();
}

class _USBDebugMonitorPageState extends State<USBDebugMonitorPage> {
  UsbPort? _port;
  String _status = "Idle";
  List<Widget> _ports = [];
  List<Widget> _serialData = [];

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  final TextEditingController _textController = TextEditingController();

  void updateSerialData(String newData) {
    setState(() {
      _serialData.add(Text(newData));
      if (_serialData.length > 20) {
        _serialData.removeAt(0);
      }
    });
  }

  Future<bool> _connectTo(device) async {
    bool connectionRes = await widget.usbHandler.connectTo(device);
    if (!connectionRes) {
      return false;
    }

    if (device == null) {
      setState(() {
        _status = "Disconnected";
      });
      _device = null;
      return true;
    } else {
      _device = device;
      // open the stream
      widget.usbHandler.subscribe(callback: updateSerialData);
    }

    setState(() {
      _status = "Connected";
      _port = widget.usbHandler.currentlyConnectedPort;
    });
    return true;
  }

  void _getPorts() async {
    _ports = [];
    await widget.usbHandler.getPorts();

    List<UsbDevice> devices = widget.usbHandler.availableDevices;

    if (!devices.contains(_device)) {
      _connectTo(null);
    }
    print(devices);

    devices.forEach((device) {
      _ports.add(ListTile(
          leading: const Icon(Icons.usb),
          title: Text(device.productName!),
          subtitle: Text(device.manufacturerName!),
          trailing: ElevatedButton(
            child: Text(_device == device ? "Disconnect" : "Connect"),
            onPressed: () {
              _connectTo(_device == device ? null : device).then((res) {
                _getPorts();
              });
            },
          )));
    });

    setState(() {
      print(_ports);
    });
  }

  @override
  void initState() {
    super.initState();

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });

    _device = widget.usbHandler.currentlyConnectedDevice;

    _getPorts();

    setState(() {
      _status = widget.usbHandler.currentlyConnectedDevice == null
          ? "Disconnected"
          : "Connected";

      _port = widget.usbHandler.currentlyConnectedPort;
    });

    if (widget.usbHandler.currentlyConnectedDevice != null) {
      // open the stream
      widget.usbHandler.subscribe(callback: updateSerialData);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.usbHandler.disposeStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 30),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 50),
              child: SizedBox(
                  width: 350,
                  height: 350,
                  child: Image.asset('images/thales_logo_no_background.png')))
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
                _ports.length > 0
                    ? "Available Serial Ports"
                    : "No serial devices available",
                style: Theme.of(context).textTheme.titleLarge),
            ..._ports,
            Text('Status: $_status\n'),
            Text('info: ${_port.toString()}\n'),
            ListTile(
              title: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Text To Send',
                ),
              ),
              trailing: ElevatedButton(
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        String data = "${_textController.text}\r\n";
                        // await _port!.write(Uint8List.fromList(data.codeUnits));
                        await _port!.write(Uint8List.fromList(data.codeUnits));
                        _textController.text = "";
                      },
                child: const Text("Send"),
              ),
            ),
            Text("Result Data", style: Theme.of(context).textTheme.titleLarge),
            ..._serialData,
          ],
        ),
      ),
    );
  }
}
