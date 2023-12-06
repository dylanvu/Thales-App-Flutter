// /* Page for debugging serial port stuff */

// import 'package:flutter/material.dart';
// import 'package:thales_wellness/components/usb_handler.dart';
// import 'package:thales_wellness/usb_debugger/usb_debug_monitor.dart';

// class SerialDebugPage extends StatefulWidget {
//   final String title;

//   const SerialDebugPage({
//     Key? key,
//     required this.title,
//   }) : super(key: key);

//   @override
//   State<SerialDebugPage> createState() => _SerialDebugPageState();
// }

// class _SerialDebugPageState extends State<SerialDebugPage> {
//   USBPortAndDevice? _usbPort;

//   // get the ports
//   var availablePorts = [];

//   @override
//   void initState() {
//     super.initState();
//   }

//   void setUsbPort(USBPortAndDevice port) {
//     setState(() {
//       _usbPort = port;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       appBar: AppBar(
//         toolbarHeight: 80,
//         title: Text(
//           widget.title,
//           style: const TextStyle(fontSize: 30),
//         ),
//         actions: [
//           Padding(
//               padding: const EdgeInsets.only(right: 50),
//               child: SizedBox(
//                   width: 350,
//                   height: 350,
//                   child: Image.asset('images/thales_logo_no_background.png')))
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text("Welcome to the Serial Debug Page"),
//             _usbPort == null
//                 ? const Text("No serial port is selected.")
//                 : Text("The port selected is: ${_usbPort!.device.deviceName}"),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         USBDebugMonitorPage(title: "USB Debug Monitor Page"),
//                   ),
//                 );
//               },
//               child: const Text("USB Monitor"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
