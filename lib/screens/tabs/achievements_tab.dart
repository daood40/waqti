import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../shell_screen.dart';

/// وسام واحد: هدف رقمي وقيمة حالية، يُفتح عند بلوغ الهدف.
class _Badge {
  const _Badge({
    required this.icon,
    required this.title,
    required this.desc,
    required this.current,
    required this.target,
  });

  final String icon;
  final String title;
  final String desc;
  final int current;
  final int target;

  bool get unlocked => current >= target;
  int get pct => target == 0 ? 100 : (current * 100 ~/ target).clamp(0, 100);
}

class _BadgeGroup {
  const _BadgeGroup(this.title, this.badges);

  final String title;
  final List<_Badge> badges;
}

/// تبويب الإنجازات: المستوى مع المتبقي للترقية، إحصاءات سريعة،
/// «هدفك التالي» (أقرب وسام مقفل)، وأقسام أوسمة متدرجة يظهر على
/// كل وسام مقفل شريط تقدمه نحو الهدف.
class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cursor = context.watch<MonthCursor>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;

    final stats = state.monthStats(cursor.year, cursor.month);
    final streak = state.currentStreak();
    final xp = state.totalXp();
    final done = state.totalDone();
    final level = state.levelInfo();
    final isArabic = state.lang == 'ar';

    String tr(String ar, String en) => isArabic ? ar : en;

    final groups = <_BadgeGroup>[
      _BadgeGroup(tr('🔥 سلاسل الالتزام', '🔥 Streaks'), [
        for (final t in const [3, 7, 14, 30])
          _Badge(
            icon: '🔥',
            title: tr('سلسلة $t أيام', '$t-day streak'),
            desc: tr(
              'أكمل كل مهامك $t أيام متتالية',
              'Finish everything $t days in a row',
            ),
            current: streak,
            target: t,
          ),
      ]),
      _BadgeGroup(tr('✅ الإنجازات الكلية', '✅ Total completions'), [
        for (final t in const [10, 50, 100, 250])
          _Badge(
            icon: t >= 100 ? '🏅' : '✅',
            title: tr('$t إنجازًا', '$t completions'),
            desc: tr('أنجز $t مهمة إجمالًا', 'Complete $t tasks in total'),
            current: done,
            target: t,
          ),
      ]),
      _BadgeGroup(tr('⭐ نقاط الخبرة', '⭐ Experience'), [
        for (final t in const [500, 2000, 5000])
          _Badge(
            icon: '⭐',
            title: '$t ${s.xp}',
            desc: tr('اجمع $t نقطة خبرة', 'Earn $t XP'),
            current: xp,
            target: t,
          ),
        _Badge(
          icon: '🚀',
          title: tr('المستوى 5', 'Level 5'),
          desc: tr('اوصل إلى المستوى الخامس', 'Reach level five'),
          current: level.level,
          target: 5,
        ),
      ]),
      _BadgeGroup(tr('🏆 التميز', '🏆 Excellence'), [
        _Badge(
          icon: '📋',
          title: tr('10 عادات', '10 habits'),
          desc: tr('أضف 10 مهام وعادات', 'Add 10 tasks and habits'),
          current: state.tasks.length,
          target: 10,
        ),
        _Badge(
          icon: '🏆',
          title: tr('شهر متقن', 'Solid month'),
          desc: tr('نسبة إكمال الشهر 80%', '80% month completion'),
          current: stats.pct,
          target: 80,
        ),
      ]),
    ];

    final all = [for (final g in groups) ...g.badges];
    final unlockedCount = all.where((b) => b.unlocked).length;

    // أقرب وسام مقفل: الأعلى تقدمًا نحو هدفه.
    _Badge? next;
    for (final b in all) {
      if (b.unlocked) continue;
      if (next == null || b.pct > next.pct) next = b;
    }

    final remaining = level.per - level.current;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        SectionTitle(s.achievements, topPadding: 0),

        // ---------- المستوى ----------
        WqCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.yourLevel,
                        style: TextStyle(fontSize: 12.5, color: wq.textMuted),
                      ),
                      Text(
                        '${s.level} ${level.level}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        s.totalXp,
                        style: TextStyle(fontSize: 12.5, color: wq.textMuted),
                      ),
                      Text(
                        '$xp ${s.xp}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LevelBar(pct: level.pct),
              const SizedBox(height: 5),
              Text(
                tr(
                  'بقيت $remaining نقطة للمستوى ${level.level + 1}',
                  '$remaining XP to level ${level.level + 1}',
                ),
                style: TextStyle(fontSize: 11, color: wq.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ---------- إحصاءات سريعة ----------
        Row(
          children: [
            Expanded(
              child: _StatTile(icon: '🔥', value: '$streak', label: s.streak),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: '✅',
                value: '$done',
                label: tr('إنجاز', 'Done'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: '🎖️',
                value: '$unlockedCount/${all.length}',
                label: tr('وسام', 'Badges'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ---------- هدفك التالي ----------
        if (next != null)
          WqCard(
            padding: const EdgeInsets.all(16),
            borderColor: wq.primary,
            child: Row(
              children: [
                Text(next.icon, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('🎯 هدفك التالي', '🎯 Your next goal'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: wq.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        next.title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        next.desc,
                        style: TextStyle(fontSize: 11.5, color: wq.textMuted),
                      ),
                      const SizedBox(height: 8),
                      LevelBar(pct: next.pct, height: 8),
                      const SizedBox(height: 4),
                      Text(
                        '${next.current} / ${next.target}',
                        style: TextStyle(fontSize: 11, color: wq.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // ---------- أقسام الأوسمة ----------
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: WqSpace.x5, bottom: 10),
            child: Text(
              group.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // عرض أقصى للبطاقة: عمودان على الهاتف وأكثر على الأجهزة اللوحية.
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemCount: group.badges.length,
            itemBuilder: (context, index) =>
                _BadgeCard(badge: group.badges[index]),
          ),
        ],
        const SizedBox(height: 4),
        Center(
          child: Text(
            s.achDesc,
            style: TextStyle(fontSize: 11.5, color: wq.textMuted),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final wq = context.wq;
    return WqCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: wq.textMuted)),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    final wq = context.wq;
    final b = badge;

    return WqCard(
      padding: const EdgeInsets.all(14),
      borderColor: b.unlocked ? wq.primary : null,
      borderWidth: b.unlocked ? 1.6 : 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            b.unlocked ? b.icon : '🔒',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              color: b.unlocked ? null : wq.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            b.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: b.unlocked ? wq.text : wq.textMuted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            b.desc,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, color: wq.textMuted),
          ),
          const SizedBox(height: 8),
          if (b.unlocked)
            Text(
              '✓',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: wq.done,
              ),
            )
          else ...[
            LevelBar(pct: b.pct, height: 7),
            const SizedBox(height: 4),
            Text(
              '${b.current} / ${b.target}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, color: wq.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
