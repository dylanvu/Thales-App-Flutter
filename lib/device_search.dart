/* Page to show while looking for device */

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key, required this.icon, required this.color, required this.title}) : super(key: key);

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
              padding: EdgeInsets.all(10),
              child: Text(
                widget.title,
                style: TextStyle(
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
                SfCartesianChart(
                  plotAreaBorderColor: Colors.white,
                  plotAreaBorderWidth: 5,
                  
                  primaryXAxis: CategoryAxis(
                    axisLine: AxisLine(color: Colors.white, width: 3),
                    majorGridLines: MajorGridLines(color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  primaryYAxis: NumericAxis(
                    axisLine: AxisLine(color: Colors.white, width: 3),
                    majorGridLines: MajorGridLines(color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  title: ChartTitle(text: 'Heart Rate Data', textStyle: TextStyle(fontSize: 20, color: Colors.white)),
                  series: <LineSeries<HeartRateData, String>>[
                    LineSeries<HeartRateData, String>(
                    // Bind data source
                      dataSource:  <HeartRateData>[
                        HeartRateData('0 min', 62),
                        HeartRateData('5 min', 65),
                        HeartRateData('10 min', 67),
                        HeartRateData('15 min', 66),
                        HeartRateData('20 min', 68)
                      ],
                      xValueMapper: (HeartRateData person, _) => person.time,
                      yValueMapper: (HeartRateData person, _) => person.rate,
                      dataLabelSettings: DataLabelSettings(isVisible: true, textStyle: TextStyle(fontSize: 15, color: Colors.white)),
                    )
                  ]
                ),
                const SizedBox(width: 300),
                Icon(
                  widget.icon,
                  size: 250,
                  color: widget.color,
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}

class HeartRateData{
    HeartRateData(this.time, this.rate);
    final String time;
    final double rate;
}
