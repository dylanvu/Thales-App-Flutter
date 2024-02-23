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
    required this.rememberInteractiveState,
    required this.interactiveStates,
  });

  IconData icon;
  Color color;
  String text;
  bool interactive;
  // dataKey is the key to access the incoming data in the JSON format
  String dataKey;
  Function rememberInteractiveState;
  Map<String, bool> interactiveStates;

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
            interactiveStates: interactiveStates,
            rememberInteractiveState: rememberInteractiveState,
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(icon),
          iconSize: 200,
          color: color,
          onPressed: () {
            navigateToDataPage();
          },
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
