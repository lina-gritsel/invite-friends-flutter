import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class InviteActions {
  const InviteActions();

  Future<void> copy(String value) {
    return Clipboard.setData(ClipboardData(text: value));
  }

  Future<void> share(String value, Rect origin) {
    return SharePlus.instance.share(
      ShareParams(
        text: 'Присоединяйтесь ко мне в IdeaWa: $value',
        sharePositionOrigin: origin,
      ),
    );
  }
}
