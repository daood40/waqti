import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqti/main.dart';
import 'package:waqti/state/app_state.dart';

void main() {
  testWidgets(
    'shows onboarding, then the home shell as guest when no auth server',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = await AppState.load();
      await tester.pumpWidget(WaqtiApp(appState: state));
      await tester.pumpAndSettle();

      // الجولة التعريفية تظهر أولًا عند أول تشغيل، ويمكن تخطّيها.
      expect(find.text('مهامك وعاداتك في مكان واحد'), findsOneWidget);
      await tester.tap(find.text('تخطٍّ'));
      await tester.pumpAndSettle();

      // بلا خادم حسابات لا تظهر شاشة دخول: الرئيسية مباشرة كزائر.
      expect(find.text('المتابعة كزائر'), findsNothing);
      expect(find.text('الجدول الشهري'), findsOneWidget);
      expect(state.loggedIn, isTrue);
      expect(state.hasAccount, isFalse);
    },
  );
}
