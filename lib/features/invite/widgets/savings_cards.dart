import 'package:flutter/material.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/invite_layout.dart';
import 'package:invite_friends/features/invite/invite_models.dart';
import 'package:invite_friends/features/invite/widgets/invite_shared_widgets.dart';

class ReferralRuleCard extends StatelessWidget {
  const ReferralRuleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RoundIcon(icon: Icons.card_giftcard_rounded),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r'1 платящий друг = -$1 / мес',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  r'Когда друг оформляет Premium, ваша ежемесячная подписка '
                  r'становится дешевле на $1.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SavingsSummaryCard extends StatelessWidget {
  const SavingsSummaryCard({required this.data, super.key});

  final InviteData data;

  @override
  Widget build(BuildContext context) {
    final metric = Row(
      children: [
        const RoundIcon(icon: Icons.bar_chart_rounded, solid: true),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.monthlySaving,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                'скидка на подписку',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
    final stats = Column(
      children: [
        _StatLine(label: 'Приглашено друзей', value: '${data.invitedCount}'),
        _StatLine(label: 'Платящих друзей', value: '${data.payingCount}'),
        _StatLine(label: 'Сэкономлено', value: data.monthlySaving),
      ],
    );

    return SurfaceCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < InviteLayout.stackSummaryBelow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                metric,
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1, color: AppColors.outline),
                const SizedBox(height: AppSpacing.sm),
                stats,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: metric),
              const SizedBox(
                height: 64,
                child: VerticalDivider(color: AppColors.outline),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
