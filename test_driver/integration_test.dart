import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot:
        (String name, List<int> bytes, [Map<String, Object?>? args]) async {
          final archivo = File('docs/evidencias/practica-06/$name.png');
          await archivo.create(recursive: true);
          await archivo.writeAsBytes(bytes);
          return true;
        },
  );
}
