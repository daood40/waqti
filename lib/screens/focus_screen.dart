import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// مؤقت التركيز (بومودورو): يعتمد على وقت الانتهاء لا على عدّ التكّات،
/// فيبقى دقيقًا حتى لو توقفت الواجهة أو انتقل التطبيق للخلفية.
class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key, this.taskId});

  final String? taskId;

  static Future<void> push(BuildContext context, {String? taskId}) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => FocusScreen(taskId: taskId)));
  }

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  static const _presets = [15, 25, 45, 60];

  int _minutes = 25;
  String? _taskId;
  DateTime? _endsAt;
  int _pausedRemaining = 0;
  bool _running = false;
  Timer? _ticker;
  bool _completed = false;

  int get _totalSeconds => _minutes * 60;

  int get _remaining {
    if (_running && _endsAt != null) {
      final left = _endsAt!.difference(DateTime.now()).inSeconds;
      return left.clamp(0, _totalSeconds);
    }
    return _pausedRemaining == 0 && !_completed
        ? _totalSeconds
        : _pausedRemaining;
  }

  @override
  void initState() {
    super.initState();
    _taskId = widget.taskId;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    final remaining = _completed ? _totalSeconds : _remaining;
    setState(() {
      _completed = false;
      _running = true;
      _endsAt = DateTime.now().add(Duration(seconds: remaining));
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    if (_remaining <= 0) {
      _finish();
      return;
    }
    setState(() {});
  }

  void _pause() {
    setState(() {
      _pausedRemaining = _remaining;
      _running = false;
      _endsAt = null;
    });
    _ticker?.cancel();
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _endsAt = null;
      _pausedRemaining = 0;
      _completed = false;
    });
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    final state = context.read<AppState>();
    final s = AppStrings.of(state.lang);
    state.addFocusMinutes(_minutes);
    setState(() {
      _running = false;
      _endsAt = null;
      _pausedRemaining = 0;
      _completed = true;
    });
    final task = _taskId == null ? null : state.taskById(_taskId!);
    final today = DateTime.now();
    final canMark =
        task != null &&
        task.isApplicableOn(today) &&
        !(task.statusOn(today)?.isCompleted ?? false);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.focusDoneTitle),
        content: Text('$_minutes ${s.focusMinutes}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.close),
          ),
          if (canMark)
            FilledButton(
              onPressed: () {
                state.setStatus(task.id, today, TaskStatus.done);
                Navigator.of(dialogContext).pop();
              },
              child: Text(s.markDone),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;
    final today = DateTime.now();
    final remaining = _remaining;
    final pct = _totalSeconds == 0
        ? 0
        : (((_totalSeconds - remaining) / _totalSeconds) * 100).round();
    final label =
        '${(remaining ~/ 60).toString().padLeft(2, '0')}:'
        '${(remaining % 60).toString().padLeft(2, '0')}';
    final candidates = state.tasks
        .where((t) => t.isApplicableOn(today))
        .toList(growable: false);
    final focusToday = state.focusMinutesOn(today);

    return Scaffold(
      appBar: AppBar(title: Text('⏱ ${s.focusTimer}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            children: [
              Text(
                s.focusHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: wq.textMuted),
              ),
              const SizedBox(height: 18),
              if (!_running && !_completed && _pausedRemaining == 0)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: SegmentedPills(
                      options: [
                        for (final m in _presets) '$m ${s.minutesShort}',
                      ],
                      selectedIndex: _presets.indexOf(_minutes),
                      onSelected: (i) => setState(() => _minutes = _presets[i]),
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              Center(
                child: CompletionRing(
                  pct: pct,
                  size: 230,
                  strokeWidth: 14,
                  label: label,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_running)
                    FilledButton.icon(
                      onPressed: _pause,
                      icon: const Icon(Icons.pause_rounded),
                      label: Text(s.focusPause),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _start,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        _pausedRemaining > 0 ? s.focusResume : s.focusStart,
                      ),
                    ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: (_running || _pausedRemaining > 0 || _completed)
                        ? _reset
                        : null,
                    icon: const Icon(Icons.replay_rounded),
                    label: Text(s.focusReset),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                s.chooseTaskOptional,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: wq.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(s.noTaskFocus),
                    selected: _taskId == null,
                    onSelected: (_) => setState(() => _taskId = null),
                  ),
                  for (final t in candidates)
                    ChoiceChip(
                      label: Text('${t.icon} ${t.name}'),
                      selected: _taskId == t.id,
                      onSelected: (_) => setState(() => _taskId = t.id),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              WqCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎯 ${s.focusMinutes}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$focusToday ${s.minutesShort}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: wq.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
