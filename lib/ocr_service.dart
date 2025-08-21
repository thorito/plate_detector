import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class OCRService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/plate.jpg');
    await file.writeAsBytes(imageBytes);

    final inputImage = InputImage.fromFilePath(file.path);
    final result = await _recognizer.processImage(inputImage);
    return result.text.replaceAll(' ', '').toUpperCase();
  }
}
