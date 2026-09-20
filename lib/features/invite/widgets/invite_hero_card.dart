import 'package:flutter/material.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/invite_layout.dart';
import 'package:invite_friends/features/invite/widgets/invite_shared_widgets.dart';

class InviteHeroCard extends StatelessWidget {
  const InviteHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Приглашайте друзей',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Каждый платящий друг уменьшает стоимость вашей подписки '
                  r'на $1 в месяц. А ещё с друзьями можно планировать '
                  'совместные события.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const ExcludeSemantics(child: _PeopleIllustration()),
        ],
      ),
    );
  }
}

class _PeopleIllustration extends StatelessWidget {
  const _PeopleIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: InviteLayout.heroIllustrationWidth,
      height: InviteLayout.heroIllustrationHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 0,
            bottom: AppSpacing.xs,
            child: Icon(
              Icons.person_rounded,
              size: 62,
              color: AppColors.primary.withValues(alpha: 0.34),
            ),
          ),
          const Positioned(
            left: 0,
            bottom: 0,
            child: Icon(
              Icons.person_rounded,
              size: 68,
              color: AppColors.primary,
            ),
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.auto_awesome, size: 22, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
