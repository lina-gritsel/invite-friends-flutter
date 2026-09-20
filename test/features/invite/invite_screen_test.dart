import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/create_event_screen.dart';
import 'package:invite_friends/features/invite/friend_details_screen.dart';
import 'package:invite_friends/features/invite/invite_models.dart';
import 'package:invite_friends/features/invite/invite_screen.dart';

void main() {
  const inviteUrl = 'https://ideawa.app/invite/D7K4P2';

  Widget buildSubject({
    InviteData data = InviteData.demo,
    Future<void> Function(String)? onCopy,
    Future<void> Function(String, Rect)? onShare,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: InviteScreen(
        data: data,
        onCopy: onCopy ?? (_) async {},
        onShare: onShare ?? (_, _) async {},
      ),
    );
  }

  Widget buildCreateEvent({
    EventCategory initialCategory = EventCategory.dinner,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: CreateEventScreen(
        friends: InviteData.demo.friends,
        initialCategory: initialCategory,
      ),
    );
  }

  testWidgets('renders the complete invite content', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Пригласить друзей'), findsOneWidget);
    expect(find.text('Приглашайте друзей'), findsOneWidget);
    expect(find.text('ideawa.app/invite/D7K4P2'), findsOneWidget);
    expect(find.text('D7K4P2'), findsOneWidget);
    expect(find.byKey(const Key('invite-friend-cta')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Ваши друзья'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Maria'), findsOneWidget);
    expect(find.text('John'), findsOneWidget);
  });

  testWidgets('both copy controls use the canonical URL', (tester) async {
    final copied = <String>[];
    await tester.pumpWidget(
      buildSubject(onCopy: (value) async => copied.add(value)),
    );

    await tester.tap(find.byKey(const Key('copy-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('copy-icon-button')));
    await tester.pumpAndSettle();

    expect(copied, [inviteUrl, inviteUrl]);
    expect(find.text('Ссылка скопирована'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      AppColors.successSoft,
    );
  });

  testWidgets('reports a copy failure', (tester) async {
    await tester.pumpWidget(
      buildSubject(onCopy: (_) async => throw Exception('copy failed')),
    );

    await tester.tap(find.byKey(const Key('copy-button')));
    await tester.pumpAndSettle();

    expect(find.text('Не удалось скопировать ссылку'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      AppColors.errorSoft,
    );
  });

  testWidgets('share uses the canonical URL and a valid popover origin', (
    tester,
  ) async {
    String? shared;
    Rect? origin;
    await tester.pumpWidget(
      buildSubject(
        onShare: (value, rect) async {
          shared = value;
          origin = rect;
        },
      ),
    );

    await tester.tap(find.byKey(const Key('share-button')));
    await tester.pumpAndSettle();

    expect(shared, inviteUrl);
    expect(origin, isNotNull);
    expect(origin!.isEmpty, isFalse);
  });

  testWidgets('primary CTA shares the canonical URL', (tester) async {
    String? shared;
    Rect? origin;
    await tester.pumpWidget(
      buildSubject(
        onShare: (value, rect) async {
          shared = value;
          origin = rect;
        },
      ),
    );

    await tester.tap(find.byKey(const Key('invite-friend-cta')));
    await tester.pumpAndSettle();

    expect(shared, inviteUrl);
    expect(origin, isNotNull);
    expect(origin!.isEmpty, isFalse);
  });

  testWidgets('ignores repeated share taps while share sheet is opening', (
    tester,
  ) async {
    final shareCompleted = Completer<void>();
    var shareCalls = 0;
    await tester.pumpWidget(
      buildSubject(
        onShare: (_, _) {
          shareCalls += 1;
          return shareCompleted.future;
        },
      ),
    );

    await tester.tap(find.byKey(const Key('share-button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('share-button')));
    await tester.pump();

    expect(shareCalls, 1);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('invite-friend-cta')))
          .onPressed,
      isNull,
    );

    shareCompleted.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('reports a share failure', (tester) async {
    await tester.pumpWidget(
      buildSubject(onShare: (_, _) async => throw Exception('share failed')),
    );

    await tester.tap(find.byKey(const Key('share-button')));
    await tester.pumpAndSettle();

    expect(find.text('Не удалось открыть меню «Поделиться»'), findsOneWidget);
  });

  testWidgets('shows an empty state when no friends were invited', (
    tester,
  ) async {
    const data = InviteData(
      inviteUrl: inviteUrl,
      code: 'D7K4P2',
      invitedCount: 0,
      payingCount: 0,
      monthlySaving: r'$0 / мес',
      friends: [],
    );
    await tester.pumpWidget(buildSubject(data: data));

    await tester.scrollUntilVisible(
      find.text('Приглашённые друзья появятся здесь'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Приглашённые друзья появятся здесь'), findsOneWidget);
    expect(find.text('Alex'), findsNothing);
  });

  testWidgets('opens an active friend profile and returns to invite screen', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    final alex = find.byKey(const ValueKey('friend-Alex'));
    await tester.scrollUntilVisible(
      alex,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byKey(const Key('invite-scroll')),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    await tester.tap(alex);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('friend-details-screen')), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Вы оба получаете скидку'), findsOneWidget);
    expect(find.text(r'-$1 / мес'), findsOneWidget);
    expect(find.text('3 мес.'), findsOneWidget);
    expect(find.text(r'$3'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Совместные события'),
      300,
      scrollable: find.descendant(
        of: find.byKey(const Key('friend-details-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Поход в кино'), findsOneWidget);
    expect(find.text('Ужин в ресторане'), findsOneWidget);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Пригласить друзей'), findsOneWidget);
    expect(find.byKey(const Key('friend-details-screen')), findsNothing);
  });

  testWidgets('shows the pending friend state and empty events', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    final maria = find.byKey(const ValueKey('friend-Maria'));
    await tester.scrollUntilVisible(
      maria,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byKey(const Key('invite-scroll')),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    await tester.tap(maria);
    await tester.pumpAndSettle();

    expect(find.text('Maria'), findsOneWidget);
    expect(find.text('Ждёт Premium'), findsOneWidget);
    expect(find.text('Скидка ещё не активна'), findsOneWidget);
    expect(find.text(r'$0 / мес'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Совместные события'),
      300,
      scrollable: find.descendant(
        of: find.byKey(const Key('friend-details-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Пока нет совместных событий'), findsOneWidget);
  });

  testWidgets('friend message opens native share with valid origin', (
    tester,
  ) async {
    String? message;
    Rect? origin;
    await tester.pumpWidget(
      buildSubject(
        onShare: (value, rect) async {
          message = value;
          origin = rect;
        },
      ),
    );
    final alex = find.byKey(const ValueKey('friend-Alex'));
    await tester.scrollUntilVisible(
      alex,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byKey(const Key('invite-scroll')),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.tap(alex);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('message-friend-button')),
      300,
      scrollable: find.descendant(
        of: find.byKey(const Key('friend-details-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.byKey(const Key('message-friend-button')));
    await tester.pumpAndSettle();

    expect(message, 'Привет, Alex! Давай запланируем совместное событие.');
    expect(origin, isNotNull);
    expect(origin!.isEmpty, isFalse);
  });

  testWidgets('friend profile remains usable with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          theme: AppTheme.light,
          home: FriendDetailsScreen(
            friend: InviteData.demo.friends.first,
            onMessage: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('message-friend-button')),
      500,
      scrollable: find.descendant(
        of: find.byKey(const Key('friend-details-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.byKey(const Key('message-friend-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remains scrollable at compact width and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: buildSubject(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Ваши друзья'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ваши друзья'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes meaningful labels for the primary actions', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(buildSubject());

    expect(
      find.bySemanticsLabel('Скопировать ссылку приглашения'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Поделиться ссылкой приглашения'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('QR-код приглашения, код D7K4P2'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(buildSubject());

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('opens event creation from the main action', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.scrollUntilVisible(
      find.text('Создать событие'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.text('Создать событие'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('create-event-screen')), findsOneWidget);
    expect(find.text('Что планируем?'), findsOneWidget);
    expect(find.text('С кем идём?'), findsOneWidget);
  });

  testWidgets('opens event creation with the selected chip category', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.scrollUntilVisible(
      find.text('Кино'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.text('Кино'));
    await tester.pumpAndSettle();

    final cinema = tester.getSemantics(
      find.byKey(const Key('event-category-cinema')),
    );
    expect(find.byKey(const Key('create-event-screen')), findsOneWidget);
    expect(cinema.flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('validates, creates an event and reports success', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.scrollUntilVisible(
      find.text('Создать событие'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Создать событие'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('create-event-title')), '');
    await tester.ensureVisible(find.byKey(const Key('create-event-submit')));
    await tester.tap(find.byKey(const Key('create-event-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Введите название события'), findsOneWidget);

    await tester.tap(find.byKey(const Key('event-category-games')));
    await tester.pump();
    expect(
      tester
          .getSemantics(find.byKey(const Key('event-category-games')))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );

    await tester.enterText(
      find.byKey(const Key('create-event-title')),
      'Вечер в кино',
    );
    await tester.tap(find.byKey(const Key('create-event-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('create-event-screen')), findsNothing);
    expect(find.text('Событие создано'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
  });

  testWidgets('uses native date and time pickers', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildCreateEvent());

    await tester.ensureVisible(find.byKey(const Key('event-date')));
    await tester.tap(find.byKey(const Key('event-date')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('event-time')));
    await tester.tap(find.byKey(const Key('event-time')));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
  });

  testWidgets('event creation remains usable with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: buildCreateEvent(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('create-event-submit')),
      500,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('create-event-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byKey(const Key('create-event-submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('event creation meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(buildCreateEvent());

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
}
