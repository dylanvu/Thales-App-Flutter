import 'package:ecg_app/data_page.dart';
import 'package:flutter/material.dart';

class CustomIconWithButton extends StatelessWidget {
  CustomIconWithButton(
      {super.key, required this.icon, required this.color, required this.text});

  IconData icon;
  Color color;
  String text;

  @override
  Widget build(BuildContext context) {
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
            print('Going to ${text} page!');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DataPage(icon: icon, color: color, title: text),
              ),
            );
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
