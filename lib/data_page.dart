/* Page to show while looking for device */

import 'package:thales_wellness/components/bluetooth_handler.dart';
import 'package:thales_wellness/components/sensor_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataPage extends StatefulWidget {
  DataPage(
      {Key? key,
      required this.icon,
      required this.color,
      required this.title,
      required this.dataKey,
      this.interactive = false})
      : super(key: key);

  final String title;
  final Color color;
  final IconData icon;
  bool interactive;
  // key to access the data in the JSON
  final String dataKey;

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  bool switchState = false;

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
            BluetoothSubscriber(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Consumer<BluetoothHandler>(
                    builder: (context, bluetoothHandler, child) {
                  List<GraphData> sensorData =
                      bluetoothHandler.bluetoothDataToGraphData(widget.dataKey);
                  return SensorGraph(
                      title: widget.title, sensorData: sensorData);
                }),
                const SizedBox(width: 100),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Consumer<BluetoothHandler>(
                      builder: (context, bluetoothHandler, child) {
                        // parse for the average
                        List<GraphData> sensorData = bluetoothHandler
                            .bluetoothDataToGraphData(widget.dataKey);
                        return Text(
                          'Current: ${bluetoothHandler.bluetoothData.isEmpty || sensorData.last.y == -1 ? "None" : sensorData.last.y.toStringAsFixed(0)}\nAverage: ${calculateAverage(sensorData).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                    if (widget.interactive)
                      Column(
                        children: [
                          Consumer<BluetoothHandler>(
                            builder: (context, bluetoothHandler, child) {
                              return Transform.scale(
                                scale: 2,
                                alignment: Alignment.center,
                                child: Switch(
                                  value: switchState,
                                  activeColor: widget.color,
                                  splashRadius: 20,
                                  onChanged: (bool value) {
                                    setState(() {
                                      if (value) {
                                        bluetoothHandler.sendData("1");
                                      } else {
                                        bluetoothHandler.sendData("0");
                                      }
                                      switchState = value;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                          const Text(
                            "Activate Destressor Device",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  widget.icon,
                  size: 120,
                  color: widget.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double calculateAverage(List<GraphData> nums) {
  double sum = 0;
  int numEntries = 0;
  for (GraphData entry in nums) {
    if (entry.y != -1) {
      sum += entry.y;
      numEntries += 1;
    }
  }
  if (numEntries > 0) {
    return sum / numEntries;
  } else {
    return 0;
  }
}
