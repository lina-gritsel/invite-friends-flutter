import 'package:flutter/material.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/invite_actions.dart';
import 'package:invite_friends/features/invite/invite_screen.dart';

class InviteFriendsApp extends StatelessWidget {
  const InviteFriendsApp({super.key, this.actions = const InviteActions()});

  final InviteActions actions;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Пригласить друзей',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: InviteScreen(onCopy: actions.copy, onShare: actions.share),
    );
  }
}
