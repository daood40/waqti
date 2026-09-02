import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqti/main.dart';
import 'package:waqti/state/app_state.dart';

void main() {
  testWidgets(
    'shows onboarding, then auth, then home shell after guest login',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = await AppState.load();
      await tester.pumpWidget(WaqtiApp(appState: state));
      await tester.pumpAndSettle();

      // الجولة التعريفية تظهر أولًا عند أول تشغيل، ويمكن تخطّيها.
      expect(find.text('مهامك وعاداتك في مكان واحد'), findsOneWidget);
      await tester.tap(find.text('تخطٍّ'));
      await tester.pumpAndSettle();

      // ثم شاشة الدخول.
      expect(find.text('مرحبًا بعودتك'), findsOneWidget);

      // المتابعة كزائر تنقل للرئيسية.
      await tester.ensureVisible(find.text('المتابعة كزائر'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('المتابعة كزائر'));
      await tester.pumpAndSettle();
      expect(find.text('الجدول الشهري'), findsOneWidget);
    },
  );
}
