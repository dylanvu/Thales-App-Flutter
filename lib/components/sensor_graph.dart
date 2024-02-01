import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorGraph extends StatefulWidget {
  SensorGraph({super.key, required this.title, required this.sensorData});
  final String title;

  List<GraphData> sensorData;

  @override
  State<SensorGraph> createState() => _SensorGraphState();
}

class _SensorGraphState extends State<SensorGraph> {
  // TODO: need to call a function that we pass in, that defines how the data is collected, and use that to update the sensor data state

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderColor: Colors.white,
      plotAreaBorderWidth: 5,
      primaryXAxis: CategoryAxis(
        minimum: 0,
        maximum: 50,
        axisLine: const AxisLine(color: Colors.white, width: 3),
        majorGridLines: const MajorGridLines(color: Colors.white),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      primaryYAxis: NumericAxis(
        // TODO: make this more variable
        minimum: 0,
        maximum: 200,
        axisLine: const AxisLine(color: Colors.white, width: 3),
        majorGridLines: const MajorGridLines(color: Colors.white),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      title: ChartTitle(
          text: widget.title,
          textStyle: const TextStyle(fontSize: 20, color: Colors.white)),
      series: <LineSeries<GraphData, String>>[
        LineSeries<GraphData, String>(
          // Bind data source
          dataSource: widget.sensorData,
          xValueMapper: (GraphData entry, _) => entry.x,
          yValueMapper: (GraphData entry, _) => entry.y,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 15, color: Colors.white)),
        )
      ],
    );
  }
}

class GraphData {
  GraphData(this.x, this.y);
  final String x;
  final double y;
}
