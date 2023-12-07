import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thales_wellness/usb_debugger/usb_debug_monitor.dart';
import 'components/custom_icon_with_button.dart';
import 'components/bluetooth_handler.dart';
import 'components/usb_handler.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => USBHandler(),
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
  BluetoothHandler bluetoothHandler = BluetoothHandler();

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  Future<void> initBluetooth() async {
    await bluetoothHandler.startBluetooth();
    await bluetoothHandler.startScanning();
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
      home: MyHomePage(
        title: 'Wellness Home Page',
        bluetoothHandler: bluetoothHandler,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.bluetoothHandler})
      : super(key: key);

  final String title;
  BluetoothHandler bluetoothHandler;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool switchPressed = false;

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomIconWithButton(
                  icon: FontAwesomeIcons.heartPulse,
                  color: const Color(0xFFD54E4E),
                  text: "Heart Rate Monitor",
                ),
                CustomIconWithButton(
                  icon: Icons.show_chart,
                  color: const Color.fromARGB(255, 163, 78, 213),
                  text: "Stress Level Monitor",
                  interactive: true,
                ),
                CustomIconWithButton(
                  icon: Icons.water_drop,
                  color: const Color(0xFF7E99C3),
                  text: "Hydration Sensor",
                ),
                CustomIconWithButton(
                  icon: Icons.thermostat,
                  color: const Color(0xFF639269),
                  text: "Body Temp Monitor",
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => USBDebugMonitorPage(
                              title: "USB Debug Monitor Page",
                              usbHandler: context.read<USBHandler>(),
                            ),
                          ),
                        );
                      },
                      child: Consumer<USBHandler>(
                        builder: (context, usbHandler, child) => Text(
                            usbHandler.currentlyConnectedDevice == null
                                ? "no device"
                                : "device connected"),
                      ),
                    ),
                    // subscribe to the stream
                    const USBSubscriber(),
                    Consumer<USBHandler>(builder: (context, usbHandler, child) {
                      if (usbHandler.serialData.isNotEmpty) {
                        return Text(
                          "Newest data: \"${usbHandler.serialData.last}\"",
                        );
                      } else {
                        return const Text("No data available");
                      }
                    }),
                    ElevatedButton(
                      onPressed: () {
                        widget.bluetoothHandler.startScanning();
                      },
                      child: const Text("connect BLE"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.bluetoothHandler.sendData("1");
                      },
                      child: const Text("BLE command"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
