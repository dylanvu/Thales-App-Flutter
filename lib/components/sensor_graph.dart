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
      series: <LineSeries<HeartRateData, String>>[
        LineSeries<HeartRateData, String>(
          // Bind data source
          dataSource: <HeartRateData>[
            HeartRateData('0 min', 62),
            HeartRateData('5 min', 65),
            HeartRateData('10 min', 67),
            HeartRateData('15 min', 66),
            HeartRateData('20 min', 68)
          ],
          xValueMapper: (HeartRateData person, _) => person.time,
          yValueMapper: (HeartRateData person, _) => person.rate,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 15, color: Colors.white)),
        )
      ],
    );
  }
}

class HeartRateData {
  HeartRateData(this.time, this.rate);
  final String time;
  final double rate;
}
