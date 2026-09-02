import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/category_manager_sheet.dart';
import '../../widgets/common.dart';
import '../../widgets/task_detail_sheet.dart';
import '../../widgets/task_editor_sheet.dart';
import '../shell_screen.dart';

/// تبويب المهام والعادات: القائمة الكاملة مع الإدارة
/// وإعادة الترتيب بالسحب والإفلات.
class TasksTab extends StatefulWidget {
  const TasksTab({super.key, required this.query});

  final String query;

  @override
  State<TasksTab> createState() => _TasksTabState();
}

enum _Sort { manual, priority, name, score }

class _TasksTabState extends State<TasksTab> {
  String? _categoryFilter; // null = الكل
  _Sort _sort = _Sort.manual;

  String get query => widget.query;

  Future<void> _deleteWithUndo(
    BuildContext context,
    AppState state,
    AppStrings s,
    TaskItem task,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.delete),
        content: Text(s.deleteTaskConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.wq.missed),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final removed = state.removeTask(task.id);
    if (removed == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.taskDeleted),
        action: SnackBarAction(
          label: s.undo,
          onPressed: () => state.restoreTask(removed.$1, removed.$2),
        ),
      ),
    );
  }

  String _recurrenceLabel(Recurrence recurrence, AppStrings s) =>
      switch (recurrence.type) {
        RecurrenceType.daily => s.daily,
        RecurrenceType.weekly => s.weekly,
        RecurrenceType.monthly => s.monthly,
        RecurrenceType.specificDays => s.specificDays,
        RecurrenceType.once => s.once,
      };

  Widget _header(BuildContext context, AppState state, AppStrings s) {
    final wq = context.wq;
    final showReorderHint = query.trim().isEmpty && state.tasks.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                s.tasks,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => showCategoryManagerSheet(context),
              child: Text(
                '🏷️ ${s.categoriesManage}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => showTaskEditorSheet(context),
              child: Text(
                '+ ${s.addTask}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        if (showReorderHint && _sort == _Sort.manual && _categoryFilter == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              s.reorderHint,
              style: TextStyle(fontSize: 11.5, color: wq.textMuted),
            ),
          ),
        const SizedBox(height: 10),
        // تصفية بالتصنيف + فرز — ما يطلبه مستخدمو Todoist/TickTick.
        if (state.tasks.length > 1)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: Text(s.filterAll),
                        selected: _categoryFilter == null,
                        onSelected: (_) =>
                            setState(() => _categoryFilter = null),
                        visualDensity: VisualDensity.compact,
                      ),
                      for (final c in state.categories) ...[
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: Text(c.name),
                          selected: _categoryFilter == c.id,
                          selectedColor: Color(
                            c.colorValue,
                          ).withValues(alpha: .25),
                          onSelected: (_) =>
                              setState(() => _categoryFilter = c.id),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<_Sort>(
                tooltip: s.sortManual,
                initialValue: _sort,
                onSelected: (v) => setState(() => _sort = v),
                icon: Icon(Icons.sort, size: 20, color: wq.textMuted),
                itemBuilder: (_) => [
                  PopupMenuItem(value: _Sort.manual, child: Text(s.sortManual)),
                  PopupMenuItem(
                    value: _Sort.priority,
                    child: Text(s.sortPriority),
                  ),
                  PopupMenuItem(value: _Sort.name, child: Text(s.sortName)),
                  PopupMenuItem(value: _Sort.score, child: Text(s.sortScore)),
                ],
              ),
            ],
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _taskCard(
    BuildContext context,
    AppState state,
    MonthCursor cursor,
    AppStrings s,
    TaskItem task,
  ) {
    final wq = context.wq;
    return Padding(
      key: ValueKey(task.id),
      padding: const EdgeInsets.only(bottom: 10),
      child: WqCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            TaskIconBox(task: task, size: 38, fontSize: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (state.categoryById(task.categoryId)
                          case final category?)
                        WqChip(
                          category.name,
                          color: Color(category.colorValue),
                        ),
                      if (task.isPaused)
                        WqChip('⏸ ${s.pausedTag}', color: wq.late),
                      if (task.isMeasurable)
                        WqChip('🎯 ${task.target} ${task.unit}'.trim()),
                      if (task.isQuit)
                        WqChip(
                          '🚭 ${state.daysSinceSlip(task)} ${s.daysClean}',
                          color: wq.done,
                        ),
                      WqChip('📈 ${state.habitScore(task)}%'),
                      WqChip(_recurrenceLabel(task.recurrence, s)),
                      WqChip(
                        switch (task.priority) {
                          TaskPriority.low => s.low,
                          TaskPriority.medium => s.medium,
                          TaskPriority.high => s.high,
                          TaskPriority.urgent => s.urgent,
                        },
                        color: switch (task.priority) {
                          TaskPriority.urgent => wq.missed,
                          TaskPriority.high => wq.late,
                          _ => null,
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            WqIconButton(
              tooltip: s.taskDetails,
              onTap: () => showTaskDetailSheet(
                context,
                taskId: task.id,
                year: cursor.year,
                month: cursor.month,
              ),
              child: Icon(
                Icons.insights_rounded,
                size: 17,
                color: wq.textMuted,
              ),
            ),
            const SizedBox(width: 6),
            WqIconButton(
              tooltip: s.editTask,
              onTap: () => showTaskEditorSheet(context, existing: task),
              child: Icon(Icons.edit_outlined, size: 17, color: wq.textMuted),
            ),
            const SizedBox(width: 6),
            WqIconButton(
              tooltip: s.delete,
              onTap: () => _deleteWithUndo(context, state, s, task),
              child: Icon(Icons.delete_outline, size: 17, color: wq.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cursor = context.watch<MonthCursor>();
    final s = AppStrings.of(state.lang);

    final trimmed = query.trim().toLowerCase();
    final filtering = _categoryFilter != null || _sort != _Sort.manual;
    final searching = trimmed.isNotEmpty || filtering;
    var tasks = state.tasks
        .where(
          (t) =>
              (trimmed.isEmpty ||
                  t.name.toLowerCase().contains(trimmed) ||
                  t.description.toLowerCase().contains(trimmed)) &&
              (_categoryFilter == null || t.categoryId == _categoryFilter),
        )
        .toList();
    tasks = switch (_sort) {
      _Sort.manual => tasks,
      _Sort.priority => AppState.sortedByPriority(tasks),
      _Sort.name => (tasks..sort((a, b) => a.name.compareTo(b.name))),
      _Sort.score =>
        (tasks
          ..sort((a, b) => state.habitScore(b).compareTo(state.habitScore(a)))),
    };

    const padding = EdgeInsets.fromLTRB(18, 8, 18, 24);

    if (tasks.isEmpty) {
      return ListView(
        padding: padding,
        children: [
          _header(context, state, s),
          WqCard(child: EmptyHint(searching ? s.noResults : s.noTasks)),
        ],
      );
    }

    if (searching) {
      return ListView(
        padding: padding,
        children: [
          _header(context, state, s),
          for (final task in tasks) _taskCard(context, state, cursor, s, task),
        ],
      );
    }

    // بدون بحث: قائمة قابلة لإعادة الترتيب بالسحب.
    return ReorderableListView(
      padding: padding,
      header: _header(context, state, s),
      onReorder: state.reorderTask,
      proxyDecorator: (child, index, animation) =>
          Material(color: Colors.transparent, child: child),
      children: [
        for (final task in tasks) _taskCard(context, state, cursor, s, task),
      ],
    );
  }
}
