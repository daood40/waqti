import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../screens/focus_screen.dart';
import 'common.dart';
import 'task_editor_sheet.dart';

/// نافذة تفاصيل مهمة: نسبة الالتزام، مرات الإنجاز والتفويت،
/// وسجل الشهر المعروض.
Future<void> showTaskDetailSheet(
  BuildContext context, {
  required String taskId,
  required int year,
  required int month,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => TaskDetailSheet(taskId: taskId, year: year, month: month),
  );
}

class TaskDetailSheet extends StatelessWidget {
  const TaskDetailSheet({
    super.key,
    required this.taskId,
    required this.year,
    required this.month,
  });

  final String taskId;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;
    final task = state.taskById(taskId);
    if (task == null) return const SizedBox.shrink();

    final dim = AppState.daysInMonth(year, month);
    var done = 0, missed = 0, applicable = 0;
    final history = <({int day, TaskStatus status})>[];
    for (var d = 1; d <= dim; d++) {
      final date = DateTime(year, month, d);
      final status = task.statusOn(date);
      if (status != null) history.add((day: d, status: status));
      if (!task.isApplicableOn(date) || status == TaskStatus.skipped) continue;
      applicable++;
      if (status == TaskStatus.done) done++;
      if (status == TaskStatus.missed) missed++;
    }
    final pct = applicable > 0 ? ((done / applicable) * 100).round() : 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueToday = task.isApplicableOn(today);
    final skippedToday = task.statusOn(today) == TaskStatus.skipped;
    final score = state.habitScore(task);
    final bestStreak = state.taskBestStreak(task);
    final noteController = TextEditingController(text: task.noteOn(today));

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
        Row(
          children: [
            TaskIconBox(task: task, size: 38, fontSize: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                task.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (task.isPaused) WqChip('⏸ ${s.pausedTag}', color: wq.late),
            if (task.isMeasurable)
              WqChip('🎯 ${task.target} ${task.unit}'.trim()),
            if (task.isQuit)
              WqChip(
                '🚭 ${state.daysSinceSlip(task)} ${s.daysClean}',
                color: wq.done,
              ),
          ],
        ),
        if (task.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            task.description,
            style: TextStyle(fontSize: 13, color: wq.textMuted),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MiniStat(value: '$pct%', label: s.commitment),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(value: '$done', label: s.doneCount),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(value: '$missed', label: s.missedCount),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LevelBar(pct: pct, color: Color(task.colorValue)),
        const SizedBox(height: 14),
        // درجة الاستمرارية (مرنة) + أطول سلسلة — بديل قلق السلسلة.
        WqCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📈 ${s.habitScore}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      s.habitScoreHint,
                      style: TextStyle(fontSize: 10.5, color: wq.textMuted),
                    ),
                    const SizedBox(height: 6),
                    LevelBar(pct: score, height: 8),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: wq.primaryDark,
                    ),
                  ),
                  Text(
                    '🔥 ${s.bestStreak2}: $bestStreak',
                    style: TextStyle(fontSize: 11, color: wq.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (task.subtasks.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            s.subtasks,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: wq.textMuted,
            ),
          ),
          for (var i = 0; i < task.subtasks.length; i++)
            InkWell(
              onTap: () => state.toggleSubtask(task.id, i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      task.subtasks[i].done
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: task.subtasks[i].done ? wq.done : wq.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.subtasks[i].title,
                        style: TextStyle(
                          fontSize: 13,
                          decoration: task.subtasks[i].done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: 14),
        Text(
          '📝 ${s.dayNote}',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: wq.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: noteController,
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(hintText: s.dayNoteHint),
          onSubmitted: (v) => state.setNote(task.id, today, v),
          onTapOutside: (_) =>
              state.setNote(task.id, today, noteController.text),
        ),
        const SizedBox(height: 14),
        // إجراءات سريعة: يوم راحة اليوم، إيقاف/استئناف، تركيز.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (dueToday)
              Tooltip(
                message: s.skipHint,
                child: FilledButton.icon(
                  onPressed: () => state.setStatus(
                    task.id,
                    today,
                    skippedToday ? null : TaskStatus.skipped,
                  ),
                  icon: Icon(
                    skippedToday ? Icons.undo_rounded : Icons.bedtime_outlined,
                    size: 16,
                  ),
                  label: Text(skippedToday ? s.cancel : s.skipDay),
                ),
              ),
            Tooltip(
              message: s.pausedHint,
              child: FilledButton.icon(
                onPressed: () => state.setPaused(task.id, !task.isPaused),
                icon: Icon(
                  task.isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  size: 16,
                ),
                label: Text(task.isPaused ? s.resumeTask : s.pauseTask),
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                FocusScreen.push(navigator.context, taskId: task.id);
              },
              icon: const Icon(Icons.timer_outlined, size: 16),
              label: Text(s.focusTimer),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          s.history,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: wq.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          Text(s.noData, style: TextStyle(fontSize: 13, color: wq.textMuted))
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final entry in history)
                Tooltip(
                  message: '${entry.day}',
                  child: StatusDot(status: entry.status),
                ),
            ],
          ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(s.close),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // نلتقط الـ Navigator قبل الإغلاق ونفتح المحرر من
                  // سياقه الحي بدل سياق النافذة المُغلقة.
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  showTaskEditorSheet(navigator.context, existing: task);
                },
                child: Text(s.editTask),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return WqCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: context.wq.textMuted),
          ),
        ],
      ),
    );
  }
}
