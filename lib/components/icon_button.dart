import 'package:flutter/material.dart';

class IconButton extends StatelessWidget {
  IconButton(
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
          size: 100,
          color: color,
        ),
        ElevatedButton(onPressed: () {}, child: Text(text)),
      ],
    );
  }
}
