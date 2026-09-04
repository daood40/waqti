import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_config.dart';
import 'core/app_info.dart';
import 'core/auth/auth_gateway.dart';
import 'core/auth/supabase_auth_gateway.dart';
import 'core/cloud_backup_service.dart';
import 'core/notification_service.dart';
import 'core/theme.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/shell_screen.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // الخدمات الخارجية اختيارية: بلا إعدادات يعمل التطبيق محليًا كزائر.
  AuthGateway authGateway = const NoAuthGateway();
  CloudBackupGateway cloudGateway = const NoCloudBackupGateway();
  if (AppConfig.hasSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    authGateway = SupabaseAuthGateway(Supabase.instance.client);
    cloudGateway = SupabaseCloudBackupGateway(Supabase.instance.client);
  }

  final appState = await AppState.load();
  appState.attachServices(authGateway: authGateway, cloudGateway: cloudGateway);
  // التذكيرات المحلية: تهيئة ثم مزامنة الجدول مع كل تغيير في الحالة.
  await NotificationService.instance.init();
  NotificationService.instance.bind(appState);

  if (AppConfig.hasSentry) {
    // تتبع الأعطال فقط: لا بيانات شخصية، لا نصوص المستخدم.
    await SentryFlutter.init((options) {
      options.dsn = AppConfig.sentryDsn;
      options.environment = AppConfig.environment;
      options.release = 'waqti@$kAppVersion';
      options.sendDefaultPii = false;
      options.tracesSampleRate = 0.1;
      options.attachScreenshot = false;
    }, appRunner: () => runApp(WaqtiApp(appState: appState)));
    return;
  }
  runApp(WaqtiApp(appState: appState));
}

/// تطبيق "وقتي" — تتبع المهام والعادات اليومية.
class WaqtiApp extends StatelessWidget {
  const WaqtiApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: Consumer<AppState>(
        builder: (context, state, _) => MaterialApp(
          title: 'وقتي',
          debugShowCheckedModeBanner: false,
          theme: WaqtiTheme.light(),
          darkTheme: WaqtiTheme.dark(),
          themeMode: state.themeMode,
          locale: Locale(state.lang),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: state.passwordRecoveryPending
              ? const ResetPasswordScreen()
              : !state.onboarded
              ? const OnboardingScreen()
              : state.loggedIn
              ? const ShellScreen()
              : const AuthScreen(),
        ),
      ),
    );
  }
}
