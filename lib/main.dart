import 'package:ecg_app/data_page.dart';
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
          primary: const Color(0xFF333333),
          background: const Color(0xFF4F5357),
        ), // Color Scheme
      ),
      home: const MyHomePage(title: 'Wellness Home Page'),
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
        toolbarHeight: 80,
        title: Text(
          widget.title, 
          style: const TextStyle(fontSize: 30),
        ),
        actions: [Padding(padding: EdgeInsets.only(right: 50), child: SizedBox(width: 350, height: 350, child: Image.asset('images/thales_logo_no_background.png')))],
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
                  color: Color.fromARGB(255, 163, 78, 213),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
