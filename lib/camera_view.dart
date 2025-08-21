import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plate_scanner/ocr_service.dart';
import 'package:plate_scanner/plate_detector.dart';
import 'package:plate_scanner/result_list.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  List<String> plates = [];

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    await Permission.camera.request();
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.low);
    await _controller!.initialize();
    setState(() {});
    startDetectionLoop();
  }

  void startDetectionLoop() async {
    final detector = PlateDetector();
    await detector.loadModel();
    final ocr = OCRService();

    while (mounted) {
      await Future.delayed(Duration(seconds: 1));
      if (!_controller!.value.isInitialized) continue;

      try {
        final image = await _controller!.takePicture();
        final bytes = await image.readAsBytes();

        final regions = await detector.detectPlates(bytes);
        for (final region in regions) {
          final text = await ocr.extractText(region);
          debugPrint('Texto extraído por OCR: "$text"');
          if (isValidPlate(text) && !plates.contains(text)) {
            setState(() => plates.add(text));
          }
        }
      } catch (e) {
        debugPrint('Error en el bucle de detección: $e');
      }
    }
  }

  bool isValidPlate(String text) {
    final regex = RegExp(r'^\d{4}[A-Z]{3}$'); // Ej: 1234ABC
    return regex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ResultList(plates: plates),
          ),
        ],
      ),
    );
  }
}
