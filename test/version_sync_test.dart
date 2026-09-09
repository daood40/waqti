import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:waqti/core/app_info.dart';

/// رقم الإصدار والبناء في الشيفرة يطابقان pubspec.yaml (Sentry release/dist).
void main() {
  test('kAppVersion/kBuildNumber match pubspec version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final m = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)',
      multiLine: true,
    ).firstMatch(pubspec)!;
    expect(kAppVersion, m.group(1));
    expect(kBuildNumber, m.group(2));
  });
}
