import 'package:flutter/material.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/invite_layout.dart';
import 'package:invite_friends/features/invite/invite_models.dart';
import 'package:invite_friends/features/invite/widgets/invite_shared_widgets.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class ReferralCard extends StatelessWidget {
  const ReferralCard({
    required this.data,
    required this.onCopy,
    required this.onShare,
    super.key,
  });

  final InviteData data;
  final VoidCallback onCopy;
  final ValueChanged<BuildContext>? onShare;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Ваша ссылка',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _LinkField(displayUrl: data.displayUrl, onCopy: onCopy),
          const SizedBox(height: AppSpacing.xs),
          LayoutBuilder(
            builder: (context, constraints) {
              final copy = _OutlineAction(
                key: const Key('copy-button'),
                icon: Icons.copy_rounded,
                label: 'Копировать',
                semanticLabel: 'Скопировать ссылку приглашения',
                onPressed: onCopy,
              );
              final share = Builder(
                builder: (shareContext) {
                  final shareAction = onShare;
                  return _OutlineAction(
                    key: const Key('share-button'),
                    icon: Icons.ios_share_rounded,
                    label: 'Поделиться',
                    semanticLabel: 'Поделиться ссылкой приглашения',
                    onPressed: shareAction == null
                        ? null
                        : () => shareAction(shareContext),
                  );
                },
              );
              if (constraints.maxWidth < InviteLayout.stackActionsBelow) {
                return Column(
                  children: [
                    SizedBox(width: double.infinity, child: copy),
                    const SizedBox(height: AppSpacing.xs),
                    SizedBox(width: double.infinity, child: share),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: share),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          const _LabeledDivider(label: 'или QR-код'),
          const SizedBox(height: AppSpacing.xs),
          LayoutBuilder(
            builder: (context, constraints) {
              final qr = Semantics(
                container: true,
                label: 'QR-код приглашения, код ${data.code}',
                image: true,
                child: ExcludeSemantics(
                  child: Container(
                    width: InviteLayout.qrSize,
                    height: InviteLayout.qrSize,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: PrettyQrView.data(data: data.inviteUrl),
                  ),
                ),
              );
              final code = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ваш код',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.codeSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        data.code,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              );
              if (constraints.maxWidth < InviteLayout.stackQrBelow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    qr,
                    const SizedBox(height: AppSpacing.xs),
                    code,
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  qr,
                  const SizedBox(width: AppSpacing.md),
                  Flexible(child: code),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LinkField extends StatelessWidget {
  const _LinkField({required this.displayUrl, required this.onCopy});

  final String displayUrl;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            key: const Key('copy-icon-button'),
            tooltip: 'Скопировать ссылку',
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 21),
          ),
        ],
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.square(kMinInteractiveDimension),
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
    );
  }
}

class _LabeledDivider extends StatelessWidget {
  const _LabeledDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.outline)),
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.outline)),
      ],
    );
  }
}
