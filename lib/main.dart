import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thales_wellness/bluetooth_debugger/bluetooth_debug_monitor.dart';
import 'package:thales_wellness/usb_debugger/usb_debug_monitor.dart';
import 'components/custom_icon_with_button.dart';
import 'components/bluetooth_handler.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BluetoothHandler(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thales Wellness',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF333333),
          background: const Color(0xFF4F5357),
        ), // Color Scheme
      ),
      home: const MyHomePage(
        title: 'Wellness Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  // BluetoothHandler bluetoothHandler;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String newestData = "None";

  Future<void> initBluetooth(BluetoothHandler bluetoothHandler) async {
    await bluetoothHandler.startBluetooth();
    await bluetoothHandler.startScanning();
  }

  @override
  void initState() {
    super.initState();
    initBluetooth(context.read<BluetoothHandler>());
  }

  void setNewestData(String newData) {
    setState(() {
      newestData = newData;
    });
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
              // child: Image.asset('images/thales_logo_no_background.png'),
              child: IconButton(
                icon: Image.asset('images/thales_logo_no_background.png'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BluetoothDebugMonitorPage(title: widget.title)),
                  );
                },
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomIconWithButton(
                  icon: FontAwesomeIcons.heartPulse,
                  color: const Color(0xFFD54E4E),
                  text: "Heart Rate Monitor",
                  dataKey: "heart_rate",
                ),
                CustomIconWithButton(
                  icon: Icons.show_chart,
                  color: const Color.fromARGB(255, 163, 78, 213),
                  text: "Stress Level Monitor",
                  interactive: true,
                  dataKey: "stress",
                ),
                CustomIconWithButton(
                  icon: Icons.water_drop,
                  color: const Color(0xFF7E99C3),
                  text: "Hydration Sensor",
                  dataKey: "hydration",
                ),
                CustomIconWithButton(
                  icon: Icons.thermostat,
                  color: const Color(0xFF639269),
                  text: "Body Temp Monitor",
                  dataKey: "temperature",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
