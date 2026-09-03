import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_info.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// شاشة الاشتراك — أربع باقات متدرجة القيمة (محاكاة بلا دفع فعلي).
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
  }

  void _choose(BuildContext context, AppState state, AppStrings s, PlanTier t) {
    final cancelling = t == PlanTier.free;
    state.setTier(t);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(cancelling ? s.cancelledMsg : s.subscribedTier)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;
    final yearly = state.billingCycle == 'yearly';

    String price(String monthly, String perYear) => yearly ? perYear : monthly;
    final per = yearly ? s.perYear : s.perMonth;

    final plans = <_Plan>[
      _Plan(
        tier: PlanTier.free,
        title: s.freePlan,
        emoji: '🌱',
        price: r'$0',
        per: '',
        intro: null,
        features: [s.freeFeat1, s.freeFeat2],
        offFeatures: [s.freeFeat3],
      ),
      _Plan(
        tier: PlanTier.bronze,
        title: '🥉 ${s.bronzePlan}',
        emoji: '',
        price: price(r'$1.99', r'$15.99'),
        per: per,
        intro: null,
        features: [s.featAds, s.featTasks15, s.featStats],
        offFeatures: const [],
      ),
      _Plan(
        tier: PlanTier.silver,
        title: '🥈 ${s.silverPlan}',
        emoji: '',
        price: price(r'$4.99', r'$39.99'),
        per: per,
        intro: s.allBronzePlus,
        features: [s.featUnlimited, s.featThemes, s.featExport],
        offFeatures: const [],
        popular: true,
      ),
      _Plan(
        tier: PlanTier.gold,
        title: '🥇 ${s.goldPlan}',
        emoji: '',
        price: price(r'$9.99', r'$79.99'),
        per: per,
        intro: s.allSilverPlus,
        features: [
          s.featSync,
          s.featBackup,
          s.featGoals,
          s.featPrioritySupport,
          s.featFuture,
        ],
        offFeatures: const [],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(s.subscription)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              if (kLaunchMode) ...[
                WqCard(
                  borderColor: wq.primary,
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    s.launchFreeNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: wq.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: SegmentedPills(
                    options: [
                      s.monthlyPlan,
                      '${s.yearlyPlan} · ${s.saveBadge}',
                    ],
                    selectedIndex: yearly ? 1 : 0,
                    onSelected: (i) =>
                        state.setBillingCycle(i == 1 ? 'yearly' : 'monthly'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (final plan in plans) ...[
                _PlanCard(
                  plan: plan,
                  current: state.tier == plan.tier,
                  strings: s,
                  onChoose: () => _choose(context, state, s, plan.tier),
                  onCancel: () => _choose(context, state, s, PlanTier.free),
                ),
                const SizedBox(height: 16),
              ],
              if (!kLaunchMode)
                Center(
                  child: Text(
                    s.simulatedNote,
                    style: TextStyle(fontSize: 11.5, color: wq.textMuted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Plan {
  const _Plan({
    required this.tier,
    required this.title,
    required this.emoji,
    required this.price,
    required this.per,
    required this.intro,
    required this.features,
    required this.offFeatures,
    this.popular = false,
  });

  final PlanTier tier;
  final String title;
  final String emoji;
  final String price;
  final String per;
  final String? intro;
  final List<String> features;
  final List<String> offFeatures;
  final bool popular;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.current,
    required this.strings,
    required this.onChoose,
    required this.onCancel,
  });

  final _Plan plan;
  final bool current;
  final AppStrings strings;
  final VoidCallback onChoose;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final wq = context.wq;
    final tag = current
        ? strings.currentPlanTag
        : (plan.popular ? strings.mostPopular : null);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        WqCard(
          padding: const EdgeInsets.all(22),
          borderColor: current ? wq.primary : null,
          borderWidth: current ? 2 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${plan.emoji}${plan.title}'.trim(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.price,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (plan.per.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        plan.per,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: wq.textMuted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              if (plan.intro != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    plan.intro!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: wq.primaryDark,
                    ),
                  ),
                ),
              for (final feature in plan.features)
                _FeatureRow(text: feature, included: true),
              for (final feature in plan.offFeatures)
                _FeatureRow(text: feature, included: false),
              if (plan.tier != PlanTier.free) ...[
                const SizedBox(height: 16),
                if (kLaunchMode)
                  FilledButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.launchFreeNote)),
                    ),
                    child: Text(strings.comingSoon),
                  )
                else if (current)
                  ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(backgroundColor: wq.missed),
                    child: Text(strings.cancelSubscription),
                  )
                else
                  ElevatedButton(
                    onPressed: onChoose,
                    child: Text(strings.subscribeNow),
                  ),
              ],
            ],
          ),
        ),
        if (tag != null)
          PositionedDirectional(
            top: -11,
            start: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: wq.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text, required this.included});

  final String text;
  final bool included;

  @override
  Widget build(BuildContext context) {
    final wq = context.wq;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel_outlined,
            size: 16,
            color: included ? wq.done : wq.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: included ? wq.text : wq.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
