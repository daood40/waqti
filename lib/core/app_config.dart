/// إعدادات التشغيل تُمرَّر عند البناء عبر `--dart-define` (أو من GitHub Secrets في CI).
/// غيابها لا يكسر التطبيق: يعمل في وضع محلي (زائر) بلا خادم ولا تتبع.
///
/// مثال:
/// flutter build web --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=sb_publishable_... --dart-define=SENTRY_DSN=https://...
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );
  static const environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  /// مخطط الرابط العميق لعودة المصادقة على الهاتف (مسجَّل في Android/iOS).
  static const authRedirectScheme = 'waqti';
  static const authRedirectUrl = 'waqti://login-callback/';

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasSentry => sentryDsn.isNotEmpty;
  static bool get hasGoogle => googleWebClientId.isNotEmpty;
}
