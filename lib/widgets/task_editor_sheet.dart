import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../core/templates.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../screens/subscription_screen.dart';
import '../state/app_state.dart';
import 'category_manager_sheet.dart';
import 'common.dart';

/// يفتح نافذة إنشاء/تعديل مهمة. يرجع `true` إذا حُفظت.
Future<bool?> showTaskEditorSheet(BuildContext context, {TaskItem? existing}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // على الشاشات العريضة تبقى الورقة بعرض نموذج مريح في المنتصف.
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => TaskEditorSheet(existing: existing),
  );
}

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({super.key, this.existing});

  final TaskItem? existing;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  final _customIconController = TextEditingController();

  late String _icon;
  late int _colorValue;
  String? _categoryId;
  late TaskPriority _priority;
  late Recurrence _recurrence;
  late bool _notificationsOn;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;
  final _subtaskController = TextEditingController();
  late List<int> _reminders;
  late List<Subtask> _subtasks;
  late TimeSlot _timeSlot;
  late bool _isQuit;
  String? _nameError;
  String? _formError;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final state = context.read<AppState>();
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descController = TextEditingController(text: existing?.description ?? '');
    _icon = existing?.icon ?? kTaskIconChoices.first;
    _colorValue = existing?.colorValue ?? kTaskColorPalette.first;
    _categoryId =
        existing?.categoryId ??
        (state.categories.isNotEmpty ? state.categories.first.id : null);
    _priority = existing?.priority ?? TaskPriority.medium;
    _recurrence = existing?.recurrence ?? const Recurrence();
    _notificationsOn = existing?.notificationsOn ?? true;
    _targetController = TextEditingController(text: '${existing?.target ?? 1}');
    _unitController = TextEditingController(text: existing?.unit ?? '');
    _reminders = List.of(existing?.reminders ?? const []);
    _subtasks = [
      for (final st in existing?.subtasks ?? const <Subtask>[])
        Subtask(title: st.title, done: st.done),
    ];
    _timeSlot = existing?.timeSlot ?? TimeSlot.any;
    _isQuit = existing?.isQuit ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _customIconController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  int get _target =>
      (int.tryParse(_targetController.text.trim()) ?? 1).clamp(1, 100000);

  /// يملأ الحقول من قالب جاهز بنقرة واحدة.
  void _applyTemplate(HabitTemplate t, AppState state) {
    setState(() {
      _nameController.text = t.name(state.lang);
      _icon = t.icon;
      _priority = t.priority;
      _targetController.text = '${t.target}';
      _unitController.text = t.unit(state.lang);
      _timeSlot = t.timeSlot;
      _isQuit = t.isQuit;
      if (state.categoryById(t.categoryId) != null) {
        _categoryId = t.categoryId;
      }
      _nameError = null;
    });
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(Subtask(title: text));
      _subtaskController.clear();
    });
  }

  /// وقت افتراضي بحسب فترة اليوم حتى يكون الاقتراح منطقيًا.
  int get _defaultReminder => switch (_timeSlot) {
    TimeSlot.morning => 7 * 60,
    TimeSlot.afternoon => 13 * 60,
    TimeSlot.evening => 20 * 60,
    TimeSlot.any => 9 * 60,
  };

  Future<void> _pickReminder({int? replaceIndex}) async {
    final initial = replaceIndex == null
        ? _defaultReminder
        : _reminders[replaceIndex];
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    setState(() {
      if (replaceIndex == null) {
        if (!_reminders.contains(minutes) && _reminders.length < 3) {
          _reminders.add(minutes);
        }
      } else {
        _reminders[replaceIndex] = minutes;
      }
      _reminders.sort();
    });
  }

  static String _hhmm(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

  void _save() {
    final s = AppStrings.of(context.read<AppState>().lang);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = s.enterTaskName);
      return;
    }
    // مهمة "مرة واحدة" بلا تاريخ لن تظهر أبدًا — نفترض اليوم.
    if (_recurrence.type == RecurrenceType.once && _recurrence.date == null) {
      _recurrence = _recurrence.copyWith(date: DateTime.now());
    }
    final state = context.read<AppState>();
    if (_isEditing) {
      final task = widget.existing!.deepCopy()
        ..name = name
        ..description = _descController.text.trim()
        ..icon = _icon
        ..colorValue = _colorValue
        ..categoryId = _categoryId
        ..priority = _priority
        ..recurrence = _recurrence
        ..notificationsOn = _notificationsOn
        ..target = _target
        ..unit = _unitController.text.trim()
        ..timeSlot = _timeSlot
        ..isQuit = _isQuit
        ..reminders.clear()
        ..reminders.addAll(_reminders)
        ..subtasks.clear()
        ..subtasks.addAll(_subtasks);
      state.updateTask(task);
    } else {
      final task = TaskItem(
        id: TaskItem.newId(),
        name: name,
        description: _descController.text.trim(),
        icon: _icon,
        colorValue: _colorValue,
        categoryId: _categoryId,
        priority: _priority,
        recurrence: _recurrence,
        notificationsOn: _notificationsOn,
        target: _target,
        unit: _unitController.text.trim(),
        timeSlot: _timeSlot,
        isQuit: _isQuit,
        reminders: _reminders,
        subtasks: _subtasks,
      );
      if (!state.addTask(task)) {
        // Snackbar يظهر خلف النافذة المنبثقة ولا يُرى —
        // نعرض الرسالة داخل النافذة نفسها مع دعوة للترقية.
        setState(() => _formError = s.freeLimitReached);
        return;
      }
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _confirmDelete() async {
    final state = context.read<AppState>();
    final s = AppStrings.of(state.lang);
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
    if (confirmed != true || !mounted) return;
    final removed = state.removeTask(widget.existing!.id);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    if (removed != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(s.taskDeleted),
          action: SnackBarAction(
            label: s.undo,
            onPressed: () => state.restoreTask(removed.$1, removed.$2),
          ),
        ),
      );
    }
  }

  void _addCustomIcon() {
    final value = _customIconController.text.trim();
    if (value.isEmpty) return;
    context.read<AppState>().addCustomIcon(value);
    setState(() {
      _icon = value;
      _customIconController.clear();
    });
  }

  Future<void> _pickCustomColor() async {
    final state = context.read<AppState>();
    final s = AppStrings.of(state.lang);
    final controller = TextEditingController(
      text: _colorValue
          .toRadixString(16)
          .padLeft(8, '0')
          .substring(2)
          .toUpperCase(),
    );
    final picked = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.customColorLabel),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: s.hexColorHint,
            prefixText: '#',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () {
              final hex = controller.text.trim().replaceAll('#', '');
              final value = int.tryParse(hex, radix: 16);
              if (hex.length == 6 && value != null) {
                Navigator.of(dialogContext).pop(0xFF000000 | value);
              }
            },
            child: Text(s.addNew),
          ),
        ],
      ),
    );
    controller.dispose();
    if (picked == null || !mounted) return;
    state.addCustomColor(picked);
    setState(() => _colorValue = picked);
  }

  Future<void> _pickOnceDate() async {
    final initial = _recurrence.date ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked == null) return;
    setState(() => _recurrence = _recurrence.copyWith(date: picked));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;

    final iconChoices = [...kTaskIconChoices, ...state.customIcons];
    final colorChoices = [...kTaskColorPalette, ...state.customColors];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ListView(
          controller: scrollController,
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
              _isEditing ? s.editTask : s.newTask,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (!_isEditing) ...[
              _FieldLabel(s.quickSuggestions),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kHabitTemplates.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final t = kHabitTemplates[i];
                    return ActionChip(
                      label: Text('${t.icon} ${t.name(state.lang)}'),
                      labelStyle: const TextStyle(fontSize: 12),
                      onPressed: () => _applyTemplate(t, state),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],
            _FieldLabel(s.name),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(errorText: _nameError),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 14),
            _FieldLabel(s.description),
            TextField(
              controller: _descController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(hintText: s.whyHint),
            ),
            const SizedBox(height: 14),
            _FieldLabel(s.icon),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final icon in iconChoices)
                  GestureDetector(
                    onTap: () => setState(() => _icon = icon),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: wq.surfaceAlt,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: _icon == icon
                              ? wq.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customIconController,
                    maxLength: 4,
                    decoration: InputDecoration(
                      hintText: s.customIconPlaceholder,
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _addCustomIcon, child: Text(s.addNew)),
              ],
            ),
            const SizedBox(height: 14),
            _FieldLabel(s.color),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final colorValue in colorChoices)
                  GestureDetector(
                    onTap: () => setState(() => _colorValue = colorValue),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorValue == colorValue
                              ? wq.text
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: _pickCustomColor,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: wq.border),
                      gradient: const SweepGradient(
                        colors: [
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.purple,
                          Colors.red,
                        ],
                      ),
                    ),
                    child: const Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FieldLabel(s.category),
            Row(
              children: [
                Expanded(
                  child: _DropdownField<String?>(
                    value: state.categoryById(_categoryId)?.id,
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(s.noCategory),
                      ),
                      for (final category in state.categories)
                        DropdownMenuItem<String?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _categoryId = value),
                  ),
                ),
                const SizedBox(width: 8),
                WqIconButton(
                  size: 44,
                  tooltip: s.addCategory,
                  onTap: () async {
                    final created = await showCategoryManagerSheet(context);
                    if (created != null && mounted) {
                      setState(() => _categoryId = created);
                    }
                  },
                  child: const Icon(Icons.add, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FieldLabel(s.priority),
            SegmentedPills(
              options: [s.low, s.medium, s.high, s.urgent],
              selectedIndex: _priority.index,
              onSelected: (i) =>
                  setState(() => _priority = TaskPriority.values[i]),
            ),
            const SizedBox(height: 14),
            _FieldLabel(s.timeSlot),
            SegmentedPills(
              options: [
                s.slotAny,
                s.slotMorning,
                s.slotAfternoon,
                s.slotEvening,
              ],
              selectedIndex: _timeSlot.index,
              onSelected: (i) => setState(() => _timeSlot = TimeSlot.values[i]),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🚭 ${s.quitHabit}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        s.quitHint,
                        style: TextStyle(fontSize: 11, color: wq.textMuted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isQuit,
                  onChanged: (v) => setState(() => _isQuit = v),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FieldLabel(s.subtasks),
            for (var i = 0; i < _subtasks.length; i++)
              Row(
                children: [
                  Icon(Icons.drag_indicator, size: 16, color: wq.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _subtasks[i].title,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  WqIconButton(
                    onTap: () => setState(() => _subtasks.removeAt(i)),
                    child: Icon(Icons.close, size: 14, color: wq.textMuted),
                  ),
                ],
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    decoration: InputDecoration(hintText: s.subtaskHint),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addSubtask,
                  child: const Icon(Icons.add, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(s.dailyTarget),
                      TextField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: s.targetHint),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(s.unit),
                      TextField(
                        controller: _unitController,
                        enabled: _target > 1,
                        decoration: InputDecoration(hintText: s.unitHint),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FieldLabel(s.recurrence),
            _DropdownField<RecurrenceType>(
              value: _recurrence.type,
              items: [
                DropdownMenuItem(
                  value: RecurrenceType.daily,
                  child: Text(s.daily),
                ),
                DropdownMenuItem(
                  value: RecurrenceType.weekly,
                  child: Text(s.weekly),
                ),
                DropdownMenuItem(
                  value: RecurrenceType.monthly,
                  child: Text(s.monthly),
                ),
                DropdownMenuItem(
                  value: RecurrenceType.specificDays,
                  child: Text(s.specificDays),
                ),
                DropdownMenuItem(
                  value: RecurrenceType.once,
                  child: Text(s.once),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _recurrence = _recurrence.copyWith(type: value));
              },
            ),
            const SizedBox(height: 14),
            ..._recurrenceDetails(s, wq),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.notifications,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: wq.textMuted,
                  ),
                ),
                Switch(
                  value: _notificationsOn,
                  onChanged: (value) =>
                      setState(() => _notificationsOn = value),
                ),
              ],
            ),
            if (_notificationsOn) ...[
              const SizedBox(height: 6),
              _FieldLabel(s.reminders),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (var i = 0; i < _reminders.length; i++)
                    InputChip(
                      avatar: const Icon(Icons.alarm, size: 15),
                      label: Text(
                        _hhmm(_reminders[i]),
                        textDirection: TextDirection.ltr,
                      ),
                      onPressed: () => _pickReminder(replaceIndex: i),
                      onDeleted: () => setState(() => _reminders.removeAt(i)),
                    ),
                  if (_reminders.length < 3)
                    ActionChip(
                      label: Text(
                        _reminders.isEmpty ? s.noReminder : s.addReminder,
                      ),
                      onPressed: () => _pickReminder(),
                    ),
                ],
              ),
            ],
            if (_formError != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: wq.missed.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: wq.missed.withValues(alpha: .4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: wq.missed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formError!,
                        style: TextStyle(fontSize: 12, color: wq.missed),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final navigator = Navigator.of(context);
                        navigator.pop(false);
                        SubscriptionScreen.push(navigator.context);
                      },
                      child: Text(
                        s.upgradeNow,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                if (_isEditing) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: wq.missed,
                      ),
                      child: Text(s.delete),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(s.cancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(onPressed: _save, child: Text(s.save)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _recurrenceDetails(AppStrings s, WaqtiColors wq) {
    switch (_recurrence.type) {
      case RecurrenceType.weekly:
        return [
          _FieldLabel(s.weekday),
          _DropdownField<int>(
            value: _recurrence.weekday,
            items: [
              for (var i = 0; i < 7; i++)
                DropdownMenuItem(value: i, child: Text(s.weekdays[i])),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(
                () => _recurrence = _recurrence.copyWith(weekday: value),
              );
            },
          ),
          const SizedBox(height: 14),
        ];
      case RecurrenceType.monthly:
        return [
          _FieldLabel(s.dayOfMonth),
          _DropdownField<int>(
            value: _recurrence.dayOfMonth.clamp(1, 31),
            items: [
              for (var d = 1; d <= 31; d++)
                DropdownMenuItem(value: d, child: Text('$d')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(
                () => _recurrence = _recurrence.copyWith(dayOfMonth: value),
              );
            },
          ),
          const SizedBox(height: 14),
        ];
      case RecurrenceType.specificDays:
        return [
          _FieldLabel(s.chooseDays),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < 7; i++)
                GestureDetector(
                  onTap: () {
                    final days = [..._recurrence.days];
                    if (!days.remove(i)) days.add(i);
                    setState(
                      () => _recurrence = _recurrence.copyWith(days: days),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _recurrence.days.contains(i)
                          ? wq.primaryLight
                          : wq.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _recurrence.days.contains(i)
                            ? wq.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      s.weekdaysShort[i],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
        ];
      case RecurrenceType.once:
        final date = _recurrence.date;
        return [
          _FieldLabel(s.date),
          OutlinedButton.icon(
            onPressed: _pickOnceDate,
            icon: const Icon(Icons.event, size: 18),
            label: Text(
              date == null ? s.date : '${date.year}/${date.month}/${date.day}',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: wq.text,
              side: BorderSide(color: wq.border),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ];
      case RecurrenceType.daily:
        return const [];
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: context.wq.textMuted,
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final wq = context.wq;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: wq.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: wq.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: wq.surface,
          style: TextStyle(
            fontSize: 13.5,
            color: wq.text,
            fontFamily: 'Tajawal',
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
