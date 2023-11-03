import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorGraph extends StatefulWidget {
  const SensorGraph({super.key, required this.title});
  final String title;

  @override
  State<SensorGraph> createState() => _SensorGraphState();
}

class _SensorGraphState extends State<SensorGraph> {
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
          dataSource: <GraphData>[
            GraphData('${0} min', 62),
            GraphData('${5} min', 65),
            GraphData('${10} min', 67),
            GraphData('${15} min', 66),
            GraphData('${20} min', 68)
          ],
          xValueMapper: (GraphData person, _) => person.x,
          yValueMapper: (GraphData person, _) => person.y,
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
