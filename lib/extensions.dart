import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension StringExt on String {
  Finder toKey() => find.byKey(Key(this));
}

extension SlideTo on WidgetTester {
  Future<void> slideToValue(Finder slider, double value,
      {double paddingOffset = 24.0}) async {
    final zeroPoint =
        getTopLeft(slider) + Offset(paddingOffset, getSize(slider).height / 2);
    final totalWidth = getSize(slider).width - (2 * paddingOffset);
    final calculatdOffset = value * (totalWidth / 100);
    await dragFrom(zeroPoint, Offset(calculatdOffset, 0));
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
    Duration timeout = const Duration(seconds: 15),
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

// ignore: avoid_print
void _log(String log) => print('#TESTING ==> $log');
