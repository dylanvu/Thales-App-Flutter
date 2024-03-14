import 'package:flutter/material.dart';

class MedicalDisclaimer extends StatelessWidget {
  const MedicalDisclaimer({Key? key}) : super(key: key);

  // variables for the disclaimer text
  final double disclaimerFontSize = 10;
  final Color disclaimerColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return (Column(
      children: [
        Text(
          "This data is for informational purposes only.",
          style: TextStyle(
            fontSize: disclaimerFontSize,
            color: disclaimerColor,
          ),
        ),
        Text(
          "It is not intended for medical diagnosis or treatment.",
          style: TextStyle(
            fontSize: disclaimerFontSize,
            color: disclaimerColor,
          ),
        ),
        Text(
          "Consult a healthcare professional for personalized advice.",
          style: TextStyle(
            fontSize: disclaimerFontSize,
            color: disclaimerColor,
          ),
        ),
      ],
    ));
  }
}
