import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PlateDetector {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/plate_detector.tflite',
    );

    debugPrint('Interpreter type: ${_interpreter.getInputTensor(0).type}');
  }

  Future<List<Uint8List>> detectPlates(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      return [];
    }

    final input = _preprocess(image);

    final outputTensorShape = _interpreter.getOutputTensor(0).shape;

    final output = List.generate(
      outputTensorShape[0],
      (_) => List.generate(
        outputTensorShape[1],
        (_) => List.filled(outputTensorShape[2], 0.0),
      ),
    );

    _interpreter.run(input, output);

    final detections = output[0];

    final boxes = _postprocess(detections, image.width, image.height);
    final crops = boxes.map((box) => _crop(image, box)).toList();
    return crops;
  }

  List<List<List<List<double>>>> _preprocess(img.Image image) {
    final resized = img.copyResize(image, width: 320, height: 320);
    final input = List.generate(
      1, // Batch size
      (_) => List.generate(
        320, // Height
        (_) => List.generate(320, (_) => List.filled(3, 0.0)),
      ),
    );
    for (int y = 0; y < 320; y++) {
      for (int x = 0; x < 320; x++) {
        final pixel = resized.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }
    return input;
  }

  List<Rect> _postprocess(
    List<List<double>> outputDetections,
    int originalWidth,
    int originalHeight,
  ) {
    final boxes = <Rect>[];
    for (final pred in outputDetections) {
      final confidence = pred[4];

      if (confidence > 0.5) {
        final cx = pred[0] * originalWidth;
        final cy = pred[1] * originalHeight;
        final w = pred[2] * originalWidth;
        final h = pred[3] * originalHeight;

        final x = cx - w / 2;
        final y = cy - h / 2;

        boxes.add(Rect.fromLTWH(x, y, w, h));
      }
    }
    return boxes;
  }

  Uint8List _crop(img.Image image, Rect box) {
    final cropped = img.copyCrop(
      image,
      x: box.left.toInt(),
      y: box.top.toInt(),
      width: box.width.toInt(),
      height: box.height.toInt(),
    );
    return Uint8List.fromList(img.encodeJpg(cropped));
  }
}

class Rect {
  final double left, top, width, height;
  Rect.fromLTWH(this.left, this.top, this.width, this.height);
}
