/// رموز التصميم (Design Tokens) — مقياس مسافات 4pt، أنصاف أقطار،
/// وسلم أحجام النص. القيم مشتقة من النموذج البصري المعتمد؛
/// كل قيمة جديدة في الواجهة تأتي من هنا لا كرقم خام.
library;

/// مقياس المسافات — مضاعفات 4.
abstract final class WqSpace {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
}

/// أنصاف الأقطار المعتمدة (من النموذج: 18 للبطاقات، 12 للعناصر).
abstract final class WqRadius {
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 18;
  static const double pill = 999;
}

/// سلم أحجام النص المسمّى — بدل أرقام متناثرة.
abstract final class WqType {
  static const double display = 24; // الساعة، الأرقام البارزة
  static const double headline = 20; // تحية اليوم
  static const double title = 17; // عناوين الأقسام
  static const double body = 14; // المحتوى الأساسي
  static const double label = 12.5; // تسميات الحقول والتلميحات
  static const double caption = 11; // شروح صغيرة
}

/// أدنى بعد لهدف لمس مريح (إرشادات الإتاحة).
abstract final class WqHit {
  static const double min = 40;
}
