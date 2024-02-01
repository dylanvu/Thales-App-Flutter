import 'package:thales_wellness/data_page.dart';
import 'package:flutter/material.dart';

class CustomIconWithButton extends StatelessWidget {
  CustomIconWithButton({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
    required this.dataKey,
    this.interactive = false,
  });

  IconData icon;
  Color color;
  String text;
  bool interactive;
  // dataKey is the key to access the incoming data in the JSON format
  String dataKey;

  @override
  Widget build(BuildContext context) {
    void navigateToDataPage() {
      print('Going to $text page!');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DataPage(
            icon: icon,
            color: color,
            title: text,
            interactive: interactive,
            dataKey: dataKey,
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 200,
          color: color,
        ),
        const SizedBox(
          height: 30,
        ),
        ElevatedButton(
          onPressed: () {
            navigateToDataPage();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
          ),
          child: Text(text, style: const TextStyle(fontSize: 25)),
        ),
      ],
    );
  }
}
