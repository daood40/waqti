import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqti/core/l10n.dart';
import 'package:waqti/main.dart';
import 'package:waqti/state/app_state.dart';
import 'package:waqti/widgets/task_editor_sheet.dart';

/// حارس التعديلات غير المحفوظة في محرر المهمة (flutter-navigation).
Future<AppState> _state() async {
  SharedPreferences.setMockInitialValues({});
  final state = await AppState.load();
  state.setOnboarded();
  state.signInAsGuest('زائر');
  return state;
}

void main() {
  testWidgets('back with unsaved edits asks before closing', (tester) async {
    final state = await _state();
    final s = AppStrings.of('ar');
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorSheet), findsOneWidget);

    final nameField = find
        .descendant(
          of: find.byType(TaskEditorSheet),
          matching: find.byType(TextField),
        )
        .first;
    await tester.enterText(nameField, 'قراءة');
    await tester.pump();

    // زر رجوع النظام يمر عبر maybePop فيستشير الحارس.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorSheet), findsOneWidget, reason: 'guard');
    expect(find.text(s.discardChangesTitle), findsOneWidget);

    await tester.tap(find.text(s.keepEditing));
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorSheet), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.discard));
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorSheet), findsNothing);
    expect(state.tasks, isEmpty);
  });

  testWidgets('back without edits closes immediately', (tester) async {
    final state = await _state();
    final s = AppStrings.of('ar');
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(s.discardChangesTitle), findsNothing);
    expect(find.byType(TaskEditorSheet), findsNothing);
  });
}
