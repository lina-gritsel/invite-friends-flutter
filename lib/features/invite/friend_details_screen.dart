import 'package:flutter/material.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/invite_layout.dart';
import 'package:invite_friends/features/invite/invite_models.dart';
import 'package:invite_friends/features/invite/widgets/invite_shared_widgets.dart';

class FriendDetailsScreen extends StatelessWidget {
  const FriendDetailsScreen({
    required this.friend,
    required this.onMessage,
    super.key,
  });

  final Friend friend;
  final ValueChanged<BuildContext> onMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('friend-details-screen'),
      appBar: AppBar(title: const Text('Профиль друга')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: InviteLayout.maxContentWidth,
            ),
            child: ListView(
              key: const Key('friend-details-scroll'),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _ProfileCard(friend: friend),
                const SizedBox(height: AppSpacing.xs),
                _DiscountCard(friend: friend),
                const SizedBox(height: AppSpacing.xs),
                _ActivityCard(friend: friend),
                const SizedBox(height: AppSpacing.xs),
                _EventsCard(events: friend.sharedEvents),
                const SizedBox(height: AppSpacing.xs),
                _MessageCard(friendName: friend.name, onPressed: onMessage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final active = friend.state == FriendState.active;
    return SurfaceCard(
      child: Row(
        children: [
          const CircleAvatar(
            radius: InviteLayout.friendDetailsAvatarRadius,
            backgroundColor: AppColors.primarySoft,
            child: Icon(
              Icons.person_rounded,
              size: 44,
              color: AppColors.avatarForeground,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    friend.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        friend.status.replaceAll('\n', ' · '),
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Друг с вами с ${friend.joinedSince}',
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

class _DiscountCard extends StatelessWidget {
  const _DiscountCard({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final active = friend.state == FriendState.active;
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundIcon(
            icon: active
                ? Icons.card_giftcard_rounded
                : Icons.hourglass_top_rounded,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    active
                        ? 'Вы оба получаете скидку'
                        : 'Скидка ещё не активна',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  active
                      ? '${friend.name} оформил Premium, и вы оба получаете по \$1 скидки каждый месяц.'
                      : '${friend.name} приняла приглашение. Скидка появится после оформления Premium.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.successSoft
                        : AppColors.warningSoft,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      friend.saving ?? r'$0 / мес',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: active
                            ? AppColors.successInk
                            : AppColors.warningInk,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _ActivityStat(
        icon: Icons.calendar_today_rounded,
        value: '${friend.monthsTogether} мес.',
        label: 'вместе',
      ),
      _ActivityStat(
        icon: Icons.bar_chart_rounded,
        value: '\$${friend.totalSavedDollars}',
        label: 'вы сэкономили',
      ),
      _ActivityStat(
        icon: Icons.star_rounded,
        value: friend.sharedEvents.length.toString(),
        label: 'общих события',
      ),
    ];
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Активность',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final stack =
                  constraints.maxWidth < InviteLayout.stackActionsBelow ||
                  MediaQuery.textScalerOf(context).scale(1) >
                      InviteLayout.largeTextScale;
              if (stack) {
                return Column(
                  children: [
                    for (var index = 0; index < stats.length; index++) ...[
                      stats[index],
                      if (index != stats.length - 1)
                        const Divider(
                          height: AppSpacing.md,
                          color: AppColors.outline,
                        ),
                    ],
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < stats.length; index++) ...[
                      Expanded(child: stats[index]),
                      if (index != stats.length - 1)
                        const VerticalDivider(color: AppColors.outline),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  const _ActivityStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: InviteLayout.leadingIconRadius,
          backgroundColor: AppColors.primarySoft,
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _EventsCard extends StatelessWidget {
  const _EventsCard({required this.events});

  final List<FriendEvent> events;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Совместные события',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (events.isEmpty)
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Пока нет совместных событий',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  for (var index = 0; index < events.length; index++) ...[
                    _EventTile(event: events[index]),
                    if (index != events.length - 1)
                      const Divider(
                        height: 1,
                        indent: 62,
                        color: AppColors.outline,
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final FriendEvent event;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${event.title}, ${event.date}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: InviteLayout.friendAvatarRadius,
              backgroundColor: AppColors.primarySoft,
              child: Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    event.date,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.friendName, required this.onPressed});

  final String friendName;
  final ValueChanged<BuildContext> onPressed;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RoundIcon(icon: Icons.chat_bubble_outline_rounded),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Написать другу',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Поделитесь идеями или предложите $friendName новое совместное событие.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Builder(
            builder: (buttonContext) => FilledButton.icon(
              key: const Key('message-friend-button'),
              onPressed: () => onPressed(buttonContext),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Написать'),
            ),
          ),
        ],
      ),
    );
  }
}
