/// معلومات إصدار التطبيق — تُحدَّث مع `version` في pubspec.yaml.
const String kAppVersion = '1.3.2';

/// رقم البناء — يطابق ما بعد `+` في pubspec.yaml (يُتحقق منه في الاختبارات).
const String kBuildNumber = '8';

/// وضع الإطلاق: كل المزايا مجانية ولا دفع داخل التطبيق (الباقات تظهر
/// «قريبًا»). يُعطَّل بسطر واحد عند تفعيل الدفع الحقيقي (RevenueCat).
const bool kLaunchMode = true;

/// روابط عامة تشترطها المتاجر (سياسة الخصوصية والدعم وحذف الحساب).
abstract final class AppLinks {
  static const String privacy = 'https://daood40.github.io/waqti/privacy.html';
  static const String support = 'https://daood40.github.io/waqti/support.html';
  static const String deleteAccount =
      'https://daood40.github.io/waqti/delete-account.html';

  /// مفتاح الإيقاف عن بُعد (JSON ثابت على Pages).
  static const String remoteConfig =
      'https://daood40.github.io/waqti/app-config.json';
  static const String playStore =
      'https://play.google.com/store/apps/details?id=com.waqti.waqti';
}
