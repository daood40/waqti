/// بحث محلي بتطبيع عربي (flutter-search-filter): توحيد الألف/الياء/التاء
/// المربوطة، حذف التشكيل والتطويل، ثم مطابقة كل كلمات الاستعلام (AND).
library;

final _diacritics = RegExp('[ً-ْٰـ]');
final _alefs = RegExp('[آأإٱ]');
final _spaces = RegExp(r'\s+');

/// يعيد النص بصيغة موحّدة للمقارنة (لا للعرض).
String normalizeArabic(String input) {
  return input
      .toLowerCase()
      .replaceAll(_diacritics, '')
      .replaceAll(_alefs, 'ا') // أ إ آ ٱ → ا
      .replaceAll('ى', 'ي') // ى → ي
      .replaceAll('ة', 'ه') // ة → ه
      .replaceAll('ی', 'ي') // ی الفارسية → ي
      .replaceAll('ک', 'ك') // ک الفارسية → ك
      .replaceAll(_spaces, ' ')
      .trim();
}

/// يقسم الاستعلام إلى كلمات مطبَّعة؛ فارغ يعني «لا بحث».
List<String> queryTerms(String query) =>
    normalizeArabic(query).split(' ').where((t) => t.isNotEmpty).toList();

/// كل كلمة من [terms] يجب أن تظهر في أحد [fields] (بعد التطبيع).
bool matchesAllTerms(List<String> terms, Iterable<String> fields) {
  if (terms.isEmpty) return true;
  final haystack = fields.map(normalizeArabic).join(' ');
  return terms.every(haystack.contains);
}
