import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/create_event_screen.dart';
import 'package:invite_friends/features/invite/friend_details_screen.dart';
import 'package:invite_friends/features/invite/invite_layout.dart';
import 'package:invite_friends/features/invite/invite_models.dart';
import 'package:invite_friends/features/invite/widgets/invite_sections.dart';

typedef CopyInvite = Future<void> Function(String value);
typedef ShareInvite = Future<void> Function(String value, Rect origin);

class InviteScreen extends StatefulWidget {
  const InviteScreen({
    required this.onCopy,
    required this.onShare,
    this.data = InviteData.demo,
    super.key,
  });

  final InviteData data;
  final CopyInvite onCopy;
  final ShareInvite onShare;

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  bool _isSharing = false;

  Future<void> _copy() async {
    try {
      await widget.onCopy(widget.data.inviteUrl);
      if (!mounted) return;
      unawaited(HapticFeedback.selectionClick());
      _showMessage(
        text: 'Ссылка скопирована',
        backgroundColor: AppColors.successSoft,
        foregroundColor: AppColors.successInk,
        icon: Icons.check_circle_outline_rounded,
      );
    } on Exception {
      if (!mounted) return;
      _showMessage(
        text: 'Не удалось скопировать ссылку',
        backgroundColor: AppColors.errorSoft,
        foregroundColor: AppColors.errorInk,
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _share(BuildContext originContext, {String? value}) async {
    if (_isSharing) return;

    final box = originContext.findRenderObject() as RenderBox?;
    final origin = box == null
        ? Rect.zero
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _isSharing = true);
    try {
      await widget.onShare(value ?? widget.data.inviteUrl, origin);
    } on Exception {
      if (!mounted) return;
      _showMessage(
        text: 'Не удалось открыть меню «Поделиться»',
        backgroundColor: AppColors.errorSoft,
        foregroundColor: AppColors.errorInk,
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _openFriend(Friend friend) {
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => FriendDetailsScreen(
            friend: friend,
            onMessage: (originContext) => unawaited(
              _share(
                originContext,
                value:
                    'Привет, ${friend.name}! Давай запланируем совместное событие.',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateEvent(EventCategory initialCategory) async {
    final wasCreated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => CreateEventScreen(
          friends: widget.data.friends,
          initialCategory: initialCategory,
        ),
      ),
    );
    if (!mounted || wasCreated != true) return;

    _showMessage(
      text: 'Событие создано',
      backgroundColor: AppColors.successSoft,
      foregroundColor: AppColors.successInk,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  void _showMessage({
    required String text,
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
    Color? iconColor,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: backgroundColor,
          content: Row(
            children: [
              Icon(icon, color: iconColor ?? foregroundColor, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Пригласить друзей'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: InviteLayout.maxContentWidth,
            ),
            child: ListView(
              key: const Key('invite-scroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              children: [
                const InviteHeroCard(),
                const SizedBox(height: AppSpacing.xs),
                ReferralCard(
                  data: widget.data,
                  onCopy: () => unawaited(_copy()),
                  onShare: _isSharing
                      ? null
                      : (shareContext) => unawaited(_share(shareContext)),
                ),
                const SizedBox(height: AppSpacing.xs),
                const ReferralRuleCard(),
                const SizedBox(height: AppSpacing.xs),
                SavingsSummaryCard(data: widget.data),
                const SizedBox(height: AppSpacing.xs),
                SharedEventsCard(
                  onCreate: (category) => unawaited(_openCreateEvent(category)),
                ),
                const SizedBox(height: AppSpacing.xs),
                FriendsCard(
                  friends: widget.data.friends,
                  onFriendTap: _openFriend,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: InviteLayout.ctaMaxWidth,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Builder(
                builder: (buttonContext) => FilledButton(
                  key: const Key('invite-friend-cta'),
                  onPressed: _isSharing
                      ? null
                      : () => unawaited(_share(buttonContext)),
                  child: const Text('Пригласить друга'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
