import 'package:flutter_test/flutter_test.dart';
import 'package:waqti/core/search.dart';

void main() {
  group('normalizeArabic', () {
    test('unifies alef, yaa, taa marbuta and strips diacritics', () {
      expect(normalizeArabic('أَحْمَد'), 'احمد');
      expect(normalizeArabic('إبراهيم'), 'ابراهيم');
      expect(normalizeArabic('مصطفى'), 'مصطفي');
      expect(normalizeArabic('قراءة'), 'قراءه');
      expect(normalizeArabic('صـــلاة'), 'صلاه');
    });
    test('lowercases latin and collapses spaces', () {
      expect(normalizeArabic('  Read   Book '), 'read book');
    });
  });

  group('matchesAllTerms', () {
    test('every term must match some field (AND)', () {
      final terms = queryTerms('قرآن صباح');
      expect(matchesAllTerms(terms, ['قراءة القرآن', 'كل صباح']), isTrue);
      expect(matchesAllTerms(terms, ['قراءة القرآن', '']), isFalse);
    });
    test('query with hamza matches stored text without it', () {
      expect(matchesAllTerms(queryTerms('أذكار'), ['اذكار المساء']), isTrue);
    });
    test('empty query matches everything', () {
      expect(matchesAllTerms(queryTerms('   '), ['x']), isTrue);
    });
  });
}
