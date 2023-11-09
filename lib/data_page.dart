/* Page to show while looking for device */

import 'package:ecg_app/components/sensor_graph.dart';
import 'package:flutter/material.dart';

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
  List<GraphData> sensorData = [
    GraphData('${0} min', 62),
    GraphData('${5} min', 65),
    GraphData('${10} min', 67),
    GraphData('${15} min', 66),
    GraphData('${20} min', 68),
  ];

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
        actions: [Padding(padding: EdgeInsets.only(right: 50), child: SizedBox(width: 350, height: 350, child: Image.asset('images/thales_logo_no_background.png')))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                      'Current: ${sensorData.last.y}\nAverage: ${calculateAverage(sensorData)}',
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 80),
                    if (widget.interactive)
                      Column(
                        children: [
                          Transform.scale(scale: 2, alignment: Alignment.center,
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
