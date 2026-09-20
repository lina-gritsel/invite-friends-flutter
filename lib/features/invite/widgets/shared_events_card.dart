import 'package:flutter/material.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/create_event_screen.dart';
import 'package:invite_friends/features/invite/widgets/invite_shared_widgets.dart';

class SharedEventsCard extends StatelessWidget {
  const SharedEventsCard({required this.onCreate, super.key});

  final ValueChanged<EventCategory> onCreate;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RoundIcon(icon: Icons.calendar_month_rounded),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
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
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Планируйте встречи, выбирайте время и делитесь идеями вместе с друзьями.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    EventChip(
                      label: 'Ужин',
                      onTap: () => onCreate(EventCategory.dinner),
                    ),
                    EventChip(
                      label: 'Кино',
                      onTap: () => onCreate(EventCategory.cinema),
                    ),
                    EventChip(
                      label: 'Парк',
                      onTap: () => onCreate(EventCategory.walk),
                    ),
                    OutlinedButton(
                      onPressed: () => onCreate(EventCategory.dinner),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(kMinInteractiveDimension, 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: const Text('Создать событие'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
