import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqti/core/l10n.dart';
import 'package:waqti/main.dart';
import 'package:waqti/models/models.dart';
import 'package:waqti/screens/shell_screen.dart';
import 'package:waqti/state/app_state.dart';

/// فحوص الإتاحة وRTL على التطبيق الحقيقي (flutter-arabic-rtl / flutter-ui-design).
Future<AppState> _seededState() async {
  SharedPreferences.setMockInitialValues({});
  final state = await AppState.load();
  state.setOnboarded();
  state.signInAsGuest('زائر');
  state.addTask(TaskItem(id: 'a', name: 'قراءة', icon: '📖'));
  return state;
}

void main() {
  testWidgets('shell renders at 1.3× text scale without overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final state = await _seededState();
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ShellScreen), findsOneWidget);
  });

  testWidgets('text scale above 1.3× is clamped by the app builder', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final state = await _seededState();
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();
    final scaler = MediaQuery.textScalerOf(
      tester.element(find.byType(ShellScreen)),
    );
    expect(scaler.scale(10), closeTo(13, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shell is RTL in Arabic and LTR in English', (tester) async {
    final state = await _seededState();
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();
    final shell = find.byType(ShellScreen);
    expect(Directionality.of(tester.element(shell)), TextDirection.rtl);

    state.setLang('en');
    await tester.pumpAndSettle();
    expect(Directionality.of(tester.element(shell)), TextDirection.ltr);
  });

  testWidgets('task editor pickers expose semantics with ≥40px targets', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final state = await _seededState();
    final s = AppStrings.of('ar');
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    final custom = find.bySemanticsLabel(s.customColor);
    await tester.dragUntilVisible(
      custom,
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(custom, findsOneWidget);
    final size = tester.getSize(custom);
    expect(size.width, greaterThanOrEqualTo(40));
    expect(size.height, greaterThanOrEqualTo(40));
    handle.dispose();
  });
}
