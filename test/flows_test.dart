import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqti/main.dart';
import 'package:waqti/models/models.dart';
import 'package:waqti/state/app_state.dart';

/// رحلات مستخدم كاملة على الواجهة الحقيقية (لا Mock).
Future<AppState> _loggedInState() async {
  SharedPreferences.setMockInitialValues({});
  final state = await AppState.load();
  state.setOnboarded();
  state.signInAsGuest('زائر');
  state.addTask(TaskItem(id: 't1', name: 'قراءة', icon: '📚'));
  return state;
}

void main() {
  testWidgets('home: tapping a today chip completes the task (1 / 1)', (
    tester,
  ) async {
    final state = await _loggedInState();
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();

    expect(find.text('0 / 1'), findsOneWidget);
    await tester.tap(find.text('قراءة').first);
    await tester.pumpAndSettle();
    expect(find.text('1 / 1'), findsOneWidget);
    expect(state.tasks.first.statusOn(DateTime.now()), TaskStatus.done);
  });

  testWidgets('calendar: tapping a day opens the day sheet with its tasks', (
    tester,
  ) async {
    final state = await _loggedInState();
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pumpAndSettle();
    final today = DateTime.now().day;
    await tester.tap(find.text('$today').first);
    await tester.pumpAndSettle();

    expect(find.text('لا مهام في هذا اليوم'), findsNothing);
    expect(find.text('قراءة'), findsOneWidget);
    expect(find.text('إغلاق'), findsOneWidget);
  });

  testWidgets('settings: language switch re-renders the shell in English', (
    tester,
  ) async {
    final state = await _loggedInState();
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(state.lang, 'en');
  });
}
