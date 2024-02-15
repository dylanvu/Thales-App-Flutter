import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thales_wellness/components/bluetooth_handler.dart';
import 'package:usb_serial/transaction.dart';

class BluetoothDebugMonitorPage extends StatefulWidget {
  final String title;

  const BluetoothDebugMonitorPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _BluetoothDebugMonitorPageState createState() =>
      _BluetoothDebugMonitorPageState();
}

class _BluetoothDebugMonitorPageState extends State<BluetoothDebugMonitorPage> {
  List<Widget> _bluetoothData = [];

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;

  final TextEditingController _textController = TextEditingController();

  void updateBluetoothData(String newData) {
    setState(() {
      _bluetoothData.add(Text(newData));
      if (_bluetoothData.length > 20) {
        _bluetoothData.removeAt(0);
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            ElevatedButton(
              onPressed: () {
                context.read<BluetoothHandler>().startScanning();
              },
              child: const Text("Connect to BLE"),
            ),
            ElevatedButton(
              onPressed: () {
                context
                    .read<BluetoothHandler>()
                    .subscribe(callback: updateBluetoothData);
              },
              child: const Text("Subscribe"),
            ),
            Consumer<BluetoothHandler>(
                builder: (context, bluetoothHandler, child) {
              if (bluetoothHandler.device != null) {
                return Text(
                    "Connected to: ${bluetoothHandler.device!.platformName}");
              } else {
                return const Text("No BLE yet");
              }
            }),
            ElevatedButton(
              onPressed: () {
                context.read<BluetoothHandler>().sendData("1");
              },
              child: const Text("BLE command"),
            ),
            Text("Result Data", style: Theme.of(context).textTheme.titleLarge),
            ..._bluetoothData,
          ],
        ),
      ),
    );
  }
}
