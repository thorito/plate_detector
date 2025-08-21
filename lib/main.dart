import 'package:flutter/material.dart';
import 'package:plate_scanner/camera_view.dart';

void main() => runApp(PlateScannerApp());

class PlateScannerApp extends StatelessWidget {
  const PlateScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plate Scanner',
      theme: ThemeData.dark(),
      home: CameraView(),
    );
  }
}
