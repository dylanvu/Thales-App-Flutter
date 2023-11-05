/* Page to show while looking for device */

import 'package:ecg_app/components/sensor_graph.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DataPage extends StatefulWidget {
  const DataPage(
      {Key? key, required this.icon, required this.color, required this.title})
      : super(key: key);

  final String title;
  final Color color;
  final IconData icon;

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
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
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SensorGraph(title: widget.title),
                const SizedBox(width: 100),
                const Text(
                  '''
                    Current:
                    Average:
                  ''',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  widget.icon,
                  size: 150,
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
