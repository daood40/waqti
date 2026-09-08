import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqti/core/app_info.dart';
import 'package:waqti/core/l10n.dart';
import 'package:waqti/main.dart';
import 'package:waqti/screens/tabs/settings_tab.dart';
import 'package:waqti/state/app_state.dart';

/// شروط المتاجر داخل التطبيق: لا محتوى «قريبًا» في وضع الإطلاق،
/// وروابط الخصوصية/الدعم/التراخيص ظاهرة في الإعدادات.
void main() {
  testWidgets('settings has no paywall in launch mode and shows policy links', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    state.setOnboarded();
    state.signInAsGuest('زائر');
    final s = AppStrings.of('ar');
    await tester.pumpWidget(WaqtiApp(appState: state));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(kLaunchMode, isTrue);
    expect(find.textContaining(s.subscriptionSection), findsNothing);
    expect(find.text(s.comingSoon), findsNothing);

    final privacy = find.text(s.privacyPolicy);
    final list = find
        .descendant(
          of: find.byType(SettingsTab),
          matching: find.byType(Scrollable),
        )
        .first;
    // القائمة كسولة: نسحب حتى يُبنى قسم «حول التطبيق».
    for (var i = 0; i < 20 && privacy.evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    expect(privacy, findsOneWidget);
    expect(find.text(s.support), findsOneWidget);
    expect(find.text(s.openSourceLicenses), findsOneWidget);
    expect(AppLinks.privacy, startsWith('https://'));
  });
}
