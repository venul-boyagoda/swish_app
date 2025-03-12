import 'dart:io';

import 'package:flutter/material.dart';
import 'package:swish_app/calibration.dart';
import 'package:swish_app/confirmation.dart';
import 'package:swish_app/general_summary.dart';
import 'package:swish_app/home_screen.dart';
import 'package:swish_app/individual_summary.dart';
import 'package:swish_app/session_complete.dart';
import 'package:swish_app/training_in_progress.dart';
import 'vision_detector_views/pose_detector_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrainingInProgress(),
    );
  }
}

// class Home extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google ML Kit Demo App'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 children: [
//                   ExpansionTile(
//                     title: const Text('Vision APIs'),
//                     children: [
//                       CustomCard('Pose Detection', PoseDetectorView()),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

