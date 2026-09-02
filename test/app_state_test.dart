import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqti/models/models.dart';
import 'package:waqti/state/app_state.dart';

Future<AppState> freshState() async {
  SharedPreferences.setMockInitialValues({});
  return AppState.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts with default categories and no tasks', () async {
    final state = await freshState();
    expect(state.categories, hasLength(4));
    expect(state.tasks, isEmpty);
    expect(state.loggedIn, isFalse);
  });

  test('free plan allows at most 5 tasks; premium is unlimited', () async {
    final state = await freshState();
    for (var i = 0; i < 5; i++) {
      expect(state.addTask(TaskItem(id: 't$i', name: 'مهمة $i')), isTrue);
    }
    expect(state.addTask(TaskItem(id: 't5', name: 'زيادة')), isFalse);
    state.setPremium(true);
    expect(state.addTask(TaskItem(id: 't5', name: 'زيادة')), isTrue);
  });

  test(
    'cycleStatus cycles pending → done → late → missed → skipped → pending',
    () async {
      final state = await freshState();
      final task = TaskItem(id: 't1', name: 'قراءة');
      state.addTask(task);
      final date = DateTime(2026, 8, 10);

      state.cycleStatus('t1', date);
      expect(task.statusOn(date), TaskStatus.done);
      state.cycleStatus('t1', date);
      expect(task.statusOn(date), TaskStatus.doneLate);
      state.cycleStatus('t1', date);
      expect(task.statusOn(date), TaskStatus.missed);
      state.cycleStatus('t1', date);
      expect(task.statusOn(date), TaskStatus.skipped);
      state.cycleStatus('t1', date);
      expect(task.statusOn(date), isNull);
    },
  );

  test('monthStats counts applicable and done occurrences', () async {
    final state = await freshState();
    final task = TaskItem(id: 't1', name: 'قراءة');
    state.addTask(task);
    task.setStatusOn(DateTime(2026, 8, 1), TaskStatus.done);
    task.setStatusOn(DateTime(2026, 8, 2), TaskStatus.doneLate);
    task.setStatusOn(DateTime(2026, 8, 3), TaskStatus.missed);

    final stats = state.monthStats(2026, 8);
    expect(stats.applicable, 31);
    expect(stats.done, 1);
    expect(stats.late, 1);
    expect(stats.missed, 1);
    expect(stats.pct, ((1 / 31) * 100).round());
  });

  test('totalDone counts done and doneLate across all days', () async {
    final state = await freshState();
    final task = TaskItem(id: 't1', name: 'قراءة');
    state.addTask(task);
    task.setStatusOn(DateTime(2026, 7, 30), TaskStatus.done);
    task.setStatusOn(DateTime(2026, 8, 1), TaskStatus.doneLate);
    task.setStatusOn(DateTime(2026, 8, 2), TaskStatus.missed);
    expect(state.totalDone(), 2);
  });

  test('XP: 10 per done, 4 per late', () async {
    final state = await freshState();
    final task = TaskItem(id: 't1', name: 'قراءة');
    state.addTask(task);
    task.setStatusOn(DateTime(2026, 8, 1), TaskStatus.done);
    task.setStatusOn(DateTime(2026, 8, 2), TaskStatus.done);
    task.setStatusOn(DateTime(2026, 8, 3), TaskStatus.doneLate);
    task.setStatusOn(DateTime(2026, 8, 4), TaskStatus.missed);
    expect(state.totalXp(), 24);
  });

  test('streak counts consecutive fully-done days ending today', () async {
    final state = await freshState();
    final task = TaskItem(id: 't1', name: 'قراءة');
    state.addTask(task);
    final today = DateTime.now();
    for (var i = 0; i < 3; i++) {
      task.setStatusOn(today.subtract(Duration(days: i)), TaskStatus.done);
    }
    expect(state.currentStreak(), 3);

    // يوم مفقود قبلها يقطع التتابع عند 3.
    task.setStatusOn(
      today.subtract(const Duration(days: 3)),
      TaskStatus.missed,
    );
    expect(state.currentStreak(), 3);
  });

  test('removing a category unlinks its tasks', () async {
    final state = await freshState();
    final category = state.addCategory('عمل', 0xFF123456);
    final task = TaskItem(id: 't1', name: 'اجتماع', categoryId: category.id);
    state.addTask(task);
    state.removeCategory(category.id);
    expect(task.categoryId, isNull);
    expect(state.categoryById(category.id), isNull);
  });

  test('export/import round-trip preserves tasks and categories', () async {
    final state = await freshState();
    state.addTask(
      TaskItem(id: 't1', name: 'قراءة')
        ..setStatusOn(DateTime(2026, 8, 1), TaskStatus.done),
    );
    final exported = state.exportJson();

    final other = await freshState();
    expect(other.importJson(exported), isTrue);
    expect(other.tasks, hasLength(1));
    expect(other.tasks.first.name, 'قراءة');
    expect(other.tasks.first.statusOn(DateTime(2026, 8, 1)), TaskStatus.done);
    expect(other.importJson('ليس JSON'), isFalse);
  });

  test('remove/restore task supports undo', () async {
    final state = await freshState();
    state.addTask(TaskItem(id: 't1', name: 'أ'));
    state.addTask(TaskItem(id: 't2', name: 'ب'));
    final removed = state.removeTask('t1');
    expect(removed, isNotNull);
    expect(state.tasks, hasLength(1));
    state.restoreTask(removed!.$1, removed.$2);
    expect(state.tasks, hasLength(2));
    expect(state.tasks.first.id, 't1');
  });

  // ---------- اختبارات إضافية للمزايا الجديدة ----------

  test('seedDemoData seeds within the free plan limit and only once', () async {
    final state = await freshState();
    state.seedDemoData();
    expect(state.tasks, hasLength(5));
    expect(state.tasks.length <= AppState.freePlanTaskLimit, isTrue);
    state.seedDemoData(); // لا تُزرع مرة ثانية فوق بيانات موجودة.
    expect(state.tasks, hasLength(5));
  });

  test('reorderTask moves a task and persists order', () async {
    final state = await freshState();
    state.addTask(TaskItem(id: 'a', name: 'أ'));
    state.addTask(TaskItem(id: 'b', name: 'ب'));
    state.addTask(TaskItem(id: 'c', name: 'ج'));
    state.reorderTask(0, 3); // كما يرسلها ReorderableListView
    expect(state.tasks.map((t) => t.id).toList(), ['b', 'c', 'a']);
    state.reorderTask(2, 0);
    expect(state.tasks.map((t) => t.id).toList(), ['a', 'b', 'c']);
  });

  test('dailyCompletionPct returns -1 without applicable tasks', () async {
    final state = await freshState();
    expect(state.dailyCompletionPct(DateTime(2026, 8, 10)), -1);
    final task = TaskItem(id: 't1', name: 'قراءة');
    state.addTask(task);
    expect(state.dailyCompletionPct(DateTime(2026, 8, 10)), 0);
    task.setStatusOn(DateTime(2026, 8, 10), TaskStatus.done);
    expect(state.dailyCompletionPct(DateTime(2026, 8, 10)), 100);
  });

  test('theme mode system round-trips through persistence', () async {
    SharedPreferences.setMockInitialValues({});
    var state = await AppState.load();
    state.setThemeMode(ThemeMode.system);
    // نعيد التحميل من نفس التخزين الوهمي.
    state = await AppState.load();
    expect(state.themeMode, ThemeMode.system);
  });

  test('weeklyBuckets covers the whole month', () async {
    final state = await freshState();
    final task = TaskItem(id: 't1', name: 'قراءة');
    state.addTask(task);
    for (var d = 1; d <= 7; d++) {
      task.setStatusOn(DateTime(2026, 8, d), TaskStatus.done);
    }
    final buckets = state.weeklyBuckets(2026, 8);
    expect(buckets, hasLength(5)); // 31 يومًا → 5 مقاطع
    expect(buckets.first.pct, 100);
    expect(buckets.last.pct, 0);
  });

  test('best and worst habit ranked by commitment', () async {
    final state = await freshState();
    final good = TaskItem(id: 'g', name: 'جيدة');
    final bad = TaskItem(id: 'b', name: 'ضعيفة');
    state.addTask(good);
    state.addTask(bad);
    for (var d = 1; d <= 10; d++) {
      good.setStatusOn(DateTime(2026, 8, d), TaskStatus.done);
    }
    expect(state.bestHabit(2026, 8)!.task.id, 'g');
    expect(state.worstHabit(2026, 8)!.task.id, 'b');
  });

  test('levelInfo derives level from xp', () async {
    final state = await freshState();
    final task = TaskItem(id: 't1', name: 'قراءة');
    state.addTask(task);
    // 31 يوم إنجاز = 310 نقطة → المستوى 2 والباقي 10.
    for (var d = 1; d <= 31; d++) {
      task.setStatusOn(DateTime(2026, 8, d), TaskStatus.done);
    }
    final level = state.levelInfo();
    expect(level.level, 2);
    expect(level.current, 10);
  });

  test('urgent priority round-trips through JSON', () async {
    final task = TaskItem(
      id: 'u1',
      name: 'عاجلة',
      priority: TaskPriority.urgent,
    );
    final decoded = TaskItem.fromJson(task.toJson());
    expect(decoded.priority, TaskPriority.urgent);
    expect(TaskPriority.fromKey('urgent'), TaskPriority.urgent);
    expect(TaskPriority.fromKey('unknown'), TaskPriority.medium);
  });

  test('sortedByPriority puts urgent first and keeps manual order within '
      'a priority', () async {
    final a = TaskItem(id: 'a', name: 'a', priority: TaskPriority.low);
    final b = TaskItem(id: 'b', name: 'b', priority: TaskPriority.urgent);
    final c = TaskItem(id: 'c', name: 'c', priority: TaskPriority.high);
    final d = TaskItem(id: 'd', name: 'd', priority: TaskPriority.high);
    final sorted = AppState.sortedByPriority([a, b, c, d]);
    expect(sorted.map((t) => t.id).toList(), ['b', 'c', 'd', 'a']);
  });

  test('overdueEntries lists past applicable days without status, '
      'excluding today', () async {
    final state = await freshState();
    state.setPremium(true);
    final now3 = DateTime.now();
    final task = TaskItem(
      id: 'o1',
      name: 'يومية',
      createdAt: DateTime(now3.year, now3.month, now3.day - 5),
    );
    state.addTask(task);
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);

    var overdue = state.overdueEntries(lookBackDays: 3);
    expect(overdue, hasLength(3)); // ثلاثة أيام ماضية بلا حالة

    task.setStatusOn(yesterday, TaskStatus.done);
    overdue = state.overdueEntries(lookBackDays: 3);
    expect(overdue, hasLength(2));
    expect(
      overdue.any(
        (e) => e.date.day == yesterday.day && e.date.month == yesterday.month,
      ),
      isFalse,
    );
    expect(
      overdue.any(
        (e) => e.date.day == twoDaysAgo.day && e.date.month == twoDaysAgo.month,
      ),
      isTrue,
    );
    // اليوم نفسه لا يُعد متأخرًا
    expect(overdue.any((e) => e.date.day == now.day), isFalse);
  });

  test(
    'a task created today has no overdue entries; createdAt round-trips',
    () async {
      final state = await freshState();
      state.setPremium(true);
      state.addTask(TaskItem(id: 'n1', name: 'جديدة'));
      expect(state.overdueEntries(lookBackDays: 7), isEmpty);

      final old = TaskItem(
        id: 'n2',
        name: 'قديمة',
        createdAt: DateTime(2020, 5, 5),
      );
      final decoded = TaskItem.fromJson(old.toJson());
      expect(decoded.createdAt.year, 2020);
      // بيانات بلا createdAt تُعامل كقديمة
      final legacyJson = old.toJson()..remove('createdAt');
      expect(TaskItem.fromJson(legacyJson).createdAt.year, 2000);
    },
  );

  test('plan tiers gate task limits and persist', () async {
    final state = await freshState();
    // برونزي: 15 حدًا أقصى
    state.setTier(PlanTier.bronze);
    for (var i = 0; i < 15; i++) {
      expect(state.addTask(TaskItem(id: 'b$i', name: 'م$i')), isTrue);
    }
    expect(state.addTask(TaskItem(id: 'b15', name: 'زيادة')), isFalse);
    // فضي: بلا حدود
    state.setTier(PlanTier.silver);
    expect(state.addTask(TaskItem(id: 'b15', name: 'زيادة')), isTrue);
    // الحفظ والاستعادة يحفظان الباقة
    var restored = await AppState.load();
    expect(restored.tier, PlanTier.silver);
    expect(restored.isPremium, isTrue);
    // ترحيل isPremium القديم إلى الذهبي
    SharedPreferences.setMockInitialValues({
      'waqti.v1': '{"isPremium": true, "tasks": [], "categories": []}',
    });
    restored = await AppState.load();
    expect(restored.tier, PlanTier.gold);
  });

  test(
    'skipped day is neutral: excluded from stats and keeps streak',
    () async {
      final state = await freshState();
      final task = TaskItem(id: 't1', name: 'قراءة');
      state.addTask(task);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      final before = DateTime(today.year, today.month, today.day - 2);
      task.setStatusOn(before, TaskStatus.done);
      task.setStatusOn(yesterday, TaskStatus.skipped);
      task.setStatusOn(today, TaskStatus.done);
      expect(state.currentStreak(), 2);
      final stats = state.monthStats(today.year, today.month);
      expect(stats.applicable, greaterThan(0));
      // يوم الراحة ليس ضمن المستحق ولا الفائت.
      expect(stats.missed, 0);
      expect(state.dailyCompletionPct(yesterday), -1);
    },
  );

  test('late completion rescues the streak; missed breaks it', () async {
    final state = await freshState();
    final task = TaskItem(id: 't1', name: 'قراءة');
    state.addTask(task);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d1 = DateTime(today.year, today.month, today.day - 1);
    final d2 = DateTime(today.year, today.month, today.day - 2);
    task.setStatusOn(d2, TaskStatus.done);
    task.setStatusOn(d1, TaskStatus.doneLate);
    task.setStatusOn(today, TaskStatus.done);
    expect(state.currentStreak(), 3);
    task.setStatusOn(d1, TaskStatus.missed);
    expect(state.currentStreak(), 1);
  });

  test('cycleStatus passes through skipped then clears', () async {
    final state = await freshState();
    state.addTask(TaskItem(id: 't1', name: 'قراءة'));
    final date = DateTime(2026, 8, 10);
    for (var i = 0; i < 4; i++) {
      state.cycleStatus('t1', date);
    }
    expect(state.taskById('t1')!.statusOn(date), TaskStatus.skipped);
    state.cycleStatus('t1', date);
    expect(state.taskById('t1')!.statusOn(date), isNull);
  });

  test('measurable habit: progress increments up to target = done', () async {
    final state = await freshState();
    final task = TaskItem(id: 'w', name: 'ماء', target: 3, unit: 'كوب');
    state.addTask(task);
    final date = DateTime(2026, 8, 10);
    state.incrementProgress('w', date);
    state.incrementProgress('w', date);
    expect(task.progressOn(date), 2);
    expect(task.statusOn(date), isNull);
    state.incrementProgress('w', date);
    expect(task.progressOn(date), 3);
    expect(task.statusOn(date), TaskStatus.done);
    // مسح الحالة يصفّر التقدم؛ الإنجاز المباشر يملأ الهدف.
    state.setStatus('w', date, null);
    expect(task.progressOn(date), 0);
    state.setStatus('w', date, TaskStatus.done);
    expect(task.progressOn(date), 3);
  });

  test('target/unit/progress/pausedAt/reminder survive JSON', () async {
    final task = TaskItem(
      id: 'w',
      name: 'ماء',
      target: 8,
      unit: 'كوب',
      reminders: const [510],
      pausedAt: DateTime(2026, 8, 20),
    )..setProgressOn(DateTime(2026, 8, 10), 5);
    final copy = TaskItem.fromJson(task.toJson());
    expect(copy.target, 8);
    expect(copy.unit, 'كوب');
    expect(copy.reminders, [510]);
    expect(copy.reminderMinutes, 510);
    expect(copy.pausedAt, DateTime(2026, 8, 20));
    expect(copy.progressOn(DateTime(2026, 8, 10)), 5);
    // بيانات قديمة بلا الحقول الجديدة تبقى صالحة.
    final legacy = TaskItem.fromJson({'id': 'x', 'name': 'قديم'});
    expect(legacy.target, 1);
    expect(legacy.isMeasurable, isFalse);
    expect(legacy.isPaused, isFalse);
  });

  test(
    'paused task is not applicable from pausedAt on, history kept',
    () async {
      final state = await freshState();
      final task = TaskItem(id: 't1', name: 'قراءة');
      state.addTask(task);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      task.setStatusOn(yesterday, TaskStatus.done);
      state.setPaused('t1', true);
      expect(task.isApplicableOn(today), isFalse);
      expect(task.isApplicableOn(yesterday), isTrue);
      expect(state.overdueEntries(), isEmpty);
      state.setPaused('t1', false);
      expect(task.isApplicableOn(today), isTrue);
    },
  );

  test('focus minutes accumulate per day and persist', () async {
    final state = await freshState();
    final date = DateTime(2026, 8, 10);
    state.addFocusMinutes(25, date: date);
    state.addFocusMinutes(15, date: date);
    expect(state.focusMinutesOn(date), 40);
    expect(state.focusMinutesInMonth(2026, 8), 40);
    expect(state.focusMinutesInMonth(2026, 7), 0);
    final reloaded = await AppState.load();
    expect(reloaded.focusMinutesOn(date), 40);
  });

  test('legacy single reminder migrates to reminders list', () async {
    final t = TaskItem.fromJson({'id': 'x', 'name': 'قديم', 'reminder': 600});
    expect(t.reminders, [600]);
  });

  test('subtasks, notes, slot and quit survive JSON', () async {
    final task = TaskItem(
      id: 'q',
      name: 'تدخين',
      isQuit: true,
      timeSlot: TimeSlot.evening,
      subtasks: [Subtask(title: 'رمي العلبة', done: true)],
    )..setNoteOn(DateTime(2026, 8, 10), 'يوم صعب لكن نجحت');
    final copy = TaskItem.fromJson(task.toJson());
    expect(copy.isQuit, isTrue);
    expect(copy.timeSlot, TimeSlot.evening);
    expect(copy.subtasks.single.title, 'رمي العلبة');
    expect(copy.subtasks.single.done, isTrue);
    expect(copy.noteOn(DateTime(2026, 8, 10)), 'يوم صعب لكن نجحت');
  });

  test('habit score fades on misses instead of resetting', () async {
    final state = await freshState();
    final task = TaskItem(
      id: 't',
      name: 'قراءة',
      createdAt: DateTime(2026, 1, 1),
    );
    state.addTask(task);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var i = 1; i <= 30; i++) {
      task.setStatusOn(
        DateTime(today.year, today.month, today.day - i),
        TaskStatus.done,
      );
    }
    final perfect = state.habitScore(task);
    expect(perfect, greaterThanOrEqualTo(95));
    // فوات يوم واحد أمس: الدرجة تهبط قليلًا فقط ولا تُصفَّر.
    task.setStatusOn(
      DateTime(today.year, today.month, today.day - 1),
      TaskStatus.missed,
    );
    final afterMiss = state.habitScore(task);
    expect(afterMiss, lessThan(perfect));
    expect(afterMiss, greaterThan(70));
  });

  test('best streak per task and longest overall streak', () async {
    final state = await freshState();
    final task = TaskItem(
      id: 't',
      name: 'قراءة',
      createdAt: DateTime(2026, 1, 1),
    );
    state.addTask(task);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime back(int d) => DateTime(today.year, today.month, today.day - d);
    for (final d in [10, 9, 8, 7, 6]) {
      task.setStatusOn(back(d), TaskStatus.done); // سلسلة 5
    }
    task.setStatusOn(back(5), TaskStatus.missed);
    task.setStatusOn(back(2), TaskStatus.done);
    task.setStatusOn(back(1), TaskStatus.doneLate); // سلسلة 2
    expect(state.taskBestStreak(task), 5);
    expect(state.longestStreak(), 5);
    expect(state.currentStreak(), 2);
  });

  test('quiet hours window wraps midnight', () async {
    final state = await freshState();
    state.setQuietHours(on: true, start: 22 * 60, end: 7 * 60);
    expect(state.isQuietAt(23 * 60), isTrue);
    expect(state.isQuietAt(3 * 60), isTrue);
    expect(state.isQuietAt(12 * 60), isFalse);
    state.setQuietHours(on: false);
    expect(state.isQuietAt(23 * 60), isFalse);
  });

  test('daysSinceSlip counts from the last missed day', () async {
    final state = await freshState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final task = TaskItem(
      id: 'q',
      name: 'تدخين',
      isQuit: true,
      createdAt: DateTime(today.year, today.month, today.day - 20),
    );
    state.addTask(task);
    expect(state.daysSinceSlip(task), 20);
    task.setStatusOn(
      DateTime(today.year, today.month, today.day - 3),
      TaskStatus.missed,
    );
    expect(state.daysSinceSlip(task), 3);
  });

  test('csv export lists one row per status', () async {
    final state = await freshState();
    final task = TaskItem(id: 't', name: 'قراءة "مهمة"');
    state.addTask(task);
    task.setStatusOn(DateTime(2026, 8, 1), TaskStatus.done);
    task.setNoteOn(DateTime(2026, 8, 1), 'ممتاز');
    final csv = state.exportCsv();
    expect(csv.split('\n').first, 'task,date,status,progress,note');
    expect(csv, contains('"قراءة ""مهمة""",2026-08-01,done,,"ممتاز"'));
  });

  test('daily local backup can be restored', () async {
    SharedPreferences.setMockInitialValues({});
    var state = await AppState.load();
    state.addTask(TaskItem(id: 'a', name: 'أ'));
    await Future<void>.delayed(Duration.zero);
    expect(state.backupDate, isNotNull);
    state.removeTask('a');
    expect(state.tasks, isEmpty);
    expect(state.restoreBackup(), isTrue);
    expect(state.tasks.map((t) => t.id), contains('a'));
    state = await AppState.load();
    expect(state.tasks.map((t) => t.id), contains('a'));
  });
}
