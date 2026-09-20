import 'package:invite_friends/app/app_theme.dart';

abstract final class InviteLayout {
  static const maxContentWidth = 600.0;
  static const ctaMaxWidth = maxContentWidth - (AppSpacing.md * 2);

  static const stackActionsBelow = 300.0;
  static const stackQrBelow = 260.0;
  static const stackSummaryBelow = 410.0;
  static const largeTextScale = 1.4;

  static const qrSize = 104.0;
  static const heroIllustrationWidth = 88.0;
  static const heroIllustrationHeight = 70.0;
  static const leadingIconRadius = 25.0;
  static const friendAvatarRadius = 21.0;
  static const friendDetailsAvatarRadius = 38.0;
  static const friendTileMinHeight = 56.0;
}
