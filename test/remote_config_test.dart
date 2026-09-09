import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqti/core/remote_config.dart';
import 'package:waqti/main.dart';
import 'package:waqti/screens/blocked_screen.dart';
import 'package:waqti/state/app_state.dart';

class _Src implements RemoteConfigSource {
  _Src(this.cfg);
  final RemoteConfig? cfg;
  @override
  Future<RemoteConfig?> load() async => cfg;
}

void main() {
  group('RemoteConfig', () {
    test('parses and compares versions', () {
      final c = RemoteConfig.tryParse(
        '{"minSupportedVersion":"1.4.0","message":{"ar":"م","en":"e"}}',
      )!;
      expect(c.requiresUpdate('1.3.1'), isTrue);
      expect(c.requiresUpdate('1.4.0'), isFalse);
      expect(c.requiresUpdate('2.0'), isFalse);
      expect(c.message('ar'), 'م');
      expect(RemoteConfig.compareVersions('1.10.0', '1.9.9'), 1);
    });

    test('malformed or wrong-typed JSON never blocks', () {
      for (final raw in ['{', '[]', '"x"', '{"minSupportedVersion": 5}']) {
        final c = RemoteConfig.tryParse(raw);
        expect(c?.blocks ?? false, isFalse, reason: raw);
      }
    });

    test('fetch failure keeps the app open (fail-open)', () async {
      SharedPreferences.setMockInitialValues({});
      final state = await AppState.load();
      await state.checkRemoteConfig(_Src(null));
      expect(state.blockedByRemote, isFalse);
    });
  });

  testWidgets('maintenance flag shows the blocked screen, retry clears it', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    state.setOnboarded();
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();
    expect(find.byType(BlockedScreen), findsNothing);

    await state.checkRemoteConfig(_Src(const RemoteConfig(maintenance: true)));
    await tester.pumpAndSettle();
    expect(find.byType(BlockedScreen), findsOneWidget);

    await state.checkRemoteConfig(_Src(RemoteConfig.none));
    await tester.pumpAndSettle();
    expect(find.byType(BlockedScreen), findsNothing);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
