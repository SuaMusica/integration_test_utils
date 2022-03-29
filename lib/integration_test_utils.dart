library integration_test_utils;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

class IntegrationTestUtils {
  int randomNumber([int max = 10]) => Random().nextInt(max);
  List<int> randomNumbers(int length, [int max = 10]) => [
        for (int i = 0; i < length; i++) randomNumber(max),
      ];
  Future<void> wait([int ms = 800]) async {
    _log('waiting for ${ms}ms');
    await Future.delayed(Duration(milliseconds: ms));
  }

  static void mockPickFile({required String assetNameWithExtension}) {
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
}

extension WidgetTesterExt on WidgetTester {
  Future<void> customTap(
    Finder finder, {
    Finder? waitFor,
    Finder? scrollable,
    Offset? scrollableOffset,
  }) async {
    _log('customTap ${finder.description}');

    if (scrollable != null) {
      _log('Scrolling to ${scrollable.description}');

      await dragUntilVisible(
        finder,
        scrollable,
        scrollableOffset ?? const Offset(0, -150.0),
      );
    }
    _log('Tapping ${finder.description}');

    await tap(finder);
    if (waitFor != null) {
      await pumpUntilFound(waitFor);
    }
  }

  Future<void> customTapAndSettle(Finder finder,
      [Duration duration = const Duration(milliseconds: 100)]) async {
    await customTap(finder);
    await pumpAndSettle(duration);
  }

  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    var timerDone = false;
    final timer = Timer(
      timeout,
      () => throw TimeoutException('Pump until has timed out'),
    );
    _log('Pumping until find -> ${finder.description}');

    while (!timerDone) {
      await pump();
      try {
        timerDone = any(finder);
      } catch (e) {
        timerDone = false;
      }
    }
    timer.cancel();
  }
}

extension StringExt on String {
  Finder toKey() => find.byKey(Key(this));
}

void category(String log) => _log('Category: ${log.toUpperCase()}');

void expectWithLog(Finder find, Matcher matcher) {
  _log('Expecting ${find.description} with $matcher');
  expect(find, matcher);
}

void _log(String log) => print('#TESTING ==> $log');
