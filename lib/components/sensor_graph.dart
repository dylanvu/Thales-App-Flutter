import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorGraph extends StatefulWidget {
  const SensorGraph({super.key, required this.title});
  final String title;

  @override
  State<SensorGraph> createState() => _SensorGraphState();
}

class _SensorGraphState extends State<SensorGraph> {
  List<GraphData> sensorData = [
    GraphData('${0} min', 62),
    GraphData('${5} min', 65),
    GraphData('${10} min', 67),
    GraphData('${15} min', 66),
    GraphData('${20} min', 68),
  ];

  // TODO: need to call a function that we pass in, that defines how the data is collected, and use that to update the sensor data state

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderColor: Colors.white,
      plotAreaBorderWidth: 5,
      primaryXAxis: CategoryAxis(
        axisLine: const AxisLine(color: Colors.white, width: 3),
        majorGridLines: const MajorGridLines(color: Colors.white),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      primaryYAxis: NumericAxis(
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
          dataSource: sensorData,
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
