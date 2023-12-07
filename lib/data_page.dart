/* Page to show while looking for device */

import 'package:thales_wellness/components/sensor_graph.dart';
import 'package:flutter/material.dart';
import 'components/usb_handler.dart';
import 'package:provider/provider.dart';

class DataPage extends StatefulWidget {
  DataPage(
      {Key? key,
      required this.icon,
      required this.color,
      required this.title,
      this.interactive = false})
      : super(key: key);

  final String title;
  final Color color;
  final IconData icon;
  bool interactive;

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  List<String> data = [];

  List<GraphData> sensorData = [
    // GraphData('${0} min', double.parse(data.elementAt(0))),
    // GraphData('${5} min', 65),
    // GraphData('${10} min', 67),
    // GraphData('${15} min', 66),
    // GraphData('${20} min', 68),
  ];
  void addSensorData(String entry) {
    setState(() {
      sensorData.add(GraphData('${0} min', double.parse(entry)));
    });
  }

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
              padding: EdgeInsets.only(right: 50),
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
            const USBSubscriber(),
            Consumer<USBHandler>(builder: (context, usbHandler, child) {
              if (usbHandler.serialData.isNotEmpty) {
                  addSensorData(usbHandler.serialData.last);
              
                return Text(
                  "Newest data: \"${usbHandler.serialData.last}\"", 
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                );
              } else {
                return const Text(
                  "No data available", 
                  style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),);
              }
            }),
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
                SensorGraph(title: widget.title, sensorData: sensorData),
                const SizedBox(width: 100),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Current: ${sensorData.isEmpty ? "None" : sensorData.last.y}\nAverage: ${calculateAverage(sensorData)}',
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 80),
                    if (widget.interactive)
                      Column(
                        children: [
                          Transform.scale(
                            scale: 2,
                            alignment: Alignment.center,
                            child: Switch(
                              value: switchState,
                              activeColor: widget.color,
                              splashRadius: 20,
                              onChanged: (bool value) {
                                setState(() {
                                  switchState = value;
                                });
                              },
                            ),
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
  for (GraphData entry in nums) {
    sum += entry.y;
  }
  return sum / nums.length;
}
