import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../shell_screen.dart';

/// تبويب التقويم: شبكة الشهر مع ملخص إنجاز كل يوم.
class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cursor = context.watch<MonthCursor>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;

    final dim = AppState.daysInMonth(cursor.year, cursor.month);
    final firstWeekday = DateTime(cursor.year, cursor.month, 1).weekday % 7;
    final today = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        SectionTitle(s.calendar, topPadding: 0),
        WqCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
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
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Center(
                        child: Text(
                          s.weekdaysShort[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: wq.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.72,
                ),
                itemCount: firstWeekday + dim,
                itemBuilder: (context, index) {
                  if (index < firstWeekday) return const SizedBox.shrink();
                  final day = index - firstWeekday + 1;
                  final date = DateTime(cursor.year, cursor.month, day);
                  final isToday = cursor.isCurrentMonth && day == today.day;
                  final dayTasks = state.tasks
                      .where((t) => t.isApplicableOn(date))
                      .toList(growable: false);
                  final doneCount = dayTasks
                      .where((t) => t.statusOn(date)?.isCompleted ?? false)
                      .length;

                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showDay(context, date),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: wq.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isToday ? wq.primary : wq.border,
                          width: isToday ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isToday ? wq.primaryDark : wq.text,
                            ),
                          ),
                          if (dayTasks.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              '$doneCount/${dayTasks.length}',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: wq.textMuted,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Expanded(
                              child: Wrap(
                                spacing: 2,
                                runSpacing: 2,
                                children: [
                                  for (final t in dayTasks.take(6))
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: switch (t.statusOn(date)) {
                                          TaskStatus.done => wq.done,
                                          TaskStatus.doneLate => wq.late,
                                          TaskStatus.missed => wq.missed,
                                          TaskStatus.skipped =>
                                            wq.textMuted.withValues(alpha: .5),
                                          null => wq.none,
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ورقة اليوم: مهام ذلك التاريخ مع تبديل الحالة بنقرة (لا أيام مستقبلية).
  void _showDay(BuildContext context, DateTime date) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) => _DaySheet(date: date),
    );
  }
}

class _DaySheet extends StatelessWidget {
  const _DaySheet({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final future = date.isAfter(today);
    final tasks = state.tasks
        .where((t) => t.isApplicableOn(date))
        .toList(growable: false);
    final done = tasks
        .where((t) => t.statusOn(date)?.isCompleted ?? false)
        .length;

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: wq.none,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${date.day} ${s.months[date.month - 1]} ${date.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          tasks.isEmpty
              ? s.noTasksThatDay
              : '$done / ${tasks.length}${future ? '' : ' · ${s.tapToCycle}'}',
          style: TextStyle(fontSize: 12.5, color: wq.textMuted),
        ),
        const SizedBox(height: 12),
        for (final t in tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(t.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StatusDot(
                  status: t.statusOn(date),
                  onTap: future ? null : () => state.cycleStatus(t.id, date),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.close),
          ),
        ),
      ],
    );
  }
}
