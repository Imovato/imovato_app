import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final version = Platform.environment['SCREENSHOT_VERSION'] ?? 'working-tree';
  final outputDirectory = Directory('artifacts/screenshots/$version');
  await outputDirectory.create(recursive: true);

  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('${outputDirectory.path}/$name.png');
      await file.writeAsBytes(bytes, flush: true);
      print('Saved screenshot: ${file.path}');
      return true;
    },
  );
}
