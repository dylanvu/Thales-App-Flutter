/* Page to show after looking for device */

// The hardware team has learned some software

import 'package:flutter/material.dart';

import 'device_search.dart';
import 'main.dart';

class DevicePairingResultPage extends StatefulWidget {
  const DevicePairingResultPage(
      {Key? key, required this.title, required this.result})
      : super(key: key);

  final String title;
  final bool result;

  @override
  State<DevicePairingResultPage> createState() =>
      _DevicePairingResultPageState();
}

class _DevicePairingResultPageState extends State<DevicePairingResultPage> {
  @override
  Widget build(BuildContext context) {
    String resultString =
        widget.result ? "Successfully connected" : "Could not find device";
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(25),
              child: Text(
                resultString,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            widget.result
                ? const Icon(
                    Icons.bluetooth_connected,
                    size: 200,
                    color: Colors.blue,
                  )
                : const Icon(
                    Icons.bluetooth_disabled,
                    size: 200,
                    color: Colors.blue,
                  ),
            if (!widget.result)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            DevicePairingPage(title: widget.title),
                      ),
                    );
                  },
                  child: const Text("Try Again"),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(
                          title: widget.title, pairResult: widget.result),
                    ),
                  );
                },
                child: const Text("Return to Home Page"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
