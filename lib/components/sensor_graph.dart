import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorGraph extends StatefulWidget {
  SensorGraph({super.key, required this.title, required this.sensorData, required this.color, required this.dataKey});
  
  final String title;
  List<GraphData> sensorData;
  final Color color;
  final String dataKey;

  @override
  State<SensorGraph> createState() => _SensorGraphState();
}

class _SensorGraphState extends State<SensorGraph> {
  // TODO: need to call a function that we pass in, that defines how the data is collected, and use that to update the sensor data state

  @override
  Widget build(BuildContext context) {
    double dataRange = 200;
    String axisName = "";

    if (widget.dataKey == "heart_rate"){
      dataRange = 150;
      axisName = "Beats per Second";
    }
    else if (widget.dataKey == "stress"){
      dataRange = 5;
      axisName = "Level";
    }
    else if (widget.dataKey == "temperature"){
      dataRange = 50;
      axisName = "Celsius";
    }

    return SfCartesianChart(
      plotAreaBorderColor: Colors.white,
      plotAreaBorderWidth: 5,
      primaryXAxis: CategoryAxis(
        isVisible: false, // hiding the x axis of the graph
        minimum: 0,
        maximum: 50,
        axisLine: const AxisLine(color: Colors.white, width: 3),
        majorGridLines: const MajorGridLines(color: Colors.white),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      primaryYAxis: NumericAxis(
        // TODO: make this more variable
        title: AxisTitle(text: axisName, textStyle: TextStyle(color: Colors.white)),
        minimum: 0,
        maximum: dataRange,
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
          color: widget.color,
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
