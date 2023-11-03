import 'package:ecg_app/device_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'components/custom_icon_with_button.dart';

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
      home: const MyHomePage(title: 'Thales Wellness App Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

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
        title: Text(widget.title),
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
                  color: Colors.red,
                  text: "Heart Rate Monitor",
                ),
                CustomIconWithButton(
                  icon: Icons.water_drop,
                  color: Colors.blue,
                  text: "Hydration Sensor",
                ),
                CustomIconWithButton(
                  icon: Icons.thermostat,
                  color: Colors.green,
                  text: "Body Temp Monitor",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
