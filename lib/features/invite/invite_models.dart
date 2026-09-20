enum FriendState { active, pending }

class FriendEvent {
  const FriendEvent({required this.title, required this.date});

  final String title;
  final String date;
}

class Friend {
  const Friend({
    required this.name,
    required this.status,
    required this.state,
    required this.joinedSince,
    required this.monthsTogether,
    required this.totalSavedDollars,
    required this.sharedEvents,
    this.saving,
  });

  final String name;
  final String status;
  final FriendState state;
  final String joinedSince;
  final int monthsTogether;
  final int totalSavedDollars;
  final List<FriendEvent> sharedEvents;
  final String? saving;
}

class InviteData {
  const InviteData({
    required this.inviteUrl,
    required this.code,
    required this.invitedCount,
    required this.payingCount,
    required this.monthlySaving,
    required this.friends,
  });

  final String inviteUrl;
  final String code;
  final int invitedCount;
  final int payingCount;
  final String monthlySaving;
  final List<Friend> friends;

  String get displayUrl => inviteUrl.replaceFirst('https://', '');

  static const demo = InviteData(
    inviteUrl: 'https://ideawa.app/invite/D7K4P2',
    code: 'D7K4P2',
    invitedCount: 4,
    payingCount: 2,
    monthlySaving: r'$2 / мес',
    friends: [
      Friend(
        name: 'Alex',
        status: 'Premium активен',
        state: FriendState.active,
        joinedSince: '12 июня 2026',
        monthsTogether: 3,
        totalSavedDollars: 3,
        sharedEvents: [
          FriendEvent(title: 'Поход в кино', date: '20 августа 2026'),
          FriendEvent(title: 'Ужин в ресторане', date: '5 августа 2026'),
        ],
        saving: r'-$1 / мес',
      ),
      Friend(
        name: 'Maria',
        status: 'Ждёт Premium',
        state: FriendState.pending,
        joinedSince: '2 сентября 2026',
        monthsTogether: 0,
        totalSavedDollars: 0,
        sharedEvents: [],
      ),
      Friend(
        name: 'John',
        status: 'Premium активен',
        state: FriendState.active,
        joinedSince: '4 июля 2026',
        monthsTogether: 2,
        totalSavedDollars: 2,
        sharedEvents: [
          FriendEvent(title: 'Прогулка в парке', date: '8 сентября 2026'),
        ],
        saving: r'-$1 / мес',
      ),
    ],
  );
}
