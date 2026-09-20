import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/create_event_screen.dart';
import 'package:invite_friends/features/invite/friend_details_screen.dart';
import 'package:invite_friends/features/invite/invite_models.dart';
import 'package:invite_friends/features/invite/invite_screen.dart';

void main() {
  testWidgets('matches the primary 390x844 layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const goldenKey = Key('invite-screen-golden');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.withFont('Roboto'),
        home: RepaintBoundary(
          key: goldenKey,
          child: InviteScreen(onCopy: _ignoreCopy, onShare: _ignoreShare),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(goldenKey),
      matchesGoldenFile('../../goldens/invite_screen_390x844.png'),
    );
  });

  testWidgets('matches the friend details 390x844 layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const goldenKey = Key('friend-details-golden');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.withFont('Roboto'),
        home: RepaintBoundary(
          key: goldenKey,
          child: FriendDetailsScreen(
            friend: InviteData.demo.friends.first,
            onMessage: _ignoreMessage,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(goldenKey),
      matchesGoldenFile('../../goldens/friend_details_390x844.png'),
    );
  });

  testWidgets('matches the create event 390x844 layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const goldenKey = Key('create-event-golden');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.withFont('Roboto'),
        home: RepaintBoundary(
          key: goldenKey,
          child: CreateEventScreen(friends: InviteData.demo.friends),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(goldenKey),
      matchesGoldenFile('../../goldens/create_event_390x844.png'),
    );
  });
}

Future<void> _ignoreCopy(String value) async {}

Future<void> _ignoreShare(String value, Rect origin) async {}

void _ignoreMessage(BuildContext context) {}
