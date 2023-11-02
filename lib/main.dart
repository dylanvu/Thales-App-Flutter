import 'package:ecg_app/device_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'components/icon_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECG App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 255, 145, 145),
          secondary: const Color.fromARGB(255, 120, 148, 230),
          background: const Color.fromARGB(255, 32, 32, 32),
        ), // Color Scheme
      ),
      home: const MyHomePage(
          title: 'Thales Wellness App Home Page', pairResult: false),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.pairResult})
      : super(key: key);

  final String title;
  final bool pairResult;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool switchPressed = false;

  @override
  Widget build(BuildContext context) {
    String devicePairingResult =
        widget.pairResult ? 'ECG Graph Display' : 'No Device Found...';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      FontAwesomeIcons.heartPulse,
                      size: 100,
                      color: Colors.red,
                    ),
                    ElevatedButton(
                        onPressed: () {},
                        child: const Text("Heart Rate Monitor")),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.water_drop,
                      size: 100,
                      color: Colors.blue,
                    ),
                    ElevatedButton(
                        onPressed: () {},
                        child: const Text("Hydration Sensor")),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.thermostat,
                      size: 100,
                      color: Colors.green,
                    ),
                    ElevatedButton(
                        onPressed: () {},
                        child: const Text("Body Temperature Monitor")),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                print('Pairing Device!');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        DevicePairingPage(title: widget.title),
                  ),
                );
              },
              child: const Text(
                'Pair with ECG Device',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              FontAwesomeIcons.heartPulse,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
