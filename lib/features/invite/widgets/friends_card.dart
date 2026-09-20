import 'package:flutter/material.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/invite_layout.dart';
import 'package:invite_friends/features/invite/invite_models.dart';
import 'package:invite_friends/features/invite/widgets/invite_shared_widgets.dart';

class FriendsCard extends StatelessWidget {
  const FriendsCard({
    required this.friends,
    required this.onFriendTap,
    super.key,
  });

  final List<Friend> friends;
  final ValueChanged<Friend> onFriendTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Ваши друзья',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (friends.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Приглашённые друзья появятся здесь',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  for (var index = 0; index < friends.length; index++) ...[
                    FriendTile(
                      key: ValueKey('friend-${friends[index].name}'),
                      friend: friends[index],
                      onTap: () => onFriendTap(friends[index]),
                    ),
                    if (index != friends.length - 1)
                      const Divider(
                        height: 1,
                        indent: 58,
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

class FriendTile extends StatelessWidget {
  const FriendTile({required this.friend, required this.onTap, super.key});

  final Friend friend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = friend.state == FriendState.active;
    final largeText =
        MediaQuery.textScalerOf(context).scale(1) > InviteLayout.largeTextScale;
    return Semantics(
      button: true,
      label:
          '${friend.name}, ${friend.status.replaceAll('\n', ', ')}'
          '${friend.saving == null ? '' : ', ${friend.saving}'}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: InviteLayout.friendTileMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: InviteLayout.friendAvatarRadius,
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.avatarForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: AppSpacing.xs,
                            height: AppSpacing.xs,
                            margin: const EdgeInsets.only(top: 4, right: 5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              friend.status,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      if (largeText && friend.saving != null)
                        Text(
                          friend.saving!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.successInk,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                ),
                if (!largeText && friend.saving != null) ...[
                  const SizedBox(width: AppSpacing.xxs),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 5,
                      ),
                      child: Text(
                        friend.saving!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.successInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: AppSpacing.xxs),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
