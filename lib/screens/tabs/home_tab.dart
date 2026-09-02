import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../../core/app_info.dart';
import '../../core/l10n.dart';
import '../../core/quotes.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/task_detail_sheet.dart';
import '../../widgets/trend_chart.dart';
import '../focus_screen.dart';
import '../shell_screen.dart';
import '../subscription_screen.dart';

/// تبويب الرئيسية: الجدول الشهري، منحنى الإنجازات، وحلقة نسبة الإنجاز.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.query});

  final String query;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _windowStart = 1;
  int? _windowMonthKey;

  static int _maxWindowStart(int dim) => 1 + 7 * ((dim - 1) ~/ 7);

  void _syncWindowWithMonth(MonthCursor cursor) {
    final key = cursor.year * 12 + cursor.month;
    if (_windowMonthKey == key) return;
    _windowMonthKey = key;
    final dim = AppState.daysInMonth(cursor.year, cursor.month);
    if (cursor.isCurrentMonth) {
      final start = 1 + 7 * ((DateTime.now().day - 1) ~/ 7);
      _windowStart = start.clamp(1, _maxWindowStart(dim));
    } else {
      _windowStart = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cursor = context.watch<MonthCursor>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;

    _syncWindowWithMonth(cursor);

    final dim = AppState.daysInMonth(cursor.year, cursor.month);
    final maxStart = _maxWindowStart(dim);
    final windowEnd = (_windowStart + 6).clamp(1, dim);
    final today = DateTime.now();

    final query = widget.query.trim().toLowerCase();
    final tasks = query.isEmpty
        ? state.tasks
        : state.tasks
              .where(
                (t) =>
                    t.name.toLowerCase().contains(query) ||
                    t.description.toLowerCase().contains(query),
              )
              .toList();

    final stats = state.monthStats(cursor.year, cursor.month);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        _TodayHeader(strings: s),
        const SizedBox(height: 10),
        _QuoteCard(lang: state.lang),
        const SizedBox(height: 4),
        if (!state.isPremium && !kLaunchMode) ...[
          const SizedBox(height: 4),
          WqCard(
            onTap: () => SubscriptionScreen.push(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Text('💎', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.adBannerTitle,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.adBannerSub,
                        style: TextStyle(fontSize: 12.5, color: wq.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: wq.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s.adBannerTag,
                    style: TextStyle(fontSize: 9.5, color: wq.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        _TodayCard(strings: s),
        _OverdueCard(strings: s),
        Text(
          s.monthlySchedule,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          s.trackDesc,
          style: TextStyle(fontSize: 13.5, color: wq.textMuted),
        ),
        const SizedBox(height: 18),
        WqCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WqIconButton(
                      onTap: () => cursor.shift(-1),
                      child: Icon(
                        Icons.chevron_left,
                        size: 20,
                        color: wq.text,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    Text(
                      '${s.months[cursor.month - 1]} ${cursor.year}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    WqIconButton(
                      onTap: () => cursor.shift(1),
                      child: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: wq.text,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: wq.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WqIconButton(
                      onTap: _windowStart > 1
                          ? () => setState(
                              () => _windowStart = (_windowStart - 7).clamp(
                                1,
                                maxStart,
                              ),
                            )
                          : null,
                      child: Icon(
                        Icons.chevron_left,
                        size: 18,
                        color: wq.text,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    Text(
                      '$_windowStart - $windowEnd / $dim',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: wq.textMuted,
                      ),
                    ),
                    WqIconButton(
                      onTap: _windowStart < maxStart
                          ? () => setState(
                              () => _windowStart = (_windowStart + 7).clamp(
                                1,
                                maxStart,
                              ),
                            )
                          : null,
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: wq.text,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ),
              if (tasks.isEmpty)
                Column(
                  children: [
                    EmptyHint(query.isNotEmpty ? s.noResults : s.noTasks),
                    if (query.isEmpty && state.tasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: FilledButton.icon(
                          onPressed: () {
                            state.seedDemoData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(s.demoLoaded)),
                            );
                          },
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: Text(s.loadDemoData),
                        ),
                      ),
                  ],
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
                  child: _HabitGrid(
                    tasks: tasks,
                    year: cursor.year,
                    month: cursor.month,
                    windowStart: _windowStart,
                    windowEnd: windowEnd,
                    today: today,
                    strings: s,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Legend(strings: s),
        SectionTitle(s.dailyTrend),
        WqCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: tasks.isEmpty && state.tasks.isEmpty
              ? EmptyHint(s.noData)
              : DailyTrendChart(
                  dailyCounts: state.dailyDoneCounts(cursor.year, cursor.month),
                  maxY: state.tasks.length,
                  todayIndex: cursor.isCurrentMonth ? today.day - 1 : -1,
                  axisLabel: s.tasksAxis,
                ),
        ),
        SectionTitle(s.completion),
        WqCard(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: CompletionRing(pct: stats.pct, label: s.completion),
          ),
        ),
      ],
    );
  }
}

/// شبكة العادات: صف لكل مهمة، وعمود لكل يوم من نافذة الأسبوع المعروضة.
class _HabitGrid extends StatelessWidget {
  const _HabitGrid({
    required this.tasks,
    required this.year,
    required this.month,
    required this.windowStart,
    required this.windowEnd,
    required this.today,
    required this.strings,
  });

  final List<TaskItem> tasks;
  final int year;
  final int month;
  final int windowStart;
  final int windowEnd;
  final DateTime today;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final wq = context.wq;
    final isCurrentMonth = year == today.year && month == today.month;
    final days = [for (var d = windowStart; d <= windowEnd; d++) d];

    return Column(
      children: [
        // صف رؤوس الأيام.
        Row(
          children: [
            const SizedBox(width: 46, child: Center(child: Text('📋'))),
            for (final d in days)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: wq.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    children: [
                      Text(
                        strings.weekdaysShort[DateTime(year, month, d).weekday %
                            7],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isCurrentMonth && d == today.day
                              ? wq.primaryDark
                              : wq.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$d',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isCurrentMonth && d == today.day
                              ? wq.primaryDark
                              : wq.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (final task in tasks)
          Padding(
            // هدف اللمس داخل StatusDot صار أعرض — لا حاجة لحشوة صف إضافية.
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                SizedBox(
                  width: 46,
                  child: Center(
                    child: TaskIconBox(
                      task: task,
                      onTap: () => showTaskDetailSheet(
                        context,
                        taskId: task.id,
                        year: year,
                        month: month,
                      ),
                    ),
                  ),
                ),
                for (final d in days)
                  Expanded(
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          final date = DateTime(year, month, d);
                          final applicable = task.isApplicableOn(date);
                          return StatusDot(
                            status: task.statusOn(date),
                            applicable: applicable,
                            onTap: applicable
                                ? () => state.cycleStatus(task.id, date)
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final wq = context.wq;

    Widget item(Color color, String label, {bool outlined = false}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: outlined ? Colors.transparent : color,
              shape: BoxShape.circle,
              border: outlined ? Border.all(color: color, width: 2) : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12.5, color: wq.textMuted)),
        ],
      );
    }

    return Wrap(
      spacing: 18,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        item(wq.done, strings.done),
        item(wq.late, strings.late),
        item(wq.missed, strings.missed),
        item(wq.textMuted.withValues(alpha: .55), strings.skipped),
        item(wq.none, strings.none, outlined: true),
      ],
    );
  }
}

/// بطاقة "مهام اليوم": إنجاز سريع لمهام اليوم الحالي بنقرة واحدة.
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final wq = context.wq;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // العاجل والمهم أولًا — الشاشة تجيب "على ماذا أركز الآن؟".
    final todayTasks = AppState.sortedByPriority(
      state.tasks.where((t) => t.isApplicableOn(today)).toList(),
    );
    if (todayTasks.isEmpty) return const SizedBox.shrink();

    // يوم الراحة لا يُحسب مع المستحق؛ الإنجاز المتأخر يُحسب إنجازًا.
    final counted = todayTasks
        .where((t) => t.statusOn(today) != TaskStatus.skipped)
        .toList(growable: false);
    final doneCount = counted
        .where((t) => t.statusOn(today)?.isCompleted ?? false)
        .length;
    final allDone = counted.isEmpty || doneCount == counted.length;
    final pct = counted.isEmpty
        ? 100
        : ((doneCount / counted.length) * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: WqCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '☀️ ${strings.todayTasks}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$doneCount / ${counted.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: allDone ? wq.done : wq.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: strings.focusTimer,
                      child: WqIconButton(
                        onTap: () => FocusScreen.push(context),
                        child: Icon(
                          Icons.timer_outlined,
                          size: 17,
                          color: wq.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            LevelBar(pct: pct, color: allDone ? wq.done : null, height: 8),
            const SizedBox(height: 12),
            if (allDone)
              Text(
                strings.todayAllDone,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: wq.done,
                ),
              )
            else
              ..._groupedChips(context, todayTasks, today),
          ],
        ),
      ),
    );
  }

  /// يجمّع شرائح اليوم بفترة اليوم عندما تكون محددة لأي عادة؛
  /// وإلا يعرضها كتلة واحدة.
  List<Widget> _groupedChips(
    BuildContext context,
    List<TaskItem> tasks,
    DateTime today,
  ) {
    final hasSlots = tasks.any((t) => t.timeSlot != TimeSlot.any);
    if (!hasSlots) {
      return [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final t in tasks) _TodayChip(task: t, date: today)],
        ),
      ];
    }
    final wq = context.wq;
    final widgets = <Widget>[];
    for (final slot in const [
      TimeSlot.morning,
      TimeSlot.afternoon,
      TimeSlot.evening,
      TimeSlot.any,
    ]) {
      final group = tasks.where((t) => t.timeSlot == slot).toList();
      if (group.isEmpty) continue;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Text(
            switch (slot) {
              TimeSlot.morning => strings.slotMorning,
              TimeSlot.afternoon => strings.slotAfternoon,
              TimeSlot.evening => strings.slotEvening,
              TimeSlot.any => strings.slotAny,
            },
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: wq.textMuted,
            ),
          ),
        ),
      );
      widgets.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final t in group) _TodayChip(task: t, date: today)],
        ),
      );
    }
    return widgets;
  }
}

/// حكمة اليوم — تتبدّل يوميًا وتُقرأ في ثانية.
class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    final wq = context.wq;
    final quote = DailyQuote.forDate(DateTime.now());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('💡', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            quote.text(lang),
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: wq.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// شريحة مهمة واحدة داخل بطاقة اليوم — تنقر لتقليب حالتها.
class _TodayChip extends StatelessWidget {
  const _TodayChip({required this.task, required this.date});

  final TaskItem task;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final wq = context.wq;
    final status = task.statusOn(date);
    // مهمة معلّقة عاجلة/عالية تُميَّز لونيًا حتى تُقرأ الأولوية بلمحة.
    final pendingFg = switch (task.priority) {
      TaskPriority.urgent => wq.missed,
      TaskPriority.high => wq.late,
      _ => wq.textMuted,
    };
    final (Color bg, Color fg) = switch (status) {
      TaskStatus.done => (wq.done.withValues(alpha: .15), wq.done),
      TaskStatus.doneLate => (wq.late.withValues(alpha: .15), wq.late),
      TaskStatus.missed => (wq.missed.withValues(alpha: .15), wq.missed),
      TaskStatus.skipped => (wq.surfaceAlt, wq.textMuted),
      null => (wq.surfaceAlt, pendingFg),
    };
    // عادة قابلة للقياس بلا حالة: كل نقرة تزيد التقدم خطوة حتى الهدف.
    final measurablePending = task.isMeasurable && status == null;
    final progressLabel = measurablePending
        ? ' ${task.progressOn(date)}/${task.target}'
              '${task.unit.isEmpty ? '' : ' ${task.unit}'}'
        : (task.isQuit && status == null
              ? ' · ${state.daysSinceSlip(task)}🛡'
              : '');
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // ردّ لمسي خفيف عند كل إنجاز (تشجيع بلا ضجيج).
          HapticFeedback.lightImpact();
          if (measurablePending) {
            state.incrementProgress(task.id, date);
          } else {
            state.cycleStatus(task.id, date);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(task.icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                '${task.name}$progressLabel',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                  decoration: status == TaskStatus.done
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: fg,
                ),
              ),
              if (status != null) ...[
                const SizedBox(width: 5),
                Icon(
                  switch (status) {
                    TaskStatus.done => Icons.check_circle,
                    TaskStatus.doneLate => Icons.error,
                    TaskStatus.missed => Icons.cancel,
                    TaskStatus.skipped => Icons.remove_circle_outline,
                  },
                  size: 14,
                  color: fg,
                ),
              ] else if (measurablePending) ...[
                const SizedBox(width: 5),
                Icon(Icons.add_circle_outline, size: 14, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ترويسة اليوم: تحية بحسب الوقت، التاريخ الكامل، وساعة حيّة.
class _TodayHeader extends StatefulWidget {
  const _TodayHeader({required this.strings});

  final AppStrings strings;

  @override
  State<_TodayHeader> createState() => _TodayHeaderState();
}

class _TodayHeaderState extends State<_TodayHeader> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // تحديث كل دقيقة يكفي لساعة بلا ثوانٍ.
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wq = context.wq;
    final s = widget.strings;
    final now = DateTime.now();
    final greeting = now.hour >= 5 && now.hour < 12
        ? s.greetingMorning
        : now.hour >= 12 && now.hour < 17
        ? s.greetingAfternoon
        : s.greetingEvening;
    final time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    // التاريخ الهجري — ميزة يفتقدها أغلب المنافسين في السوق العربي.
    HijriCalendar.language = s == AppStrings.ar ? 'ar' : 'en';
    final hijri = HijriCalendar.fromDate(now);
    final hijriLabel =
        '${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear} ${s.hijriSuffix}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${s.weekdays[now.weekday % 7]}، '
                '${now.day} ${s.months[now.month - 1]} ${now.year}',
                style: TextStyle(fontSize: 13, color: wq.textMuted),
              ),
              Text(
                hijriLabel,
                style: TextStyle(fontSize: 12, color: wq.primaryDark),
              ),
            ],
          ),
        ),
        Text(
          time,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: wq.primaryDark,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// بطاقة المتأخرات: أيام مستحقة فاتت بلا حالة خلال آخر أسبوع —
/// نقرة واحدة تنجز المهمة لذلك اليوم.
class _OverdueCard extends StatelessWidget {
  const _OverdueCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final wq = context.wq;
    final entries = state.overdueEntries();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: WqCard(
        padding: const EdgeInsets.all(16),
        borderColor: wq.late.withValues(alpha: .55),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, size: 17, color: wq.late),
                const SizedBox(width: 7),
                Text(
                  '${strings.overdueTitle} (${entries.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    '${strings.overdueHint} · ${strings.overdueRescue}',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 11, color: wq.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in entries.take(12))
                  _OverdueChip(entry: entry, strings: strings),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverdueChip extends StatelessWidget {
  const _OverdueChip({required this.entry, required this.strings});

  final ({TaskItem task, DateTime date}) entry;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final wq = context.wq;
    final task = entry.task;
    final date = entry.date;
    return Material(
      color: wq.late.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        // نقرة = إنجاز ذلك اليوم (التقليب الكامل متاح في الشبكة).
        onTap: () => state.cycleStatus(task.id, date),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(task.icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(
                task.name,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: wq.text,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${strings.weekdaysShort[date.weekday % 7]} ${date.day}',
                style: TextStyle(fontSize: 11, color: wq.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
