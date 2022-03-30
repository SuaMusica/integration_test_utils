// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class IntegrationTestUtils {
  int randomNumber([int max = 10]) => Random().nextInt(max);
  List<int> randomNumbers(int length, [int max = 10]) => [
        for (int i = 0; i < length; i++) randomNumber(max),
      ];
  static Future<void> wait([int ms = 800]) async {
    _log('waiting for ${ms}ms');
    await Future.delayed(Duration(milliseconds: ms));
  }

  static Finder getSliderWithValue({required Key key, required double value}) {
    return find.byWidgetPredicate(
      (Widget widget) =>
          widget is Slider && widget.key == key && widget.value >= value,
    );
  }

  static void mockFilePicker({required String assetNameWithExtension}) {
    MethodChannel(
      'miguelruivo.flutter.plugins.filepicker',
      Platform.isLinux || Platform.isWindows || Platform.isMacOS
          ? const JSONMethodCodec()
          : const StandardMethodCodec(),
    ).setMockMethodCallHandler(
      (MethodCall methodCall) async {
        if (methodCall.method == 'custom') {
          final byteData =
              await rootBundle.load('assets/$assetNameWithExtension');
          final buffer = byteData.buffer;
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;
          var filePath = tempPath + '/$assetNameWithExtension';
          final tFile = File(filePath).writeAsBytes(buffer.asUint8List(
              byteData.offsetInBytes, byteData.lengthInBytes));

          final tFile1 = await tFile.then((value) => value);
          final size = await tFile1.length();
          final path = tFile1.path;

          final Map<String, dynamic> map = {
            'path': path,
            'size': size,
            'bytes': null,
            'name': assetNameWithExtension,
          };
          return [map];
        }
      },
    );
  }

  static void category(String log) => _log('Category: ${log.toUpperCase()}');

  static void expectWithLog(Finder find, Matcher matcher) {
    _log('Expecting ${find.description} with $matcher');
    expect(find, matcher);
  }

  static void _log(String log) => print('#TESTING ==> $log');
}
