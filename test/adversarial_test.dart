import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqti/core/auth/auth_gateway.dart';
import 'package:waqti/core/cloud_backup_service.dart';
import 'package:waqti/models/models.dart';
import 'package:waqti/state/app_state.dart';

/// جولة كسر عدائية (qa-engineer-mode) على طبقة الحالة والنماذج.
/// كل اختبار = محاولة كسر؛ النتائج موثّقة في qa/rounds/2026-09-09-state-layer.md.
Future<AppState> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final state = await AppState.load();
  state.setOnboarded();
  return state;
}

class _ThrowingAuth implements AuthGateway {
  @override
  bool get isAvailable => true;
  @override
  bool get supportsGoogle => false;
  @override
  bool get supportsApple => false;
  @override
  AuthUser? get currentUser =>
      const AuthUser(id: 'u1', email: 'a@b.c', name: 'x');
  @override
  Stream<AuthEvent> get events => const Stream.empty();
  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async => const SignUpResult(needsEmailConfirmation: true);
  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async => currentUser!;
  @override
  Future<AuthUser?> signInWithGoogle() async => null;
  @override
  Future<AuthUser?> signInWithApple() async => null;
  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<void> updateName(String name) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> deleteAccount() async => throw const AuthFailure('network');
}

class _NoCloud implements CloudBackupGateway {
  @override
  bool get isAvailable => false;
  @override
  Future<CloudSnapshot?> fetch() async => null;
  @override
  Future<DateTime> push(String payload, {required String appVersion}) async =>
      DateTime.now();
}

void main() {
  group('مدخلات', () {
    test('اسم مهمة فارغ أو مسافات لا يُقبل', () async {
      final s = await _fresh();
      expect(s.addTask(TaskItem(id: 'a', name: '   ')), isFalse);
      expect(s.addTask(TaskItem(id: 'b', name: '')), isFalse);
      expect(s.tasks, isEmpty);
    });

    test('اسم 5000 حرف يُقصّ إلى الحد المعلن (60) ولا يُرفض', () async {
      final s = await _fresh();
      final long = 'م' * 5000;
      expect(s.addTask(TaskItem(id: 'a', name: long)), isTrue);
      expect(s.tasks.first.name.length, lessThanOrEqualTo(60));
    });

    test('رموز خاصة تُحفظ كنص كما هي', () async {
      final s = await _fresh();
      const evil = '<script>alert(1)</script> \'"; {{x}}';
      expect(s.addTask(TaskItem(id: 'a', name: evil)), isTrue);
      expect(s.tasks.first.name, evil);
      s.setStatus('a', DateTime(2026, 9), TaskStatus.done);
      expect(s.exportCsv(), contains('"<script>'));
    });

    test('CSV: قيمة تبدأ بـ = أو + أو - أو @ لا تُصدَّر كصيغة', () async {
      final s = await _fresh();
      s.addTask(TaskItem(id: 'a', name: '=HYPERLINK("x")'));
      s.setStatus('a', DateTime(2026, 9), TaskStatus.done);
      final csv = s.exportCsv();
      expect(csv, isNot(contains('"=HYPERLINK')));
      expect(csv, contains("'=HYPERLINK"));
    });

    test('تصنيف باسم فارغ أو مكرر لا يُضاف مرتين', () async {
      final s = await _fresh();
      final before = s.categories.length;
      s.addCategory('   ', 0xFF000000);
      expect(s.categories.length, before);
      s.addCategory('صحة', 0xFF000000); // موجود افتراضيًا
      expect(s.categories.where((c) => c.name == 'صحة').length, 1);
    });

    test('نفس المعرّف مرتين لا يُضاف مرتين', () async {
      final s = await _fresh();
      expect(s.addTask(TaskItem(id: 'dup', name: 'أ')), isTrue);
      expect(s.addTask(TaskItem(id: 'dup', name: 'ب')), isFalse);
      expect(s.tasks.length, 1);
    });
  });

  group('حدود', () {
    test('هدف 0 أو سالب يُعامل كغير قابل للقياس', () {
      expect(TaskItem(id: 'a', name: 'x', target: 0).isMeasurable, isFalse);
      expect(TaskItem(id: 'a', name: 'x', target: -5).isMeasurable, isFalse);
      final t = TaskItem.fromJson({'id': 'a', 'name': 'x', 'target': -9});
      expect(t.target, greaterThanOrEqualTo(1));
    });

    test('التقدم لا يتجاوز الهدف ولا ينزل تحت الصفر', () async {
      final s = await _fresh();
      s.addTask(TaskItem(id: 'w', name: 'ماء', target: 8));
      final d = DateTime(2026, 9);
      for (var i = 0; i < 20; i++) {
        s.incrementProgress('w', d);
      }
      expect(s.taskById('w')!.progressOn(d), 8);
      s.incrementProgress('w', d, step: -100);
      expect(s.taskById('w')!.progressOn(d), greaterThanOrEqualTo(0));
    });

    test('أكثر من 3 تذكيرات في JSON تُقصّ إلى 3', () {
      final t = TaskItem.fromJson({
        'id': 'a',
        'name': 'x',
        'reminders': [1, 2, 3, 4, 5, 6],
      });
      expect(t.reminders.length, lessThanOrEqualTo(3));
    });

    test('فهارس خارج النطاق لا تُسقط التطبيق', () async {
      final s = await _fresh();
      s.addTask(TaskItem(id: 'a', name: 'أ'));
      s.reorderTask(5, 0);
      s.reorderTask(0, 99);
      s.restoreTask(TaskItem(id: 'r', name: 'ر'), 99);
      s.toggleSubtask('a', 7);
      s.toggleSubtask('missing', 0);
      s.cycleStatus('missing', DateTime.now());
      expect(s.tasks.length, 2);
    });

    test('ساعات الهدوء العابرة لمنتصف الليل والمتساوية', () async {
      final s = await _fresh();
      s.setQuietHours(on: true, start: 22 * 60, end: 6 * 60);
      expect(s.isQuietAt(3 * 60), isTrue);
      expect(s.isQuietAt(12 * 60), isFalse);
      s.setQuietHours(start: 8 * 60, end: 8 * 60);
      expect(s.isQuietAt(8 * 60), isFalse); // نطاق فارغ = لا هدوء
    });
  });

  group('تواريخ', () {
    test('29 فبراير في سنة كبيسة يوم صالح لعادة يومية', () {
      final t = TaskItem(id: 'a', name: 'x', createdAt: DateTime(2028));
      expect(t.isApplicableOn(DateTime(2028, 2, 29)), isTrue);
    });

    test('مفتاح اليوم ثابت عند 23:59 و00:00', () {
      expect(DateKey.fromDate(DateTime(2026, 9, 8, 23, 59)), '2026-09-08');
      expect(DateKey.fromDate(DateTime(2026, 9, 9)), '2026-09-09');
    });

    test('إحصاءات ديسمبر لا تتسرّب إلى يناير', () async {
      final s = await _fresh();
      s.addTask(TaskItem(id: 'a', name: 'x', createdAt: DateTime(2025)));
      s.setStatus('a', DateTime(2025, 12, 31), TaskStatus.done);
      expect(s.monthStats(2026, 1).done, 0);
      expect(s.monthStats(2025, 12).done, 1);
    });

    test('مهمة «مرة واحدة» بلا تاريخ لا تنطبق على أي يوم', () {
      final t = TaskItem(
        id: 'a',
        name: 'x',
        recurrence: const Recurrence(type: RecurrenceType.once),
      );
      expect(t.isApplicableOn(DateTime.now()), isFalse);
    });
  });

  group('استيراد/تصدير', () {
    test('JSON تالف أو غير كائن أو فارغ يُرفض بلا تغيير', () async {
      final s = await _fresh();
      s.addTask(TaskItem(id: 'a', name: 'أ'));
      for (final raw in ['{', '[]', '{}', 'null', '"x"', '{"tasks":"no"}']) {
        expect(s.importJson(raw), isFalse, reason: raw);
      }
      expect(s.tasks.length, 1);
    });

    test('مهمة بلا معرّف أو بحقول بأنواع خاطئة لا تُسقط الاستيراد', () async {
      final s = await _fresh();
      const raw =
          '{"tasks":[{"name":"بلا معرف"},{"id":"b","name":5,"target":"x","statuses":{"2026-09-01":"weird"}}]}';
      expect(s.importJson(raw), isTrue);
      expect(s.tasks.length, 2);
    });

    test('ملاحظة بسطر جديد وفواصل تُقتبس في CSV', () async {
      final s = await _fresh();
      s.addTask(TaskItem(id: 'a', name: 'أ, ب'));
      final d = DateTime(2026, 9);
      s.setStatus('a', d, TaskStatus.done);
      s.setNote('a', d, 'سطر1\nسطر2, "اقتباس"');
      final line = s
          .exportCsv()
          .split('\n')
          .firstWhere((l) => l.contains('2026-09-01'));
      expect(line, contains('"أ, ب"'));
      expect(s.exportCsv(), contains('"سطر1\nسطر2, ""اقتباس"""'));
    });
  });

  group('حساب', () {
    test('فشل حذف الحساب لا يمسح البيانات المحلية', () async {
      final s = await _fresh();
      s.attachServices(authGateway: _ThrowingAuth(), cloudGateway: _NoCloud());
      await s.onSignedIn(const AuthUser(id: 'u1', email: 'a@b.c', name: 'x'));
      s.addTask(TaskItem(id: 'keep', name: 'احتفظ'));
      await expectLater(s.deleteAccount(), throwsA(isA<AuthFailure>()));
      expect(s.taskById('keep'), isNotNull);
      expect(s.hasAccount, isTrue);
    });
  });
}
