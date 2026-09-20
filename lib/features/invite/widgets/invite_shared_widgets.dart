import 'package:flutter/material.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/invite_layout.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class RoundIcon extends StatelessWidget {
  const RoundIcon({required this.icon, this.solid = false, super.key});

  final IconData icon;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CircleAvatar(
        radius: InviteLayout.leadingIconRadius,
        backgroundColor: solid ? AppColors.primary : AppColors.primarySoft,
        child: Icon(
          icon,
          size: 28,
          color: solid ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}

class EventChip extends StatelessWidget {
  const EventChip({required this.label, this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: AppColors.primary),
    );
    final chip = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: text,
      ),
    );

    if (onTap == null) return chip;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: 'Создать событие: $label',
      child: Material(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(widthFactor: 1, child: text),
            ),
          ),
        ),
      ),
    );
  }
}
